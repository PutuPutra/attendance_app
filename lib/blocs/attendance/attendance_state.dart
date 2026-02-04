import 'package:equatable/equatable.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceSuccess extends AttendanceState {
  final String type;

  const AttendanceSuccess(this.type);

  @override
  List<Object> get props => [type];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object> get props => [message];
}
