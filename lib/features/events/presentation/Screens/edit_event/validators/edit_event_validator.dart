class EditEventValidationResult {
  final bool isValid;
  final String? errorMessage;

  EditEventValidationResult({required this.isValid, this.errorMessage});

  factory EditEventValidationResult.valid() {
    return EditEventValidationResult(isValid: true);
  }

  factory EditEventValidationResult.invalid(String message) {
    return EditEventValidationResult(isValid: false, errorMessage: message);
  }
}

class EditEventValidator {
  static EditEventValidationResult validateTitle(String title) {
    if (title.trim().isEmpty) {
      return EditEventValidationResult.invalid('Please enter event title');
    }
    return EditEventValidationResult.valid();
  }

  static EditEventValidationResult validateDescription(String description) {
    if (description.trim().isEmpty) {
      return EditEventValidationResult.invalid('Please add event description');
    }
    return EditEventValidationResult.valid();
  }

  static EditEventValidationResult validateCoverImage(
    bool hasNewImage,
    bool hasExistingImage,
  ) {
    if (!hasNewImage && !hasExistingImage) {
      return EditEventValidationResult.invalid('Please select a cover image');
    }
    return EditEventValidationResult.valid();
  }

  static EditEventValidationResult validateLocation(
    String location,
    double? latitude,
    double? longitude,
  ) {
    if (location.isEmpty || latitude == null || longitude == null) {
      return EditEventValidationResult.invalid('Please select event location');
    }
    return EditEventValidationResult.valid();
  }

  static EditEventValidationResult validateDateTime(
    DateTime? startTime,
    DateTime? endTime,
  ) {
    if (startTime == null || endTime == null) {
      return EditEventValidationResult.invalid(
        'Please select start and end time',
      );
    }
    if (endTime.isBefore(startTime)) {
      return EditEventValidationResult.invalid(
        'End time must be after start time',
      );
    }
    return EditEventValidationResult.valid();
  }

  static EditEventValidationResult validateMaxAttendees(
    int maxAttendees,
    int currentAttendees,
  ) {
    if (maxAttendees < currentAttendees) {
      return EditEventValidationResult.invalid(
        'Max attendees must be at least $currentAttendees',
      );
    }
    return EditEventValidationResult.valid();
  }

  static EditEventValidationResult validateTicketPrice(double? price) {
    if (price == null || price < 0) {
      return EditEventValidationResult.invalid(
        'Ticket price must be 0 or greater',
      );
    }
    return EditEventValidationResult.valid();
  }

  static EditEventValidationResult validateCategory(String category) {
    if (category.trim().isEmpty) {
      return EditEventValidationResult.invalid('Please select event type');
    }
    return EditEventValidationResult.valid();
  }
}