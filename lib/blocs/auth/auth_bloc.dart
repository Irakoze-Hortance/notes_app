import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<User?> _authSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    
    on<AuthSignUp>(_onSignUp);
    on<AuthSignIn>(_onSignIn);
    on<AuthSignOut>(_onSignOut);
    on<AuthCheckStatus>(_onCheckStatus);

    // Listen to auth state changes
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(AuthCheckStatus());
      } else {
        if (state is! AuthUnauthenticated) {
          add(AuthCheckStatus());
        }
      }
    });
  }

  Future<void> _onSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: userCredential.user!));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: userCredential.user!));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
