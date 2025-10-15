import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static const String smtpServer = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const String username = 'your_email@gmail.com'; // Replace with your email
  static const String password = 'your_app_password'; // Use Gmail App Password

  static Future<void> sendInvoice(String userId, String bookingId, double amount) async {
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Sync Event')
      ..recipients.add(userId) // Replace with actual user email from auth
      ..subject = 'Invoice for Booking #$bookingId'
      ..text = 'Thank you for your booking! Amount: ₹$amount. Booking ID: $bookingId';

    try {
      await send(message, smtpServer);
    } catch (e) {
      print('Email sending failed: $e');
    }
  }

  static Future<void> sendCancellationNotice(String userId, String bookingId, double amount) async {
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Sync Event')
      ..recipients.add(userId) // Replace with actual user email from auth
      ..subject = 'Cancellation Notice for Booking #$bookingId'
      ..text = 'Your booking #$bookingId has been cancelled. Refund of ₹$amount initiated.';

    try {
      await send(message, smtpServer);
    } catch (e) {
      print('Email sending failed: $e');
    }
  }
}