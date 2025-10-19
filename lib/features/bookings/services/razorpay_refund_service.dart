// Create new file: lib/features/bookings/services/razorpay_refund_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RazorpayRefundService {
  final FirebaseFirestore firestore;

  RazorpayRefundService({required this.firestore});

  /// Create a refund record for bank transfers
  /// Note: Actual Razorpay API integration would go here
  Future<void> createBankRefund({
    required String userId,
    required String bookingId,
    required String paymentId,
    required double amount,
    required String cancellationReason,
  }) async {
    try {
      print('RazorpayRefundService: Creating bank refund record');
      print('  Payment ID: $paymentId');
      print('  Amount: ₹$amount');
      print('  Reason: $cancellationReason');

      // Create a refund record in Firestore for admin to process
      final refundRecord = {
        'bookingId': bookingId,
        'userId': userId,
        'paymentId': paymentId,
        'amount': amount,
        'refundType': 'bank',
        'status': 'pending', // admin will change to 'processed'
        'cancellationReason': cancellationReason,
        'createdAt': FieldValue.serverTimestamp(),
        'processedAt': null,
        'razorpayRefundId': null, // Will be filled when admin processes
      };

      // Save to refunds collection
      await firestore
          .collection('refunds')
          .doc(bookingId)
          .set(refundRecord);

      print('✓ Bank refund record created: $bookingId');

      // TODO: When you have Razorpay API credentials, implement actual refund:
      // final refund = await _razorpayClient.payments.refund(
      //   paymentId,
      //   RazorpayRefundRequest(
      //     amount: (amount * 100).toInt(), // Razorpay uses paise
      //     notes: {
      //       'bookingId': bookingId,
      //       'userId': userId,
      //       'reason': cancellationReason,
      //     },
      //   ),
      // );
      //
      // Update the refund record with Razorpay response
      // await firestore.collection('refunds').doc(bookingId).update({
      //   'razorpayRefundId': refund.id,
      //   'status': 'processed',
      //   'processedAt': FieldValue.serverTimestamp(),
      // });
    } catch (e) {
      print('✗ Error creating bank refund: $e');
      rethrow;
    }
  }

  /// Get refund status (for user to check)
  Future<Map<String, dynamic>?> getRefundStatus(String bookingId) async {
    try {
      final doc = await firestore.collection('refunds').doc(bookingId).get();
      return doc.data();
    } catch (e) {
      print('Error fetching refund status: $e');
      return null;
    }
  }
}