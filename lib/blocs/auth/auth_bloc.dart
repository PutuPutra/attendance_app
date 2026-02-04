import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/user_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserService userService;

  AuthBloc({required this.userService}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await userService.authenticate(
        event.username,
        event.password,
      );
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Invalid username or password'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUnauthenticated());
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final code = await userService.sendResetCode(event.username);
      // For simplicity, just emit success. In real app, might need a separate state.
      emit(const AuthError('Reset code sent. Check your password field.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
