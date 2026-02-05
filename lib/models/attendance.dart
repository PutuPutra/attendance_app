class Attendance {
  final String userId;
  final DateTime date;
  final String? checkInTime;
  final String? checkInImage;
  final String? breakTime;
  final String? breakImage;
  final String? returnTime;
  final String? returnImage;
  final String? checkOutTime;
  final String? checkOutImage;

  Attendance({
    required this.userId,
    required this.date,
    this.checkInTime,
    this.checkInImage,
    this.breakTime,
    this.breakImage,
    this.returnTime,
    this.returnImage,
    this.checkOutTime,
    this.checkOutImage,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      checkInTime: json['checkInTime'],
      checkInImage: json['checkInImage'],
      breakTime: json['breakTime'],
      breakImage: json['breakImage'],
      returnTime: json['returnTime'],
      returnImage: json['returnImage'],
      checkOutTime: json['checkOutTime'],
      checkOutImage: json['checkOutImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime,
      'checkInImage': checkInImage,
      'breakTime': breakTime,
      'breakImage': breakImage,
      'returnTime': returnTime,
      'returnImage': returnImage,
      'checkOutTime': checkOutTime,
      'checkOutImage': checkOutImage,
    };
  }

  Attendance copyWith({
    String? userId,
    DateTime? date,
    String? checkInTime,
    String? checkInImage,
    String? breakTime,
    String? breakImage,
    String? returnTime,
    String? returnImage,
    String? checkOutTime,
    String? checkOutImage,
  }) {
    return Attendance(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkInImage: checkInImage ?? this.checkInImage,
      breakTime: breakTime ?? this.breakTime,
      breakImage: breakImage ?? this.breakImage,
      returnTime: returnTime ?? this.returnTime,
      returnImage: returnImage ?? this.returnImage,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkOutImage: checkOutImage ?? this.checkOutImage,
    );
  }
}
