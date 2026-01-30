import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

class AttendanceHistoryWidget extends StatefulWidget {
  final bool isScrollable;
  const AttendanceHistoryWidget({super.key, this.isScrollable = false});

  @override
  State<AttendanceHistoryWidget> createState() =>
      _AttendanceHistoryWidgetState();
}

class _AttendanceHistoryWidgetState extends State<AttendanceHistoryWidget> {
  List<Map<String, dynamic>> _attendanceHistory = [];
  bool _showRefreshIcon = false;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Map<String, dynamic>> _getAttendanceHistory() {
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
      {
        'date': now.subtract(const Duration(days: 2)),
        'checkIn': '07:55 AM',
        'break': '12:00 PM',
        'return': '01:00 PM',
        'checkOut': '05:00 PM',
        'status': 'red',
      },
      {
        'date': now.subtract(const Duration(days: 3)),
        'checkIn': '07:58 AM',
        'break': '11:58 AM',
        'return': '12:58 PM',
        'checkOut': '05:00 PM',
        'status': 'red',
      },
      {
        'date': now.subtract(const Duration(days: 4)),
        'checkIn': '08:15 AM',
        'break': '12:00 PM',
        'return': '01:05 PM',
        'checkOut': '05:00 PM',
        'status': 'red',
      },
      {
        'date': now.subtract(const Duration(days: 5)),
        'checkIn': '08:00 AM',
        'break': '12:00 PM',
        'return': '01:00 PM',
        'checkOut': '05:00 PM',
        'status': 'red',
      },
      {
        'date': now.subtract(const Duration(days: 6)),
        'checkIn': '09:00 AM',
        'break': '12:05 PM',
        'return': '01:00 PM',
        'checkOut': '05:00 PM',
        'status': 'red',
      },
      {
        'date': now.subtract(const Duration(days: 7)),
        'checkIn': '08:00 AM',
        'break': '12:05 PM',
        'return': '01:00 PM',
        'checkOut': '05:00 PM',
        'status': 'green',
      },
    ];
  }

  Future<void> _loadAttendanceHistory() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear old data and force reload with new format
    await prefs.remove('attendance_history');

    final history = _getAttendanceHistory();

    // Simpan dengan format baru
    final historyJsonDummy = history.map((entry) {
      final date = entry['date'] as DateTime;
      return '${date.toIso8601String()}|${entry['checkIn']}|${entry['break']}|${entry['return']}|${entry['checkOut']}|${entry['status']}';
    }).toList();
    await prefs.setStringList('attendance_history', historyJsonDummy);

    setState(() {
      _attendanceHistory = history;
      _filterToLast7Days();
    });
  }

  Future<void> _saveAttendanceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _attendanceHistory.map((entry) {
      return '${entry['date'].toIso8601String()}|${entry['checkIn']}|${entry['checkOut']}|${entry['status']}';
    }).toList();
    await prefs.setStringList('attendance_history', historyJson);
  }

  void _filterToLast7Days() {
    final fullHistory = _getAttendanceHistory();
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final filtered =
        fullHistory.where((entry) {
          final date = entry['date'] as DateTime;
          return date.isAfter(sevenDaysAgo) &&
              date.isBefore(now.add(const Duration(days: 1)));
        }).toList()..sort(
          (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
        );

    setState(() {
      _attendanceHistory = filtered;
      _startDateFilter = null;
      _endDateFilter = null;
      _showRefreshIcon = false;
    });
  }

  void _filterByDateRange(DateTime start, DateTime end) {
    final fullHistory = _getAttendanceHistory();
    final filtered =
        fullHistory.where((entry) {
          final date = entry['date'] as DateTime;
          return date.isAfter(start.subtract(const Duration(days: 1))) &&
              date.isBefore(end.add(const Duration(days: 1)));
        }).toList()..sort(
          (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
        );

    setState(() {
      _attendanceHistory = filtered;
      _startDateFilter = start;
      _endDateFilter = end;
      _showRefreshIcon = true;
    });
  }

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter by Date Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedStartDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedStartDate = picked;
                        });
                      }
                    },
                    child: Text(
                      _selectedStartDate == null
                          ? 'Select Start Date'
                          : 'Start: ${DateFormat('dd/MM/yyyy').format(_selectedStartDate!)}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedEndDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedEndDate = picked;
                        });
                      }
                    },
                    child: Text(
                      _selectedEndDate == null
                          ? 'Select End Date'
                          : 'End: ${DateFormat('dd/MM/yyyy').format(_selectedEndDate!)}',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (_selectedStartDate != null &&
                        _selectedEndDate != null) {
                      _filterByDateRange(
                        _selectedStartDate!,
                        _selectedEndDate!,
                      );
                      _selectedStartDate = null;
                      _selectedEndDate = null;
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select both start and end dates',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper method to parse time string and return DateTime for comparison
  DateTime? _parseTimeString(String timeStr) {
    try {
      // Remove extra spaces
      timeStr = timeStr.trim();

      // Handle 12-hour format (e.g., "08:00 AM" or "08:45 AM")
      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        final format = DateFormat('hh:mm a');
        return format.parse(timeStr);
      }

      // Handle 24-hour format (e.g., "08:00" or "08:45")
      final format = DateFormat('HH:mm');
      return format.parse(timeStr);
    } catch (e) {
      return null;
    }
  }

  // Check if check-in time is after 08:01
  bool _isLateCheckIn(String checkInTime) {
    final checkInDateTime = _parseTimeString(checkInTime);
    if (checkInDateTime == null) return false;

    // Create reference time 08:01
    final referenceTime = DateTime(
      checkInDateTime.year,
      checkInDateTime.month,
      checkInDateTime.day,
      8,
      1,
    );

    return checkInDateTime.isAfter(referenceTime);
  }

  // Check if break time is after 12:00
  bool _isLateBreak(String breakTime) {
    final breakDateTime = _parseTimeString(breakTime);
    if (breakDateTime == null) return false;

    // Create reference time 12:00
    final referenceTime = DateTime(
      breakDateTime.year,
      breakDateTime.month,
      breakDateTime.day,
      12,
      0,
    );

    return breakDateTime.isAfter(referenceTime);
  }

  // Check if return from break is after 13:00
  bool _isLateReturn(String returnTime) {
    final returnDateTime = _parseTimeString(returnTime);
    if (returnDateTime == null) return false;

    // Create reference time 13:00
    final referenceTime = DateTime(
      returnDateTime.year,
      returnDateTime.month,
      returnDateTime.day,
      13,
      0,
    );

    return returnDateTime.isAfter(referenceTime);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    final header = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            localizations.attendanceHistory,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: _showDateRangePicker,
          ),

          if (_showRefreshIcon)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: _filterToLast7Days,
            ),
        ],
      ),
    );

    final listView = ListView.builder(
      shrinkWrap: widget.isScrollable,
      physics: widget.isScrollable
          ? const NeverScrollableScrollPhysics()
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _attendanceHistory.length,
      itemBuilder: (context, index) {
        final entry = _attendanceHistory[index];
        final date = entry['date'] as DateTime;
        final formattedDate = DateFormat(
          'EEE, dd/MM/yyyy',
          locale,
        ).format(date);
        final status = entry['status'] as String;

        // Determine check-in color based on time
        final checkInTime = entry['checkIn'] as String;
        final breakTime = entry['break'] as String? ?? '-';
        final returnTime = entry['return'] as String? ?? '-';
        final checkOutTime = entry['checkOut'] as String;

        final isLateCheckIn = _isLateCheckIn(checkInTime);
        final isLateBreak = breakTime != '-' ? _isLateBreak(breakTime) : false;
        final isLateReturn = returnTime != '-'
            ? _isLateReturn(returnTime)
            : false;

        // Use orange warning icon for late check-in, green check for on-time
        final iconColor = isLateCheckIn
            ? Colors.orange
            : Theme.of(context).colorScheme.primary;
        final icon = isLateCheckIn ? Icons.warning : Icons.check_circle;

        final checkInColor = isLateCheckIn ? Colors.red : onSurfaceColor;
        final breakColor = onSurfaceColor;
        final returnColor = onSurfaceColor;
        final checkOutColor = onSurfaceColor;

        return ListTile(
          tileColor: isDarkMode ? Colors.transparent : Colors.grey[100],
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: iconColor, size: 20),
          title: Text(
            formattedDate,
            style: TextStyle(color: onSurfaceColor, fontSize: 14),
          ),
          trailing: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: checkInTime,
                  style: TextStyle(color: checkInColor, fontSize: 14),
                ),
                TextSpan(
                  text: ' - ',
                  style: TextStyle(color: onSurfaceColor, fontSize: 14),
                ),
                TextSpan(
                  text: breakTime,
                  style: TextStyle(color: breakColor, fontSize: 14),
                ),
                TextSpan(
                  text: ' - ',
                  style: TextStyle(color: onSurfaceColor, fontSize: 14),
                ),
                TextSpan(
                  text: returnTime,
                  style: TextStyle(color: returnColor, fontSize: 14),
                ),
                TextSpan(
                  text: ' - ',
                  style: TextStyle(color: onSurfaceColor, fontSize: 14),
                ),
                TextSpan(
                  text: checkOutTime,
                  style: TextStyle(color: checkOutColor, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (widget.isScrollable) {
      return Column(children: [header, listView]);
    } else {
      return SizedBox.expand(
        child: Column(
          children: [
            header,
            Expanded(child: listView),
          ],
        ),
      );
    }
  }
}
