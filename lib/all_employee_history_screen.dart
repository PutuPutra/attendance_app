import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';
import 'models/user.dart';
import 'services/user_service.dart';

class AllEmployeeHistoryScreen extends StatefulWidget {
  const AllEmployeeHistoryScreen({super.key});

  @override
  State<AllEmployeeHistoryScreen> createState() =>
      _AllEmployeeHistoryScreenState();
}

class _AllEmployeeHistoryScreenState extends State<AllEmployeeHistoryScreen> {
  final UserService _userService = UserService();
  List<User> _users = [];
  Map<String, List<Map<String, dynamic>>> _attendanceHistories = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final users = await _userService.loadUsers();
    setState(() {
      _users = users;
    });
    // For each user, load their attendance history (dummy for now)
    for (var user in _users) {
      _attendanceHistories[user.id] = _getDummyAttendanceHistory();
    }
    setState(() {});
  }

  List<Map<String, dynamic>> _getDummyAttendanceHistory() {
    final now = DateTime.now();
    return [
      {
        'date': now.subtract(const Duration(days: 0)),
        'checkIn': '08:00 AM',
        'break': '12:00 PM',
        'return': '01:00 PM',
        'checkOut': '05:00 PM',
        'status': 'green',
      },
      {
        'date': now.subtract(const Duration(days: 1)),
        'checkIn': '08:45 AM',
        'break': '12:05 PM',
        'return': '01:10 PM',
        'checkOut': '05:00 PM',
        'status': 'red',
      },
      // Add more as needed
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.allEmployeeHistory)),
      body: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final user = _users[index];
          final history = _attendanceHistories[user.id] ?? [];
          return ExpansionTile(
            dense: true,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 0.0,
            ),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 0.0,
            ),
            title: Text('${user.username} (${user.id})'),
            children: history.map((entry) {
              final date = entry['date'] as DateTime;
              final formattedDate = DateFormat('EEE, dd/MM/yyyy').format(date);
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 2.0,
                ),
                title: Text(formattedDate),
                subtitle: Text(
                  '${entry['checkIn']} - ${entry['break']} - ${entry['return']} - ${entry['checkOut']}',
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
