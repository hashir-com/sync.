import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class InvoiceGenerator {
  static Future<Uint8List> generate(BookingEntity booking, EventEntity event) async {
    final pdf = pw.Document();
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Sync Event', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Invoice', style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 24),
                pw.Text('Booking ID: ${booking.id}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Date: ${DateFormat('MMM d, y h:mm a').format(booking.bookingDate)}', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 16),
                pw.Text('Event', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(event.title),
                pw.Text(event.location),
                pw.Text('${DateFormat('EEE, MMM d y').format(event.startTime)} · ${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}'),
                pw.SizedBox(height: 16),
                pw.Container(
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                  child: pw.Table(
                    border: pw.TableBorder.symmetric(outside: pw.BorderSide.none, inside: const pw.BorderSide(color: PdfColors.grey300)),
                    columnWidths: const {
                      0: pw.FlexColumnWidth(3),
                      1: pw.FlexColumnWidth(1),
                      2: pw.FlexColumnWidth(2),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Item')),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Qty')),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Amount', textAlign: pw.TextAlign.right)),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${booking.ticketType.toUpperCase()} Ticket')),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${booking.ticketQuantity}')),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(currency.format(booking.totalAmount), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 240,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text(currency.format(booking.totalAmount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text('Payment ID: ${booking.paymentId}', style: const pw.TextStyle(fontSize: 12)),
                if (booking.seatNumbers.isNotEmpty)
                  pw.Text('Seats: ${booking.seatNumbers.join(', ')}', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 24),
                pw.Text('Thank you for choosing Sync Event!', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
