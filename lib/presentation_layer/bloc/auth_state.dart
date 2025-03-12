import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class Loading extends AuthState {} // ✅ Loading state

class Authenticated extends AuthState {} // ✅ User is logged in

class UnAuthenticated extends AuthState {} // ✅ User is not logged in
