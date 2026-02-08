import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Taj Azal'**
  String get appTitle;

  /// Welcome text
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authWelcome;

  /// Welcome subtitle text
  ///
  /// In en, this message translates to:
  /// **'to Taj Azal Medical Platform'**
  String get authWelcomeSubtitle;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// Email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailHint;

  /// Password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// Register link text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authNoAccount;

  /// Register link
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get authRegisterNow;

  /// Divider text
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOr;

  /// Register screen title
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get authCreateAccount;

  /// Register screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Fill in the following information to create your account'**
  String get authFillData;

  /// Add profile picture
  ///
  /// In en, this message translates to:
  /// **'Add Profile Picture'**
  String get authAddProfilePicture;

  /// Change picture
  ///
  /// In en, this message translates to:
  /// **'Change Picture'**
  String get authChangePicture;

  /// Name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authName;

  /// Name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authNameHint;

  /// Phone field
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhone;

  /// Phone field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get authPhoneHint;

  /// Registration success message
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Welcome {name}, you can now login'**
  String authRegisterSuccess(String name);

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get authLogout;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get authForgotPassword;

  /// No description provided for @authEnterEmailReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset your password'**
  String get authEnterEmailReset;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPassword;

  /// No description provided for @authSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP Code'**
  String get authSendOtp;

  /// No description provided for @authOtpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get authOtpVerification;

  /// No description provided for @authChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get authChangePassword;

  /// OTP screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to your email'**
  String get authOtpSubtitle;

  /// OTP code field label
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get authOtpCode;

  /// OTP code field hint
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get authOtpCodeHint;

  /// New password field label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get authNewPassword;

  /// New password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter the new password'**
  String get authNewPasswordHint;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Re-enter the new password'**
  String get authConfirmPasswordHint;

  /// Resend OTP link text
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? Resend'**
  String get authResendCode;

  /// Prompt shown with back-to-login link
  ///
  /// In en, this message translates to:
  /// **'Remembered your password?'**
  String get authRememberPassword;

  /// Snackbar text after successful password change
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get authPasswordChangedSuccess;

  /// Snackbar text after resending OTP
  ///
  /// In en, this message translates to:
  /// **'A new verification code has been sent to your email'**
  String get authOtpResent;

  /// Home menu
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Departments menu
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get navDepartments;

  /// Appointments menu
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get navAppointments;

  /// Profile menu
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// User greeting
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get homeGreeting;

  /// Guest name
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get homeGuest;

  /// Search text
  ///
  /// In en, this message translates to:
  /// **'Search for a clinic or health issue...'**
  String get homeSearchHint;

  /// Appointments section title
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get homeMyAppointments;

  /// Departments section title
  ///
  /// In en, this message translates to:
  /// **'Medical Departments'**
  String get homeMedicalDepartments;

  /// See all link
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get homeSeeAll;

  /// No appointments message
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get homeNoUpcomingAppointments;

  /// No departments message
  ///
  /// In en, this message translates to:
  /// **'No departments available'**
  String get homeNoDepartments;

  /// Upcoming appointments tab
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get apptUpcoming;

  /// Past appointments tab
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get apptPast;

  /// Cancelled appointments tab
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get apptCancelled;

  /// Appointment status - Confirmed
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get apptStatusConfirmed;

  /// Appointment status - Pending Confirmation
  ///
  /// In en, this message translates to:
  /// **'Pending Confirmation'**
  String get apptStatusPendingConfirm;

  /// Appointment status - Completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get apptStatusCompleted;

  /// Appointment status - Cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get apptStatusCancelled;

  /// Appointment status - Pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get apptStatusPending;

  /// Enter session button
  ///
  /// In en, this message translates to:
  /// **'Enter Session'**
  String get apptEnterSession;

  /// Message doctor button
  ///
  /// In en, this message translates to:
  /// **'Message Doctor'**
  String get apptMessageDoctor;

  /// Appointment details button
  ///
  /// In en, this message translates to:
  /// **'Appointment Details'**
  String get apptAppointmentDetails;

  /// View details button
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get apptViewDetails;

  /// Book appointment button
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get apptBookAppointment;

  /// Cancel dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get apptCancelAppointment;

  /// Cancel confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this appointment?'**
  String get apptCancelConfirm;

  /// Cancel reason field
  ///
  /// In en, this message translates to:
  /// **'Cancellation Reason (Optional)'**
  String get apptCancelReason;

  /// Cancel reason hint
  ///
  /// In en, this message translates to:
  /// **'Example: Change of plans'**
  String get apptCancelReasonHint;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get apptBack;

  /// Confirm cancel button
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get apptConfirmCancel;

  /// Cannot cancel message
  ///
  /// In en, this message translates to:
  /// **'Cannot cancel appointment less than 24 hours before'**
  String get apptCannotCancel;

  /// No appointments message
  ///
  /// In en, this message translates to:
  /// **'No appointments'**
  String get apptNoAppointments;

  /// No upcoming appointments message
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get apptNoUpcoming;

  /// No past appointments message
  ///
  /// In en, this message translates to:
  /// **'No past appointments'**
  String get apptNoPast;

  /// No cancelled appointments message
  ///
  /// In en, this message translates to:
  /// **'No cancelled appointments'**
  String get apptNoCancelled;

  /// Unauthorized message
  ///
  /// In en, this message translates to:
  /// **'Unauthorized - Please login'**
  String get apptUnauthorized;

  /// Departments screen title
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get deptDepartments;

  /// No departments message
  ///
  /// In en, this message translates to:
  /// **'No departments available'**
  String get deptNoDepartments;

  /// Doctors section title
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get deptDoctors;

  /// Services section title
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get deptServices;

  /// Working hours title
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get deptWorkingHours;

  /// Search hint in departments
  ///
  /// In en, this message translates to:
  /// **'Search for a medical specialty...'**
  String get deptSearchHint;

  /// Search results count
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String deptResultsCount(int count);

  /// Loading departments message
  ///
  /// In en, this message translates to:
  /// **'Loading departments...'**
  String get deptLoading;

  /// Error loading departments message
  ///
  /// In en, this message translates to:
  /// **'Error loading departments'**
  String get deptLoadError;

  /// Try again text
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get deptTryAgain;

  /// No search results
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get deptNoResults;

  /// Try searching with other words
  ///
  /// In en, this message translates to:
  /// **'Try searching with other words'**
  String get deptTryOtherWords;

  /// Location not available
  ///
  /// In en, this message translates to:
  /// **'Location not available'**
  String get deptLocationNotAvailable;

  /// Departments will be added soon
  ///
  /// In en, this message translates to:
  /// **'Departments will be added soon'**
  String get deptWillBeAddedSoon;

  /// No services message
  ///
  /// In en, this message translates to:
  /// **'No services available at the moment'**
  String get deptNoServices;

  /// Doctors screen title
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get docDoctors;

  /// No doctors message
  ///
  /// In en, this message translates to:
  /// **'No doctors available'**
  String get docNoDoctors;

  /// Specialization
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get docSpecialization;

  /// Years of experience
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get docExperience;

  /// Rating
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get docRating;

  /// Book button
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get docBook;

  /// Doctor years of experience
  ///
  /// In en, this message translates to:
  /// **'{years} years of experience'**
  String docYearsExperience(int years);

  /// Default doctor text
  ///
  /// In en, this message translates to:
  /// **'Specialist Doctor'**
  String get docSpecialist;

  /// Search hint in doctors
  ///
  /// In en, this message translates to:
  /// **'Search for a doctor...'**
  String get docSearchHint;

  /// Loading doctors message
  ///
  /// In en, this message translates to:
  /// **'Loading doctors...'**
  String get docLoading;

  /// Error loading doctors message
  ///
  /// In en, this message translates to:
  /// **'Error loading doctors'**
  String get docLoadError;

  /// Try other words message
  ///
  /// In en, this message translates to:
  /// **'Try searching with other words or clear search'**
  String get docTryOtherWords;

  /// Doctors will be added soon
  ///
  /// In en, this message translates to:
  /// **'Doctors will be added soon'**
  String get docWillBeAddedSoon;

  /// Clear search button
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get docClearSearch;

  /// Search results count
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String docResultsCount(int count);

  /// Profile title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profProfile;

  /// Edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profEditProfile;

  /// Medical records
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get profMedicalRecords;

  /// Payments
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get profPayments;

  /// Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profSettings;

  /// Help & Support
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profHelpSupport;

  /// Language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profLanguage;

  /// Arabic
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get profArabic;

  /// English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profEnglish;

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'This feature will be available soon'**
  String get profComingSoon;

  /// Personal settings section title
  ///
  /// In en, this message translates to:
  /// **'Personal Settings'**
  String get profPersonalSettings;

  /// General settings section title
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get profGeneralSettings;

  /// Account section title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profAccount;

  /// Data update success message
  ///
  /// In en, this message translates to:
  /// **'Data updated successfully'**
  String get profDataUpdated;

  /// Session expired message
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again'**
  String get profSessionExpired;

  /// Unauthorized message
  ///
  /// In en, this message translates to:
  /// **'Unauthorized - Please log in'**
  String get profUnauthorized;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server. Check your internet connection'**
  String get profConnectionError;

  /// No user data message
  ///
  /// In en, this message translates to:
  /// **'No user data available'**
  String get profNoUserData;

  /// Patient role
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get profPatient;

  /// Appointments in statistics
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get profAppointments;

  /// Sessions in statistics
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get profSessions;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profLogoutConfirm;

  /// Image pick failure message
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get profImagePickFailed;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profProfileUpdated;

  /// Data update failure message
  ///
  /// In en, this message translates to:
  /// **'Failed to update data'**
  String get profUpdateFailed;

  /// Phone number already used error
  ///
  /// In en, this message translates to:
  /// **'Phone number is already in use'**
  String get profPhoneAlreadyUsed;

  /// Name entry error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get profEnterName;

  /// Phone entry error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get profEnterPhone;

  /// Save changes button
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profSaveChanges;

  /// Doctor dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get drDashboard;

  /// Doctor appointments
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get drAppointments;

  /// Doctor schedule
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get drSchedule;

  /// Doctor services
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get drServices;

  /// Reject appointment
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get drReject;

  /// Accept appointment
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get drAccept;

  /// Rejection reason
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get drRejectReason;

  /// Rejection reason hint
  ///
  /// In en, this message translates to:
  /// **'Enter reason'**
  String get drEnterReason;

  /// Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get drCancel;

  /// Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get drSave;

  /// Create medical record
  ///
  /// In en, this message translates to:
  /// **'Create Medical Record'**
  String get drCreateRecord;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get commonError;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// Yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// Appointment details screen title
  ///
  /// In en, this message translates to:
  /// **'Appointment Details'**
  String get apptDetailsTitle;

  /// Appointment status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get apptDetailsStatus;

  /// Doctor
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get apptDetailsDoctor;

  /// Service
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get apptDetailsService;

  /// Date and time
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get apptDetailsDateTime;

  /// Duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get apptDetailsDuration;

  /// Type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get apptDetailsType;

  /// Price
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get apptDetailsPrice;

  /// Payment
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get apptDetailsPayment;

  /// Appointment type - In Person
  ///
  /// In en, this message translates to:
  /// **'In Person'**
  String get apptTypeInPerson;

  /// Appointment type - Video Call
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get apptTypeVideo;

  /// Appointment type - Text Chat
  ///
  /// In en, this message translates to:
  /// **'Text Chat'**
  String get apptTypeChat;

  /// Appointment status - No Show
  ///
  /// In en, this message translates to:
  /// **'No Show'**
  String get apptStatusNoShow;

  /// Appointment status - Rejected
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get apptStatusRejected;

  /// Time remaining
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get apptTimeRemaining;

  /// Time ongoing
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get apptTimeOngoing;

  /// Time finished
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get apptTimeFinished;

  /// Morning
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get apptMorning;

  /// Evening
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get apptEvening;

  /// Unauthorized for doctor
  ///
  /// In en, this message translates to:
  /// **'Unauthorized - You must be a doctor'**
  String get apptUnauthorizedDoctor;

  /// Records can only be created for completed appointments
  ///
  /// In en, this message translates to:
  /// **'Medical records can only be created for completed appointments'**
  String get apptOnlyCompleted;

  /// Medical record created
  ///
  /// In en, this message translates to:
  /// **'Medical record created successfully'**
  String get apptRecordCreated;

  /// Select doctor first message
  ///
  /// In en, this message translates to:
  /// **'Please select a doctor first'**
  String get apptSelectDoctorFirst;

  /// Select service first message
  ///
  /// In en, this message translates to:
  /// **'Please select a service first'**
  String get apptSelectServiceFirst;

  /// Select date and time message
  ///
  /// In en, this message translates to:
  /// **'Please select a date and available time slot'**
  String get apptSelectDateAndSlot;

  /// Select future time message
  ///
  /// In en, this message translates to:
  /// **'Please select a time in the future'**
  String get apptSelectFutureTime;

  /// Booking success message
  ///
  /// In en, this message translates to:
  /// **'Appointment booked successfully'**
  String get apptBookSuccess;

  /// Booking and confirmation success message
  ///
  /// In en, this message translates to:
  /// **'Appointment booked and confirmed successfully ✓'**
  String get apptBookConfirmSuccess;

  /// Booking pending confirmation message
  ///
  /// In en, this message translates to:
  /// **'Appointment booked successfully. It will be confirmed by the doctor.'**
  String get apptBookPendingConfirm;

  /// Appointment type title
  ///
  /// In en, this message translates to:
  /// **'Appointment Type'**
  String get apptTypeTitle;

  /// Date title
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get apptDateTitle;

  /// Select date text
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get apptSelectDate;

  /// Select date help text
  ///
  /// In en, this message translates to:
  /// **'Select appointment date'**
  String get apptSelectDateHelp;

  /// Select time title
  ///
  /// In en, this message translates to:
  /// **'Select a time from available slots'**
  String get apptSelectTimeTitle;

  /// No slots available message
  ///
  /// In en, this message translates to:
  /// **'No slots available on this day. Please select another date.'**
  String get apptNoSlotsAvailable;

  /// Select doctor warning
  ///
  /// In en, this message translates to:
  /// **'Please select a doctor first before booking'**
  String get apptSelectDoctorWarning;

  /// Select doctor button
  ///
  /// In en, this message translates to:
  /// **'Select Doctor'**
  String get apptSelectDoctor;

  /// Doctor text
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get apptDoctor;

  /// Doctor not selected text
  ///
  /// In en, this message translates to:
  /// **'Doctor not selected'**
  String get apptDoctorNotSelected;

  /// Change doctor button
  ///
  /// In en, this message translates to:
  /// **'Change Doctor'**
  String get apptChangeDoctor;

  /// Service/Specialty text
  ///
  /// In en, this message translates to:
  /// **'Service / Specialty'**
  String get apptServiceSpecialty;

  /// Booking message
  ///
  /// In en, this message translates to:
  /// **'Booking...'**
  String get apptBooking;

  /// Booking and confirming message
  ///
  /// In en, this message translates to:
  /// **'Booking and confirming...'**
  String get apptBookingConfirming;

  /// Select available time message
  ///
  /// In en, this message translates to:
  /// **'Select an available time'**
  String get apptSelectAvailableTime;

  /// Book confirmed test button
  ///
  /// In en, this message translates to:
  /// **'Book Confirmed (Test) ✓'**
  String get apptBookConfirmedTest;

  /// Test mode doctor message
  ///
  /// In en, this message translates to:
  /// **'Test Mode: Instant confirmed booking (as doctor)'**
  String get apptTestModeDoctor;

  /// Test mode patient message
  ///
  /// In en, this message translates to:
  /// **'Test Mode: Booking will need doctor confirmation'**
  String get apptTestModePatient;

  /// Minimum minutes message
  ///
  /// In en, this message translates to:
  /// **'Please select a time at least {minutes} minutes from now'**
  String apptMinimumMinutes(int minutes);

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String apptError(String error);

  /// Booking success with doctor login request
  ///
  /// In en, this message translates to:
  /// **'⚠️ Booking successful. Please login as doctor to confirm automatically, or it will be confirmed manually by the doctor.'**
  String get apptBookSuccessDoctorLogin;

  /// Booking success with confirmation failure
  ///
  /// In en, this message translates to:
  /// **'Booking successful, but automatic confirmation failed: {error}'**
  String apptBookSuccessConfirmFailed(String error);

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get supportTitle;

  /// No description provided for @supportNewTicket.
  ///
  /// In en, this message translates to:
  /// **'New Ticket'**
  String get supportNewTicket;

  /// No description provided for @supportNoTickets.
  ///
  /// In en, this message translates to:
  /// **'No support tickets currently'**
  String get supportNoTickets;

  /// No description provided for @supportCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Ticket'**
  String get supportCreateTitle;

  /// No description provided for @supportCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get supportCategory;

  /// No description provided for @supportSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get supportSubject;

  /// No description provided for @supportDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get supportDescription;

  /// No description provided for @supportSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the subject'**
  String get supportSubjectRequired;

  /// No description provided for @supportDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the description'**
  String get supportDescriptionRequired;

  /// No description provided for @supportSend.
  ///
  /// In en, this message translates to:
  /// **'Send Ticket'**
  String get supportSend;

  /// No description provided for @supportCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ticket created successfully'**
  String get supportCreateSuccess;

  /// No description provided for @supportDetails.
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get supportDetails;

  /// No description provided for @supportOriginalTicket.
  ///
  /// In en, this message translates to:
  /// **'Original Ticket'**
  String get supportOriginalTicket;

  /// No description provided for @supportReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write your reply here...'**
  String get supportReplyHint;

  /// No description provided for @supportStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get supportStatusOpen;

  /// No description provided for @supportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get supportStatusInProgress;

  /// No description provided for @supportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get supportStatusResolved;

  /// No description provided for @supportStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get supportStatusClosed;

  /// No description provided for @supportCatTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical Issue'**
  String get supportCatTechnical;

  /// No description provided for @supportCatBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing Issue'**
  String get supportCatBilling;

  /// No description provided for @supportCatMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical Inquiry'**
  String get supportCatMedical;

  /// No description provided for @supportCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get supportCatOther;

  /// Payment required alert message
  ///
  /// In en, this message translates to:
  /// **'Please complete payment to confirm booking'**
  String get apptPaymentRequired;

  /// Payment screen title
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// Payment required message
  ///
  /// In en, this message translates to:
  /// **'Payment required to confirm booking'**
  String get paymentRequired;

  /// Complete payment message
  ///
  /// In en, this message translates to:
  /// **'Complete payment to confirm your booking'**
  String get paymentCompleteToConfirm;

  /// Payment details title
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// Amount
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentAmount;

  /// Payment status
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// Payment status - Pending
  ///
  /// In en, this message translates to:
  /// **'Pending Payment'**
  String get paymentStatusPending;

  /// Payment status - Completed
  ///
  /// In en, this message translates to:
  /// **'Payment Completed'**
  String get paymentStatusCompleted;

  /// Payment status - Failed
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentStatusFailed;

  /// Pay now button
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get paymentPayNow;

  /// Processing message
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get paymentProcessing;

  /// Payment success message
  ///
  /// In en, this message translates to:
  /// **'Payment successful! Your booking is confirmed'**
  String get paymentSuccess;

  /// Payment cancelled message
  ///
  /// In en, this message translates to:
  /// **'Payment was cancelled'**
  String get paymentCancelled;

  /// Payment error message
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again'**
  String get paymentError;

  /// Reservation expiry warning
  ///
  /// In en, this message translates to:
  /// **'Note: Reservation will expire if payment is not completed within 15 minutes'**
  String get paymentReservationExpiry;

  /// Notifications page title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// Message when there are no notifications
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get notificationsEmpty;

  /// Description for no notifications message
  ///
  /// In en, this message translates to:
  /// **'Your notifications will appear here'**
  String get notificationsEmptyDescription;

  /// Button to mark all notifications as read
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get notificationsMarkAllRead;

  /// Button to clear all notifications
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get notificationsClearAll;

  /// Button to delete a notification
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notificationsDelete;

  /// Notification time - just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationsJustNow;

  /// Notification time - minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String notificationsMinutesAgo(int count);

  /// Notification time - hours ago
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String notificationsHoursAgo(int count);

  /// Notification time - days ago
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String notificationsDaysAgo(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
