part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignupInfoEntered extends AuthEvent {
  final String name;
  final String email;
  final String password;
  SignupInfoEntered(this.name, this.email, this.password);
  @override
  List<Object?> get props => [name, email, password];
}

class ProfileImageSubmitted extends AuthEvent {
  final Uint8List imageBytes;
  ProfileImageSubmitted(this.imageBytes);
  @override
  List<Object?> get props => [imageBytes];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class ProfileSubmittedWithImage extends AuthEvent {
  final File imageFile;
  ProfileSubmittedWithImage(this.imageFile);
  @override
  List<Object?> get props => [imageFile];
}
