import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'models/user.dart';
import 'services/user_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _userService.loadUsers();
    setState(() {
      _users = users.where((u) => u.role == 'karyawan').toList();
    });
  }

  Future<void> _addUser() async {
    final newUser = await _showUserDialog();
    if (newUser != null) {
      await _userService.addUser(newUser);
      _loadUsers();
    }
  }

  Future<void> _editUser(User user) async {
    final updatedUser = await _showUserDialog(user: user);
    if (updatedUser != null) {
      await _userService.updateUser(user.id, updatedUser);
      _loadUsers();
    }
  }

  Future<void> _deleteUser(User user) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteUser),
        content: Text(localizations.confirmDeleteUser(user.username)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _userService.deleteUser(user.id);
      _loadUsers();
    }
  }

  Future<User?> _showUserDialog({User? user}) async {
    final localizations = AppLocalizations.of(context)!;
    final isEditing = user != null;
    final idController = TextEditingController(text: user?.id ?? '');
    final usernameController = TextEditingController(
      text: user?.username ?? '',
    );
    final passwordController = TextEditingController(
      text: user?.password ?? '',
    );
    final emailController = TextEditingController(text: user?.email ?? '');

    return showDialog<User>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? localizations.editUser : localizations.addUser),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: localizations.employeeId,
                ),
                enabled: !isEditing,
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: localizations.username),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: localizations.password),
                obscureText: true,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: localizations.email),
              ),

              TextField(
                controller: TextEditingController(text: localizations.karyawan),
                decoration: InputDecoration(labelText: localizations.role),
                enabled: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              final newUser = User(
                id: isEditing ? user!.id : idController.text.trim(),
                username: usernameController.text.trim(),
                password: passwordController.text.trim(),
                email: emailController.text.trim(),
                role: 'karyawan',
              );
              Navigator.of(context).pop(newUser);
            },
            child: Text(
              isEditing ? localizations.update : localizations.addUser,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.userManagement)),
      body: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 0.0,
            ),
            title: Text(user.username),
            subtitle: Text('${user.email} - ${user.role}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editUser(user),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteUser(user),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: const Icon(Icons.add),
      ),
    );
  }
}
