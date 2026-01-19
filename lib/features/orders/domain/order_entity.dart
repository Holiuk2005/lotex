import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lotex/core/utils/price_calculator.dart';

class OrderEntity {
  final String id;
  final String? userId;
  final PriceBreakdown breakdown;
  final String senderCityName;
  final String senderCityRef;
  final String receiverCityName;
  final String receiverCityRef;
  final String receiverBranchName;
  final String receiverBranchRef;
  final String senderRef;
  final String receiverRef;
  final String ttn;
  final String status;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.breakdown,
    required this.senderCityName,
    required this.senderCityRef,
    required this.receiverCityName,
    required this.receiverCityRef,
    required this.receiverBranchName,
    required this.receiverBranchRef,
    required this.senderRef,
    required this.receiverRef,
    required this.ttn,
    this.status = 'created',
  });

  Map<String, dynamic> toDocument() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'subtotal': breakdown.subtotal,
      'shippingCost': breakdown.shipping,
      'serviceFee': breakdown.serviceFee,
      // Analytics-friendly fields
      'sellerPayout': breakdown.subtotal,
      'platformRevenue': breakdown.serviceFee,
      'total': breakdown.total,
      'senderCityName': senderCityName,
      'senderCityRef': senderCityRef,
      'receiverCityName': receiverCityName,
      'receiverCityRef': receiverCityRef,
      'receiverBranchName': receiverBranchName,
      'receiverBranchRef': receiverBranchRef,
      'senderRef': senderRef,
      'receiverRef': receiverRef,
      'ttn': ttn,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
