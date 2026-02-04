import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/user_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;

  UserBloc({required this.userService}) : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
    on<ChangePassword>(_onChangePassword);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await userService.loadUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onAddUser(AddUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await userService.addUser(event.user);
      final users = await userService.loadUsers();
      emit(UserLoaded(users));
      emit(const UserOperationSuccess('User added successfully'));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await userService.updateUser(event.id, event.user);
      final users = await userService.loadUsers();
      emit(UserLoaded(users));
      emit(const UserOperationSuccess('User updated successfully'));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await userService.deleteUser(event.id);
      final users = await userService.loadUsers();
      emit(UserLoaded(users));
      emit(const UserOperationSuccess('User deleted successfully'));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final success = await userService.changePassword(
        event.userId,
        event.newPassword,
      );
      if (success) {
        emit(const UserOperationSuccess('Password changed successfully'));
      } else {
        emit(const UserError('Failed to change password'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
