abstract class AuthEvent {}

class LoginWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String role;
  LoginWithEmailRequested({
    required this.email,
    required this.password,
    required this.role,
  });
}

class RegisterWithEmailRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;
  RegisterWithEmailRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
  });
}

class GoogleSignInRequested extends AuthEvent {
  final String role;
  final bool isRegister;
  GoogleSignInRequested({required this.role, this.isRegister = false});
}
