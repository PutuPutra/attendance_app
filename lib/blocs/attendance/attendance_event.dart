import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class CheckInRequested extends AttendanceEvent {}

class BreakTimeRequested extends AttendanceEvent {}

class ReturnToWorkRequested extends AttendanceEvent {}

class CheckOutRequested extends AttendanceEvent {}
