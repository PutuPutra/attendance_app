import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  static const String _usersFileName = 'users.json';

  Future<String> _getUsersFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_usersFileName';
  }

  Future<void> _ensureUsersFileExists() async {
    final filePath = await _getUsersFilePath();
    final file = File(filePath);

    if (!await file.exists()) {
      // Load initial users from assets
      final initialUsersJson = await rootBundle.loadString('assets/users.json');
      await file.writeAsString(initialUsersJson);
    }
  }

  Future<List<User>> loadUsers() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        final List<dynamic> jsonList = json.decode(usersJson);
        return jsonList.map((json) => User.fromJson(json)).toList();
      } else {
        // Load initial users from assets
        final initialUsersJson = await rootBundle.loadString(
          'assets/users.json',
        );
        final List<dynamic> jsonList = json.decode(initialUsersJson);
        final users = jsonList.map((json) => User.fromJson(json)).toList();
        // Save to prefs
        await saveUsers(users);
        return users;
      }
    } else {
      await _ensureUsersFileExists();
      final filePath = await _getUsersFilePath();
      final file = File(filePath);
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => User.fromJson(json)).toList();
    }
  }

  Future<void> saveUsers(List<User> users) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = users.map((user) => user.toJson()).toList();
      final contents = json.encode(jsonList);
      await prefs.setString('users', contents);
    } else {
      final filePath = await _getUsersFilePath();
      final file = File(filePath);
      final jsonList = users.map((user) => user.toJson()).toList();
      final contents = json.encode(jsonList);
      await file.writeAsString(contents);
    }
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
    final directory = Directory('assets/images');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final fileName = '${userId}_face.jpg';
    final filePath = path.join(directory.path, fileName);
    await imageFile.copy(filePath);
    return filePath;
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

  String _generateCode() {
    final random = Random();
    String code = '';
    for (int i = 0; i < 10; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }
}
