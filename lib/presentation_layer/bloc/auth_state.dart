import '../../model/user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class Loading extends AuthState {} 

class Authenticated extends AuthState {
  final AppUser user;
  Authenticated({required this.user});
} 

class UnAuthenticated extends AuthState {
  final String error;

  UnAuthenticated({required this.error});
} 
