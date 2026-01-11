import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/features/auth/data/firebase_auth_datasource.dart';
import 'package:lotex/features/auth/data/auth_repository_impl.dart';
import 'package:lotex/features/auth/domain/auth_repository.dart';
import 'package:lotex/features/auth/domain/entities/user_entity.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
	return AuthRepositoryImpl(
		FirebaseAuthDatasource(FirebaseAuth.instance),
		FirebaseFirestore.instance,
	);
});

final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
	final repo = ref.watch(authRepositoryProvider);
	return repo.authStateChanges();
});

final currentUserProvider = Provider<UserEntity?>((ref) {
	return ref.watch(authStateChangesProvider).valueOrNull;
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
	late final AuthRepository _repository;

	@override
	void build() {
		_repository = ref.read(authRepositoryProvider);
	}

	Future<void> signIn({required String email, required String password}) async {
		state = const AsyncValue.loading();
		try {
			await _repository.signIn(email: email, password: password);
			state = const AsyncValue.data(null);
		} catch (e, st) {
			state = AsyncValue.error(e, st);
			rethrow;
		}
	}

	Future<void> signUp({required String email, required String password}) async {
		state = const AsyncValue.loading();
		try {
			await _repository.signUp(email: email, password: password);
			state = const AsyncValue.data(null);
		} catch (e, st) {
			state = AsyncValue.error(e, st);
			rethrow;
		}
	}

	Future<void> signOut() async {
		state = const AsyncValue.loading();
		try {
			await _repository.signOut();
			state = const AsyncValue.data(null);
		} catch (e, st) {
			state = AsyncValue.error(e, st);
			rethrow;
		}
	}

	Future<void> signInWithGoogle() async {
		state = const AsyncValue.loading();
		try {
			await _repository.signInWithGoogle();
			state = const AsyncValue.data(null);
		} catch (e, st) {
			state = AsyncValue.error(e, st);
			rethrow;
		}
	}

	Future<void> signInWithApple() async {
		state = const AsyncValue.loading();
		try {
			await _repository.signInWithApple();
			state = const AsyncValue.data(null);
		} catch (e, st) {
			state = AsyncValue.error(e, st);
			rethrow;
		}
	}
}