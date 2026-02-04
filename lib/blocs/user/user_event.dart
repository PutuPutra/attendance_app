import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUsers extends UserEvent {}

class AddUser extends UserEvent {
  final User user;

  const AddUser(this.user);

  @override
  List<Object> get props => [user];
}

class UpdateUser extends UserEvent {
  final String id;
  final User user;

  const UpdateUser(this.id, this.user);

  @override
  List<Object> get props => [id, user];
}

class DeleteUser extends UserEvent {
  final String id;

  const DeleteUser(this.id);

  @override
  List<Object> get props => [id];
}

class ChangePassword extends UserEvent {
  final String userId;
  final String newPassword;

  const ChangePassword(this.userId, this.newPassword);

  @override
  List<Object> get props => [userId, newPassword];
}
