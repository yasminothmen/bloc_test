import 'package:bloc_test/data/models/user_profile.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final user_profile user;

  ProfileLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);

  @override
  List<Object> get props => [message];
}
