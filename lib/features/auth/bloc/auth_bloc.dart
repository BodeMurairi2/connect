import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connect/repositories/auth_repository.dart';
import 'package:connect/repositories/startup_repository.dart';
import 'package:connect/repositories/student_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _auth = AuthService();

  AuthBloc() : super(AuthInitial()) {
    on<LoginWithEmailRequested>(_onLoginWithEmail);
    on<RegisterWithEmailRequested>(_onRegisterWithEmail);
    on<GoogleSignInRequested>(_onGoogleSignIn);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential =
          await _auth.signInWithEmail(event.email, event.password);
      final uid = credential.user!.uid;
      if (await _auth.isAdmin(uid)) {
        emit(AuthSuccess('admin'));
        return;
      }
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();
      final role = userDoc.data()?['role'] as String? ?? 'student';
      if (role == 'startup') {
        final hasProfile =
            await StartupRepository().hasCompletedOnboarding(uid);
        emit(AuthSuccess(hasProfile ? 'startup' : 'onboarding/startup'));
      } else {
        final hasProfile =
            await StudentRepository().hasCompletedOnboarding(uid);
        emit(AuthSuccess(hasProfile ? 'student' : 'onboarding/student'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Login failed'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential =
          await _auth.registerWithEmail(event.email, event.password);
      await _auth.saveUserToFirestore(
        uid: credential.user!.uid,
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        role: event.role,
      );
      await _auth.sendEmailVerification();
      emit(AuthSuccess('login'));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Registration failed'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _auth.signInWithGoogle();
      final uid = credential.user!.uid;
      if (event.isRegister) {
        await _auth.saveUserToFirestore(
          uid: uid,
          firstName:
              credential.user!.displayName?.split(' ').first ?? '',
          lastName:
              credential.user!.displayName?.split(' ').last ?? '',
          email: credential.user!.email ?? '',
          role: event.role,
        );
        emit(AuthSuccess(
          event.role == 'startup'
              ? 'onboarding/startup'
              : 'onboarding/student',
        ));
      } else {
        if (event.role == 'startup') {
          final hasProfile =
              await StartupRepository().hasCompletedOnboarding(uid);
          emit(AuthSuccess(hasProfile ? 'startup' : 'onboarding/startup'));
        } else {
          final hasProfile =
              await StudentRepository().hasCompletedOnboarding(uid);
          emit(AuthSuccess(hasProfile ? 'student' : 'onboarding/student'));
        }
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
