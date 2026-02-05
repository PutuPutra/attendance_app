import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/attendance.dart';

class UserService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _usersKey = 'encrypted_users';

  Future<List<User>> loadUsers() async {
    final usersJson = await _secureStorage.read(key: _usersKey);
    if (usersJson != null) {
      final List<dynamic> jsonList = json.decode(usersJson);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      // Load initial users from assets
      final initialUsersJson = await rootBundle.loadString('assets/users.json');
      final List<dynamic> jsonList = json.decode(initialUsersJson);
      final users = jsonList.map((json) => User.fromJson(json)).toList();
      // Save to secure storage
      await saveUsers(users);
      return users;
    }
  }

  Future<void> saveUsers(List<User> users) async {
    final jsonList = users.map((user) => user.toJson()).toList();
    final contents = json.encode(jsonList);
    await _secureStorage.write(key: _usersKey, value: contents);
  }

  Future<User?> authenticate(String username, String password) async {
    final users = await loadUsers();
    try {
      final user = users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
      return user;
    } catch (e) {
      // Check if password is the reset code
      final prefs = await SharedPreferences.getInstance();
      final storedUsername = prefs.getString('reset_username');
      final storedCode = prefs.getString('reset_code');
      final timestamp = prefs.getInt('reset_timestamp') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (storedUsername == username &&
          storedCode == password &&
          (now - timestamp) < 60000) {
        // Valid reset code, return user and clear reset data
        final user = users.firstWhere((u) => u.username == username);
        await prefs.remove('reset_code');
        await prefs.remove('reset_username');
        await prefs.remove('reset_timestamp');
        await prefs.setBool('just_reset_password', true);
        return user;
      }
      return null;
    }
  }

  Future<void> addUser(User user) async {
    final users = await loadUsers();
    users.add(user);
    await saveUsers(users);
  }

  Future<void> updateUser(String id, User updatedUser) async {
    final users = await loadUsers();
    final index = users.indexWhere((user) => user.id == id);
    if (index != -1) {
      users[index] = updatedUser;
      await saveUsers(users);
    }
  }

  Future<void> deleteUser(String id) async {
    final users = await loadUsers();
    users.removeWhere((user) => user.id == id);
    await saveUsers(users);
  }

  Future<String> saveFaceImage(String userId, File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final faceDir = Directory(
      path.join(directory.path, 'assets', 'face_images'),
    );
    if (!await faceDir.exists()) {
      await faceDir.create(recursive: true);
    }
    final fileName = '${userId}_face.jpg';
    final filePath = path.join(faceDir.path, fileName);
    await imageFile.copy(filePath);
    // Return relative path for easier access
    return 'assets/face_images/$fileName';
  }

  Future<String> generateNewId() async {
    final users = await loadUsers();
    final ids = users.map((user) => int.tryParse(user.id) ?? 0).toList();
    final maxId = ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b);
    return (maxId + 1).toString();
  }

  Future<bool> changePassword(String userId, String newPassword) async {
    final users = await loadUsers();
    final index = users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updatedUser = users[index].copyWith(password: newPassword);
      users[index] = updatedUser;
      await saveUsers(users);
      return true;
    }
    return false;
  }

  Future<String> sendResetCode(String username) async {
    // Check if username exists in users
    final users = await loadUsers();
    final userExists = users.any((user) => user.username == username);
    if (!userExists) {
      throw Exception('Username not registered');
    }

    final code = _generateCode();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reset_code', code);
    await prefs.setString('reset_username', username);
    await prefs.setInt(
      'reset_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );

    // Return the code for display
    return code;
  }

  Future<String?> verifyResetCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final storedCode = prefs.getString('reset_code');
    final timestamp = prefs.getInt('reset_timestamp') ?? 0;
    final username = prefs.getString('reset_username');
    final now = DateTime.now().millisecondsSinceEpoch;
    if (storedCode == code && username != null && (now - timestamp) < 60000) {
      // 1 minute, valid, clear data to make one-time
      await prefs.remove('reset_code');
      await prefs.remove('reset_username');
      await prefs.remove('reset_timestamp');
      return username;
    }
    return null;
  }

  Future<bool> resetPasswordForUser(String username, String newPassword) async {
    final users = await loadUsers();
    final index = users.indexWhere((u) => u.username == username);
    if (index != -1) {
      final updatedUser = users[index].copyWith(password: newPassword);
      users[index] = updatedUser;
      await saveUsers(users);
      return true;
    }
    return false;
  }

  List<double> extractFaceFeatures(Face face, int width, int height) {
    final boundingBox = face.boundingBox;
    return [
      boundingBox.left / width,
      boundingBox.top / height,
      boundingBox.width / width,
      boundingBox.height / height,
      (face.headEulerAngleX ?? 0.0) / 180.0 + 0.5,
      (face.headEulerAngleY ?? 0.0) / 180.0 + 0.5,
      (face.headEulerAngleZ ?? 0.0) / 180.0 + 0.5,
      face.leftEyeOpenProbability ?? 0.0,
      face.rightEyeOpenProbability ?? 0.0,
      face.smilingProbability ?? 0.0,
    ];
  }

  double calculateFaceSimilarity(
    List<double> features1,
    List<double> features2,
  ) {
    if (features1.length != features2.length) return 0.0;
    double dot = 0.0, norm1 = 0.0, norm2 = 0.0;
    for (int i = 0; i < features1.length; i++) {
      dot += features1[i] * features2[i];
      norm1 += features1[i] * features1[i];
      norm2 += features2[i] * features2[i];
    }
    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;
    return dot / (sqrt(norm1) * sqrt(norm2));
  }

  Future<List<Attendance>> loadAttendances() async {
    final prefs = await SharedPreferences.getInstance();
    final attendancesJson = prefs.getString('attendances');
    if (attendancesJson != null) {
      final List<dynamic> jsonList = json.decode(attendancesJson);
      return jsonList.map((json) => Attendance.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveAttendances(List<Attendance> attendances) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = attendances.map((a) => a.toJson()).toList();
    final contents = json.encode(jsonList);
    await prefs.setString('attendances', contents);
  }

  Future<String> saveAttendanceImage(
    String userId,
    String type,
    File imageFile,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final attendanceDir = Directory(
      path.join(directory.path, 'attendance_images'),
    );
    if (!await attendanceDir.exists()) {
      await attendanceDir.create(recursive: true);
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${userId}_${type}_$timestamp.jpg';
    final filePath = path.join(attendanceDir.path, fileName);
    await imageFile.copy(filePath);
    return filePath;
  }

  Future<void> recordAttendance(
    String userId,
    String type,
    File imageFile,
  ) async {
    final attendances = await loadAttendances();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Find existing attendance for today
    Attendance? existing = attendances.firstWhere(
      (a) => a.userId == userId && a.date == today,
      orElse: () => Attendance(userId: userId, date: today),
    );

    if (!attendances.contains(existing)) {
      attendances.add(existing);
    }

    final imagePath = await saveAttendanceImage(userId, type, imageFile);

    switch (type) {
      case 'checkIn':
        existing = existing.copyWith(
          checkInTime: timeStr,
          checkInImage: imagePath,
        );
        break;
      case 'break':
        existing = existing.copyWith(breakTime: timeStr, breakImage: imagePath);
        break;
      case 'return':
        existing = existing.copyWith(
          returnTime: timeStr,
          returnImage: imagePath,
        );
        break;
      case 'checkOut':
        existing = existing.copyWith(
          checkOutTime: timeStr,
          checkOutImage: imagePath,
        );
        break;
    }

    // Update the list
    final index = attendances.indexWhere(
      (a) => a.userId == userId && a.date == today,
    );
    attendances[index] = existing;

    await saveAttendances(attendances);
  }

  Future<Attendance?> getTodayAttendance(String userId) async {
    final attendances = await loadAttendances();
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return attendances.firstWhere(
      (a) => a.userId == userId && a.date == today,
      orElse: () => Attendance(userId: userId, date: today),
    );
  }

  String _generateCode() {
    final random = Random();
    String code = '';
    for (int i = 0; i < 10; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }
}
