// lib/features/email/services/email_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static const String smtpServer = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const String username = 'ashirhash111@gmail.com';
  static const String password = 'ncwv klod kdvy cgiz'; //app password

  static Future<String?> _getUserEmail(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.data()?['email'] as String?;
      }
      return null;
    } catch (e) {
      print('Failed to fetch user email: $e');
      return null;
    }
  }

  static Future<void> sendInvoice(
    String userId,
    String bookingId,
    double amount,
    String email,
  ) async {
    final userEmail = await _getUserEmail(userId);
    if (userEmail == null) {
      print('User email not found for userId: $userId');
      return;
    }

    final smtp = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Sync Event')
      ..recipients.add(userEmail)
      ..subject = 'Invoice for Booking #$bookingId'
      ..text =
          'Thank you for booking with Sync Event!\n\n'
          'We are pleased to confirm your booking.\n\n'
          'Booking Details:\n'
          'Booking ID: $bookingId\n'
          'Amount Paid: ₹$amount\n\n'
          'We look forward to seeing you at the event. '
          'For any questions or assistance, feel free to contact our support team support@sync-event.com.\n\n'
          'Best regards,\n'
          'Sync Event Team';

    try {
      await send(message, smtp);
      print('Invoice email sent to $userEmail');
    } catch (e) {
      print('Email sending failed: $e');
    }
  }

  static Future<void> sendCancellationNotice(
    String userId,
    String bookingId,
    double amount,
  ) async {
    final userEmail = await _getUserEmail(userId);
    if (userEmail == null) {
      print('User email not found for userId: $userId');
      return;
    }

    final smtp = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Sync Event')
      ..recipients.add(userEmail)
      ..subject = 'Cancellation Notice for Booking #$bookingId'
      ..text =
          'Your booking #$bookingId has been cancelled.\n'
          'Refund of ₹$amount has been initiated.\n\n'
          'We hope to see you at other events!';

    try {
      await send(message, smtp);
      print('Cancellation email sent to $userEmail');
    } catch (e) {
      print('Email sending failed: $e');
    }
  }

  /// Send detailed cancellation email with refund information
  static Future<void> sendDetailedCancellationEmail({
    required String userId,
    required String bookingId,
    required String eventTitle,
    required double refundAmount,
    required String refundType,
    required String cancellationReason,
  }) async {
    try {
      print('📧 EmailService: Sending detailed cancellation email');
      print('   userId: $userId');
      print('   bookingId: $bookingId');
      print('   refundType: $refundType');
      print('   refundAmount: ₹$refundAmount');

      final userEmail = await _getUserEmail(userId);
      if (userEmail == null) {
        print(' User email not found for userId: $userId');
        return;
      }

      final smtp = gmail(username, password);

      // Format refund details based on type
      final refundDetails = refundType == 'wallet'
          ? 'Your refund of ₹$refundAmount has been instantly credited to your Sync Event wallet.'
          : 'Your refund of ₹$refundAmount will be processed to your bank account within 5-7 business days.';

      final emailBody =
          '''
Dear User,

We confirm that your booking has been successfully cancelled.

CANCELLATION DETAILS

Booking ID: $bookingId
Event: $eventTitle
Cancellation Reason: $cancellationReason

REFUND INFORMATION

Refund Amount: ₹$refundAmount
Refund Method: ${refundType == 'wallet' ? 'Wallet' : 'Bank Transfer'}

$refundDetails

${refundType == 'wallet' ? 'You can use this balance immediately to book other events.' : 'Please allow 5-7 business days for the amount to appear in your bank account. In case of any delay, please contact our support team.'}


If you have any questions or concerns, please feel free to contact us at support@sync-event.com

We hope to see you at future events!

Best regards,
Sync Event Team
''';

      final message = Message()
        ..from = Address(username, 'Sync Event')
        ..recipients.add(userEmail)
        ..subject = 'Booking Cancellation Confirmation - Refund Initiated'
        ..text = emailBody;

      await send(message, smtp);
      print('✓ Detailed cancellation email sent to $userEmail');
    } catch (e) {
      print(' Error sending cancellation email: $e');
      // Don't rethrow - cancellation should succeed even if email fails
    }
  }
}
