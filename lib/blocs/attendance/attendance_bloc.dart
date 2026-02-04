import 'package:flutter_bloc/flutter_bloc.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc() : super(AttendanceInitial()) {
    on<CheckInRequested>(_onCheckInRequested);
    on<BreakTimeRequested>(_onBreakTimeRequested);
    on<ReturnToWorkRequested>(_onReturnToWorkRequested);
    on<CheckOutRequested>(_onCheckOutRequested);
  }

  Future<void> _onCheckInRequested(
    CheckInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    // Logic for check in - for now just emit success
    // Actual face scan and saving is handled in FaceScanScreen
    emit(const AttendanceSuccess('Check In'));
  }

  Future<void> _onBreakTimeRequested(
    BreakTimeRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    emit(const AttendanceSuccess('Break Time'));
  }

  Future<void> _onReturnToWorkRequested(
    ReturnToWorkRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    emit(const AttendanceSuccess('Return to Work'));
  }

  Future<void> _onCheckOutRequested(
    CheckOutRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    emit(const AttendanceSuccess('Check Out'));
  }
}
