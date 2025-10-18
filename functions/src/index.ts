import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";

admin.initializeApp();

// Use environment variables for Gmail credentials
const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_APP_PASSWORD,
    },
});

export const sendBookingConfirmationEmail = onDocumentCreated(
  { document: "bookings/{bookingId}" },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const bookingData = snap.data();
    const userEmail = bookingData.userEmail;// Make sure your booking doc stores userEmail
        const amount = bookingData.totalAmount;
        const bookingId = event.params.bookingId;

        if (!userEmail) {
            logger.error("Booking has no userEmail");
            return;
        }

        const mailOptions = {
            from: `"Sync Event" <${process.env.GMAIL_USER}>`,
            to: userEmail,
            subject: `Booking Confirmation - ${bookingId}`,
            text: `Thank you for your booking!\nBooking ID: ${bookingId}\nAmount: ₹${amount}\nEnjoy your event!`,
        };

        try {
            await transporter.sendMail(mailOptions);
            logger.info(`Booking confirmation email sent to ${userEmail}`);
        } catch (error) {
            logger.error("Failed to send email", error);
        }
    }
);
