import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
      return users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
    } catch (e) {
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

  Future<String> generateNewId() async {
    final users = await loadUsers();
    final ids = users.map((user) => int.tryParse(user.id) ?? 0).toList();
    final maxId = ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b);
    return (maxId + 1).toString();
  }

  Future<bool> changePassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    final users = await loadUsers();
    final index = users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = users[index];
      if (user.password == oldPassword) {
        final updatedUser = user.copyWith(password: newPassword);
        users[index] = updatedUser;
        await saveUsers(users);
        return true;
      }
    }
    return false;
  }
}
