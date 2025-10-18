// lib/features/email/services/email_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static const String smtpServer = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const String username =
      'ashirhash111@gmail.com'; // Replace with your email
  static const String password =
      'ncwv klod kdvy cgiz'; // Replace with your app password

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
          'Thank you for your booking!\n\n'
          'Booking ID: $bookingId\n'
          'Amount Paid: ₹$amount\n\n'
          'We hope you enjoy the event!';

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
}
