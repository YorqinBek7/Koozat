import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription<fb.User?>? _userSub;

  AuthBloc(this._authService) : super(const AuthState()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _userSub?.cancel();
    _userSub = _authService.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final fbUser = event.firebaseUser;
    if (fbUser == null) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        isLoading: false,
      ));
      return;
    }
    final userModel = await _authService.getUserById(fbUser.uid);
    if (userModel == null) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        isLoading: false,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: userModel,
        isLoading: false,
      ));
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _authService.signIn(
        email: event.email,
        password: event.password,
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: _friendlySignInError(e.toString()),
      ));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _authService.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: _friendlySignUpError(e.toString()),
      ));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearError: true));
  }

  String _friendlySignInError(String raw) {
    if (raw.contains('user-not-found') || raw.contains('wrong-password')) {
      return 'Email yoki parol noto\'g\'ri';
    }
    if (raw.contains('invalid-credential')) {
      return 'Email yoki parol noto\'g\'ri';
    }
    if (raw.contains('too-many-requests')) {
      return 'Juda ko\'p urinish. Keyinroq qayta urinib ko\'ring';
    }
    return 'Xatolik yuz berdi. Qaytadan urinib ko\'ring';
  }

  String _friendlySignUpError(String raw) {
    if (raw.contains('email-already-in-use')) {
      return 'Bu email allaqachon ro\'yxatdan o\'tgan';
    }
    if (raw.contains('weak-password')) {
      return 'Parol juda zaif';
    }
    return 'Xatolik yuz berdi. Qaytadan urinib ko\'ring';
  }

  @override
  Future<void> close() {
    _userSub?.cancel();
    return super.close();
  }
}
