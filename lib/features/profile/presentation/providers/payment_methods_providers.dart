import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:lotex/core/config/app_config.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:lotex/features/profile/data/repositories/payment_methods_repository.dart';
import 'package:lotex/features/profile/domain/entities/payment_method_entity.dart';

final paymentMethodsRepositoryProvider = Provider<PaymentMethodsRepository>((ref) {
  return PaymentMethodsRepository();
});

final myPaymentMethodsProvider = StreamProvider.autoDispose<List<PaymentMethodEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.read(paymentMethodsRepositoryProvider).watchMyPaymentMethods(user.uid);
});

final paymentMethodsControllerProvider = AsyncNotifierProvider.autoDispose<PaymentMethodsController, void>(
  PaymentMethodsController.new,
);

class PaymentMethodsController extends AutoDisposeAsyncNotifier<void> {
  PaymentMethodsRepository get _repo => ref.read(paymentMethodsRepositoryProvider);

  @override
  Future<void> build() async {
    // No eager work. UI reads myPaymentMethodsProvider for stream.
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.syncPaymentMethods();
    });
  }

  Future<void> addCardWithPaymentSheet() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (kIsWeb) {
        throw Exception('Stripe on web is not configured yet.');
      }

      final pk = AppConfig.stripePublishableKey.trim();
      if (pk.isEmpty) {
        throw Exception('STRIPE_PUBLISHABLE_KEY is not configured.');
      }

      final data = await _repo.createSetupIntent();
      final setupIntentClientSecret = (data['setupIntentClientSecret'] as String?)?.trim() ?? '';
      final customerId = (data['customerId'] as String?)?.trim() ?? '';
      final ephemeralKeySecret = (data['ephemeralKeySecret'] as String?)?.trim() ?? '';

      if (setupIntentClientSecret.isEmpty || customerId.isEmpty || ephemeralKeySecret.isEmpty) {
        throw Exception('Invalid setup intent payload');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: AppConfig.stripeMerchantDisplayName,
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKeySecret,
          setupIntentClientSecret: setupIntentClientSecret,
          applePay: PaymentSheetApplePay(
            merchantCountryCode: 'UA',
          ),
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'UA',
            testEnv: AppConfig.stripeGooglePayTestEnv,
          ),
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // After successful setup, sync saved methods into Firestore.
      await _repo.syncPaymentMethods();
    });
  }

  Future<void> setDefault(String paymentMethodId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.setDefaultPaymentMethod(paymentMethodId);
    });
  }

  Future<void> remove(String paymentMethodId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.detachPaymentMethod(paymentMethodId);
    });
  }
}
