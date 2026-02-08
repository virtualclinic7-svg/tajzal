// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Taj Azal';

  @override
  String get authWelcome => 'Welcome';

  @override
  String get authWelcomeSubtitle => 'to Taj Azal Medical Platform';

  @override
  String get authLogin => 'Login';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailHint => 'Enter your email';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authRegisterNow => 'Register Now';

  @override
  String get authOr => 'OR';

  @override
  String get authCreateAccount => 'Create New Account';

  @override
  String get authFillData =>
      'Fill in the following information to create your account';

  @override
  String get authAddProfilePicture => 'Add Profile Picture';

  @override
  String get authChangePicture => 'Change Picture';

  @override
  String get authName => 'Name';

  @override
  String get authNameHint => 'Enter your full name';

  @override
  String get authPhone => 'Phone Number';

  @override
  String get authPhoneHint => 'Enter your phone number';

  @override
  String authRegisterSuccess(String name) {
    return 'Registration successful! Welcome $name, you can now login';
  }

  @override
  String get authLogout => 'Logout';

  @override
  String get authForgotPassword => 'Forgot Password';

  @override
  String get authEnterEmailReset => 'Enter your email to reset your password';

  @override
  String get authResetPassword => 'Reset Password';

  @override
  String get authSendOtp => 'Send OTP Code';

  @override
  String get authOtpVerification => 'OTP Verification';

  @override
  String get authChangePassword => 'Change Password';

  @override
  String get authOtpSubtitle =>
      'Enter the verification code sent to your email';

  @override
  String get authOtpCode => 'Verification Code';

  @override
  String get authOtpCodeHint => 'Enter the 6-digit code';

  @override
  String get authNewPassword => 'New Password';

  @override
  String get authNewPasswordHint => 'Enter the new password';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authConfirmPasswordHint => 'Re-enter the new password';

  @override
  String get authResendCode => 'Didn\'t receive the code? Resend';

  @override
  String get authRememberPassword => 'Remembered your password?';

  @override
  String get authPasswordChangedSuccess => 'Password changed successfully';

  @override
  String get authOtpResent =>
      'A new verification code has been sent to your email';

  @override
  String get navHome => 'Home';

  @override
  String get navDepartments => 'Departments';

  @override
  String get navAppointments => 'Appointments';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGreeting => 'Hello';

  @override
  String get homeGuest => 'Guest';

  @override
  String get homeSearchHint => 'Search for a clinic or health issue...';

  @override
  String get homeMyAppointments => 'My Appointments';

  @override
  String get homeMedicalDepartments => 'Medical Departments';

  @override
  String get homeSeeAll => 'See All';

  @override
  String get homeNoUpcomingAppointments => 'No upcoming appointments';

  @override
  String get homeNoDepartments => 'No departments available';

  @override
  String get apptUpcoming => 'Upcoming';

  @override
  String get apptPast => 'Past';

  @override
  String get apptCancelled => 'Cancelled';

  @override
  String get apptStatusConfirmed => 'Confirmed';

  @override
  String get apptStatusPendingConfirm => 'Pending Confirmation';

  @override
  String get apptStatusCompleted => 'Completed';

  @override
  String get apptStatusCancelled => 'Cancelled';

  @override
  String get apptStatusPending => 'Pending';

  @override
  String get apptEnterSession => 'Enter Session';

  @override
  String get apptMessageDoctor => 'Message Doctor';

  @override
  String get apptAppointmentDetails => 'Appointment Details';

  @override
  String get apptViewDetails => 'View Details';

  @override
  String get apptBookAppointment => 'Book Appointment';

  @override
  String get apptCancelAppointment => 'Cancel Appointment';

  @override
  String get apptCancelConfirm =>
      'Are you sure you want to cancel this appointment?';

  @override
  String get apptCancelReason => 'Cancellation Reason (Optional)';

  @override
  String get apptCancelReasonHint => 'Example: Change of plans';

  @override
  String get apptBack => 'Back';

  @override
  String get apptConfirmCancel => 'Confirm Cancellation';

  @override
  String get apptCannotCancel =>
      'Cannot cancel appointment less than 24 hours before';

  @override
  String get apptNoAppointments => 'No appointments';

  @override
  String get apptNoUpcoming => 'No upcoming appointments';

  @override
  String get apptNoPast => 'No past appointments';

  @override
  String get apptNoCancelled => 'No cancelled appointments';

  @override
  String get apptUnauthorized => 'Unauthorized - Please login';

  @override
  String get deptDepartments => 'Departments';

  @override
  String get deptNoDepartments => 'No departments available';

  @override
  String get deptDoctors => 'Doctors';

  @override
  String get deptServices => 'Services';

  @override
  String get deptWorkingHours => 'Working Hours';

  @override
  String get deptSearchHint => 'Search for a medical specialty...';

  @override
  String deptResultsCount(int count) {
    return '$count results';
  }

  @override
  String get deptLoading => 'Loading departments...';

  @override
  String get deptLoadError => 'Error loading departments';

  @override
  String get deptTryAgain => 'Please try again';

  @override
  String get deptNoResults => 'No search results';

  @override
  String get deptTryOtherWords => 'Try searching with other words';

  @override
  String get deptLocationNotAvailable => 'Location not available';

  @override
  String get deptWillBeAddedSoon => 'Departments will be added soon';

  @override
  String get deptNoServices => 'No services available at the moment';

  @override
  String get docDoctors => 'Doctors';

  @override
  String get docNoDoctors => 'No doctors available';

  @override
  String get docSpecialization => 'Specialization';

  @override
  String get docExperience => 'Years of Experience';

  @override
  String get docRating => 'Rating';

  @override
  String get docBook => 'Book Appointment';

  @override
  String docYearsExperience(int years) {
    return '$years years of experience';
  }

  @override
  String get docSpecialist => 'Specialist Doctor';

  @override
  String get docSearchHint => 'Search for a doctor...';

  @override
  String get docLoading => 'Loading doctors...';

  @override
  String get docLoadError => 'Error loading doctors';

  @override
  String get docTryOtherWords =>
      'Try searching with other words or clear search';

  @override
  String get docWillBeAddedSoon => 'Doctors will be added soon';

  @override
  String get docClearSearch => 'Clear Search';

  @override
  String docResultsCount(int count) {
    return '$count results';
  }

  @override
  String get profProfile => 'Profile';

  @override
  String get profEditProfile => 'Edit Profile';

  @override
  String get profMedicalRecords => 'Medical Records';

  @override
  String get profPayments => 'Payments';

  @override
  String get profSettings => 'Settings';

  @override
  String get profHelpSupport => 'Help & Support';

  @override
  String get profLanguage => 'Language';

  @override
  String get profArabic => 'العربية';

  @override
  String get profEnglish => 'English';

  @override
  String get profComingSoon => 'This feature will be available soon';

  @override
  String get profPersonalSettings => 'Personal Settings';

  @override
  String get profGeneralSettings => 'General Settings';

  @override
  String get profAccount => 'Account';

  @override
  String get profDataUpdated => 'Data updated successfully';

  @override
  String get profSessionExpired => 'Session expired. Please log in again';

  @override
  String get profUnauthorized => 'Unauthorized - Please log in';

  @override
  String get profConnectionError =>
      'Cannot connect to server. Check your internet connection';

  @override
  String get profNoUserData => 'No user data available';

  @override
  String get profPatient => 'Patient';

  @override
  String get profAppointments => 'Appointments';

  @override
  String get profSessions => 'Sessions';

  @override
  String get profLogoutConfirm => 'Are you sure you want to log out?';

  @override
  String get profImagePickFailed => 'Failed to pick image';

  @override
  String get profProfileUpdated => 'Profile updated successfully';

  @override
  String get profUpdateFailed => 'Failed to update data';

  @override
  String get profPhoneAlreadyUsed => 'Phone number is already in use';

  @override
  String get profEnterName => 'Please enter your name';

  @override
  String get profEnterPhone => 'Please enter your phone number';

  @override
  String get profSaveChanges => 'Save Changes';

  @override
  String get drDashboard => 'Dashboard';

  @override
  String get drAppointments => 'Appointments';

  @override
  String get drSchedule => 'Schedule';

  @override
  String get drServices => 'Services';

  @override
  String get drReject => 'Reject';

  @override
  String get drAccept => 'Accept';

  @override
  String get drRejectReason => 'Rejection Reason';

  @override
  String get drEnterReason => 'Enter reason';

  @override
  String get drCancel => 'Cancel';

  @override
  String get drSave => 'Save';

  @override
  String get drCreateRecord => 'Create Medical Record';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'An error occurred';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonOk => 'OK';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get apptDetailsTitle => 'Appointment Details';

  @override
  String get apptDetailsStatus => 'Status';

  @override
  String get apptDetailsDoctor => 'Doctor';

  @override
  String get apptDetailsService => 'Service';

  @override
  String get apptDetailsDateTime => 'Date & Time';

  @override
  String get apptDetailsDuration => 'Duration';

  @override
  String get apptDetailsType => 'Type';

  @override
  String get apptDetailsPrice => 'Price';

  @override
  String get apptDetailsPayment => 'Payment';

  @override
  String get apptTypeInPerson => 'In Person';

  @override
  String get apptTypeVideo => 'Video Call';

  @override
  String get apptTypeChat => 'Text Chat';

  @override
  String get apptStatusNoShow => 'No Show';

  @override
  String get apptStatusRejected => 'Rejected';

  @override
  String get apptTimeRemaining => 'Remaining';

  @override
  String get apptTimeOngoing => 'Ongoing';

  @override
  String get apptTimeFinished => 'Finished';

  @override
  String get apptMorning => 'AM';

  @override
  String get apptEvening => 'PM';

  @override
  String get apptUnauthorizedDoctor => 'Unauthorized - You must be a doctor';

  @override
  String get apptOnlyCompleted =>
      'Medical records can only be created for completed appointments';

  @override
  String get apptRecordCreated => 'Medical record created successfully';

  @override
  String get apptSelectDoctorFirst => 'Please select a doctor first';

  @override
  String get apptSelectServiceFirst => 'Please select a service first';

  @override
  String get apptSelectDateAndSlot =>
      'Please select a date and available time slot';

  @override
  String get apptSelectFutureTime => 'Please select a time in the future';

  @override
  String get apptBookSuccess => 'Appointment booked successfully';

  @override
  String get apptBookConfirmSuccess =>
      'Appointment booked and confirmed successfully ✓';

  @override
  String get apptBookPendingConfirm =>
      'Appointment booked successfully. It will be confirmed by the doctor.';

  @override
  String get apptTypeTitle => 'Appointment Type';

  @override
  String get apptDateTitle => 'Date';

  @override
  String get apptSelectDate => 'Select Date';

  @override
  String get apptSelectDateHelp => 'Select appointment date';

  @override
  String get apptSelectTimeTitle => 'Select a time from available slots';

  @override
  String get apptNoSlotsAvailable =>
      'No slots available on this day. Please select another date.';

  @override
  String get apptSelectDoctorWarning =>
      'Please select a doctor first before booking';

  @override
  String get apptSelectDoctor => 'Select Doctor';

  @override
  String get apptDoctor => 'Doctor';

  @override
  String get apptDoctorNotSelected => 'Doctor not selected';

  @override
  String get apptChangeDoctor => 'Change Doctor';

  @override
  String get apptServiceSpecialty => 'Service / Specialty';

  @override
  String get apptBooking => 'Booking...';

  @override
  String get apptBookingConfirming => 'Booking and confirming...';

  @override
  String get apptSelectAvailableTime => 'Select an available time';

  @override
  String get apptBookConfirmedTest => 'Book Confirmed (Test) ✓';

  @override
  String get apptTestModeDoctor =>
      'Test Mode: Instant confirmed booking (as doctor)';

  @override
  String get apptTestModePatient =>
      'Test Mode: Booking will need doctor confirmation';

  @override
  String apptMinimumMinutes(int minutes) {
    return 'Please select a time at least $minutes minutes from now';
  }

  @override
  String apptError(String error) {
    return 'Error: $error';
  }

  @override
  String get apptBookSuccessDoctorLogin =>
      '⚠️ Booking successful. Please login as doctor to confirm automatically, or it will be confirmed manually by the doctor.';

  @override
  String apptBookSuccessConfirmFailed(String error) {
    return 'Booking successful, but automatic confirmation failed: $error';
  }

  @override
  String get supportTitle => 'Help & Support';

  @override
  String get supportNewTicket => 'New Ticket';

  @override
  String get supportNoTickets => 'No support tickets currently';

  @override
  String get supportCreateTitle => 'Create New Ticket';

  @override
  String get supportCategory => 'Category';

  @override
  String get supportSubject => 'Subject';

  @override
  String get supportDescription => 'Description';

  @override
  String get supportSubjectRequired => 'Please enter the subject';

  @override
  String get supportDescriptionRequired => 'Please enter the description';

  @override
  String get supportSend => 'Send Ticket';

  @override
  String get supportCreateSuccess => 'Ticket created successfully';

  @override
  String get supportDetails => 'Ticket Details';

  @override
  String get supportOriginalTicket => 'Original Ticket';

  @override
  String get supportReplyHint => 'Write your reply here...';

  @override
  String get supportStatusOpen => 'Open';

  @override
  String get supportStatusInProgress => 'In Progress';

  @override
  String get supportStatusResolved => 'Resolved';

  @override
  String get supportStatusClosed => 'Closed';

  @override
  String get supportCatTechnical => 'Technical Issue';

  @override
  String get supportCatBilling => 'Billing Issue';

  @override
  String get supportCatMedical => 'Medical Inquiry';

  @override
  String get supportCatOther => 'Other';

  @override
  String get apptPaymentRequired =>
      'Please complete payment to confirm booking';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentRequired => 'Payment required to confirm booking';

  @override
  String get paymentCompleteToConfirm =>
      'Complete payment to confirm your booking';

  @override
  String get paymentDetails => 'Payment Details';

  @override
  String get paymentAmount => 'Amount';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get paymentStatusPending => 'Pending Payment';

  @override
  String get paymentStatusCompleted => 'Payment Completed';

  @override
  String get paymentStatusFailed => 'Payment Failed';

  @override
  String get paymentPayNow => 'Pay Now';

  @override
  String get paymentProcessing => 'Processing payment...';

  @override
  String get paymentSuccess => 'Payment successful! Your booking is confirmed';

  @override
  String get paymentCancelled => 'Payment was cancelled';

  @override
  String get paymentError => 'Payment failed. Please try again';

  @override
  String get paymentReservationExpiry =>
      'Note: Reservation will expire if payment is not completed within 15 minutes';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No Notifications';

  @override
  String get notificationsEmptyDescription =>
      'Your notifications will appear here';

  @override
  String get notificationsMarkAllRead => 'Mark All as Read';

  @override
  String get notificationsClearAll => 'Clear All';

  @override
  String get notificationsDelete => 'Delete';

  @override
  String get notificationsJustNow => 'Just now';

  @override
  String notificationsMinutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String notificationsHoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String notificationsDaysAgo(int count) {
    return '$count days ago';
  }
}
