import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AuthEvent {}

class SignUpSubmitted extends AuthEvent {
  SignUpSubmitted(this.email, this.password);
  final String email, password;
}

class LoginSubmitted extends AuthEvent {
  LoginSubmitted(this.email, this.password);
  final String email, password;
}

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  AuthFailure(this.message);
  final String message;
}

String _authMessage(FirebaseAuthException e) => switch (e.code) {
      'email-already-in-use' => 'Email already used.',
      'invalid-email' => 'Email is not valid.',
      'weak-password' => 'Password too weak.',
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' =>
        'Wrong email or password.',
      'user-disabled' => 'This account is disabled.',
      'too-many-requests' => 'Too many tries. Wait and try again.',
      'network-request-failed' => 'No internet.',
      _ => e.message ?? 'Something went wrong.',
    };

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignUpSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(_authMessage(e)));
      }
    });

    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(_authMessage(e)));
      }
    });
  }
}
