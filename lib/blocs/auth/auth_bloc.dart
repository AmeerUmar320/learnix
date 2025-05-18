import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/auth_repository.dart';
import '../../models/user_model.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  String? name;
  String? email;
  String? password;
  Uint8List? imageBytes;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<SignupInfoEntered>((event, emit) {
      name = event.name;
      email = event.email;
      password = event.password;
      emit(AuthInfoEntered());
    });

    on<ProfileImageSubmitted>((event, emit) async {
      imageBytes = event.imageBytes;
      emit(AuthLoading());
      try {
        final user = await authRepository.register(
          name: name!,
          email: email!,
          password: password!,
          imageBytes: imageBytes!,
        );
        // Cache user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', user.name ?? '');
        await prefs.setString('profilePictureUrl', user.profilePictureUrl ?? '');
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.login(
          email: event.email,
          password: event.password,
        );
        // Cache user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', user.name ?? '');
        await prefs.setString('profilePictureUrl', user.profilePictureUrl ?? '');
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<ProfileSubmittedWithImage>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.registerWithProfilePicture(
          name: name!,
          email: email!,
          password: password!,
          imageFile: event.imageFile,
        );
        // Cache user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', user.name ?? '');
        await prefs.setString('profilePictureUrl', user.profilePictureUrl ?? '');
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
