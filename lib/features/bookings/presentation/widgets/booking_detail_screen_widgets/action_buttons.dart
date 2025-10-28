import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/utils/invoice_generator.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

// Widget for action buttons (Invoice and Back)
class ActionButtons extends StatelessWidget {
  final BookingEntity booking;
  final EventEntity event;

  const ActionButtons({super.key, required this.booking, required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);

    // Build action buttons row
    return Row(
      children: [
        // Back button
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightLarge,
            child: OutlinedButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/root'),
              style: Theme.of(context).outlinedButtonTheme.style,
              child: Text(
                'Back',
                style: AppTextStyles.labelMedium(
                  isDark: isDark,
                ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.spacingMedium),
        // Invoice button
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightLarge,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  final bytes = await InvoiceGenerator.generate(booking, event);
                  await Printing.layoutPdf(
                    onLayout: (_) async => bytes,
                    name: 'Invoice_${booking.id}.pdf',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error generating invoice: $e',
                        style: AppTextStyles.bodyMedium(
                          isDark: true,
                        ).copyWith(color: Colors.white),
                      ),
                      backgroundColor: AppColors.getError(isDark),
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Invoice'),
              style: Theme.of(context).elevatedButtonTheme.style,
            ),
          ),
        ),
      ],
    );
  }
}
