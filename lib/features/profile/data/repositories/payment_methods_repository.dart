import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:lotex/features/profile/data/models/payment_method_dto.dart';
import 'package:lotex/features/profile/domain/entities/payment_method_entity.dart';

class PaymentMethodsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  PaymentMethodsRepository({FirebaseFirestore? firestore, FirebaseFunctions? functions})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  Stream<List<PaymentMethodEntity>> watchMyPaymentMethods(String uid) {
    final col = _firestore.collection('users').doc(uid).collection('payment_methods');
    return col
        .orderBy('isDefault', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final dto = PaymentMethodDto.fromJson(d.data());
        return dto.toEntity(d.id);
      }).toList(growable: false);
    });
  }

  Future<Map<String, dynamic>> createSetupIntent() async {
    final callable = _functions.httpsCallable('stripeCreateSetupIntent');
    final res = await callable.call(<String, dynamic>{});
    final data = res.data;
    if (data is! Map) throw Exception('Invalid stripeCreateSetupIntent response');
    return Map<String, dynamic>.from(data);
  }

  Future<void> syncPaymentMethods() async {
    final callable = _functions.httpsCallable('stripeSyncPaymentMethods');
    await callable.call(<String, dynamic>{});
  }

  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    final callable = _functions.httpsCallable('stripeSetDefaultPaymentMethod');
    await callable.call(<String, dynamic>{
      'paymentMethodId': paymentMethodId,
    });
  }

  Future<void> detachPaymentMethod(String paymentMethodId) async {
    final callable = _functions.httpsCallable('stripeDetachPaymentMethod');
    await callable.call(<String, dynamic>{
      'paymentMethodId': paymentMethodId,
    });
  }
}
