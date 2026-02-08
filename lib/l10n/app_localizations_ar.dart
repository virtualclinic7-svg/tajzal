// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تاج ازال';

  @override
  String get authWelcome => 'مرحباً بك';

  @override
  String get authWelcomeSubtitle => 'في منصة تاج ازال الطبية';

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authPasswordHint => 'أدخل كلمة المرور';

  @override
  String get authNoAccount => 'ليس لديك حساب؟ ';

  @override
  String get authRegisterNow => 'سجل الآن';

  @override
  String get authOr => 'أو';

  @override
  String get authCreateAccount => 'إنشاء حساب جديد';

  @override
  String get authFillData => 'املأ البيانات التالية لإنشاء حسابك';

  @override
  String get authAddProfilePicture => 'إضافة صورة شخصية';

  @override
  String get authChangePicture => 'تغيير الصورة';

  @override
  String get authName => 'الاسم';

  @override
  String get authNameHint => 'أدخل اسمك الكامل';

  @override
  String get authPhone => 'رقم الهاتف';

  @override
  String get authPhoneHint => 'أدخل رقم هاتفك';

  @override
  String authRegisterSuccess(String name) {
    return 'تم التسجيل بنجاح! مرحباً $name، يمكنك تسجيل الدخول الآن';
  }

  @override
  String get authLogout => 'تسجيل الخروج';

  @override
  String get authForgotPassword => 'نسيت كلمة السر';

  @override
  String get authEnterEmailReset =>
      'أدخل بريدك الإلكتروني لإعادة تعيين كلمة السر';

  @override
  String get authResetPassword => 'إعادة تعيين كلمة السر';

  @override
  String get authSendOtp => 'إرسال رمز التحقق';

  @override
  String get authOtpVerification => 'رمز التحقق';

  @override
  String get authChangePassword => 'تغيير كلمة السر';

  @override
  String get authOtpSubtitle => 'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني';

  @override
  String get authOtpCode => 'رمز التحقق';

  @override
  String get authOtpCodeHint => 'أدخل رمز الـ 6 أرقام';

  @override
  String get authNewPassword => 'كلمة السر الجديدة';

  @override
  String get authNewPasswordHint => 'أدخل كلمة السر الجديدة';

  @override
  String get authConfirmPassword => 'تأكيد كلمة السر';

  @override
  String get authConfirmPasswordHint => 'أعد إدخال كلمة السر الجديدة';

  @override
  String get authResendCode => 'لم يصلك رمز التحقق؟ إعادة الإرسال';

  @override
  String get authRememberPassword => 'تذكرت كلمة السر؟';

  @override
  String get authPasswordChangedSuccess => 'تم تغيير كلمة السر بنجاح';

  @override
  String get authOtpResent => 'تم إرسال رمز تحقق جديد إلى بريدك الإلكتروني';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navDepartments => 'التخصصات';

  @override
  String get navAppointments => 'المواعيد';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get homeGreeting => 'مرحباً';

  @override
  String get homeGuest => 'زائر';

  @override
  String get homeSearchHint => 'ابحث عن عيادة أو مشكلة صحية...';

  @override
  String get homeMyAppointments => 'مواعيدي';

  @override
  String get homeMedicalDepartments => 'التخصصات الطبية';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get homeNoUpcomingAppointments => 'لا توجد مواعيد قادمة';

  @override
  String get homeNoDepartments => 'لا توجد تخصصات متاحة';

  @override
  String get apptUpcoming => 'القادمة';

  @override
  String get apptPast => 'السابقة';

  @override
  String get apptCancelled => 'الملغاة';

  @override
  String get apptStatusConfirmed => 'مؤكد';

  @override
  String get apptStatusPendingConfirm => 'في انتظار التأكيد';

  @override
  String get apptStatusCompleted => 'مكتمل';

  @override
  String get apptStatusCancelled => 'ملغي';

  @override
  String get apptStatusPending => 'قيد الانتظار';

  @override
  String get apptEnterSession => 'دخول للجلسة';

  @override
  String get apptMessageDoctor => 'مراسلة الطبيب';

  @override
  String get apptAppointmentDetails => 'تفاصيل الحجز';

  @override
  String get apptViewDetails => 'عرض التفاصيل';

  @override
  String get apptBookAppointment => 'حجز الموعد';

  @override
  String get apptCancelAppointment => 'إلغاء الموعد';

  @override
  String get apptCancelConfirm => 'هل أنت متأكد من رغبتك في إلغاء هذا الموعد؟';

  @override
  String get apptCancelReason => 'سبب الإلغاء (اختياري)';

  @override
  String get apptCancelReasonHint => 'مثال: تغير في الخطط';

  @override
  String get apptBack => 'رجوع';

  @override
  String get apptConfirmCancel => 'تأكيد الإلغاء';

  @override
  String get apptCannotCancel => 'لا يمكن إلغاء الموعد قبل أقل من 24 ساعة';

  @override
  String get apptNoAppointments => 'لا توجد مواعيد';

  @override
  String get apptNoUpcoming => 'لا توجد مواعيد قادمة';

  @override
  String get apptNoPast => 'لا توجد مواعيد سابقة';

  @override
  String get apptNoCancelled => 'لا توجد مواعيد ملغاة';

  @override
  String get apptUnauthorized => 'غير مصرح - يرجى تسجيل الدخول';

  @override
  String get deptDepartments => 'التخصصات';

  @override
  String get deptNoDepartments => 'لا توجد تخصصات متاحة';

  @override
  String get deptDoctors => 'الأطباء';

  @override
  String get deptServices => 'الخدمات';

  @override
  String get deptWorkingHours => 'ساعات العمل';

  @override
  String get deptSearchHint => 'ابحث عن تخصص طبي...';

  @override
  String deptResultsCount(int count) {
    return '$count نتيجة';
  }

  @override
  String get deptLoading => 'جاري تحميل التخصصات...';

  @override
  String get deptLoadError => 'حدث خطأ في تحميل التخصصات';

  @override
  String get deptTryAgain => 'يرجى المحاولة مرة أخرى';

  @override
  String get deptNoResults => 'لا توجد نتائج للبحث';

  @override
  String get deptTryOtherWords => 'جرب البحث بكلمات أخرى';

  @override
  String get deptLocationNotAvailable => 'الموقع غير متوفر';

  @override
  String get deptWillBeAddedSoon => 'سيتم إضافة التخصصات قريباً';

  @override
  String get deptNoServices => 'لا توجد خدمات متاحة حالياً';

  @override
  String get docDoctors => 'الأطباء';

  @override
  String get docNoDoctors => 'لا يوجد أطباء متاحون';

  @override
  String get docSpecialization => 'التخصص';

  @override
  String get docExperience => 'سنوات الخبرة';

  @override
  String get docRating => 'التقييم';

  @override
  String get docBook => 'حجز موعد';

  @override
  String docYearsExperience(int years) {
    return '$years سنوات خبرة';
  }

  @override
  String get docSpecialist => 'طبيب متخصص';

  @override
  String get docSearchHint => 'ابحث عن طبيب...';

  @override
  String get docLoading => 'جاري تحميل الأطباء...';

  @override
  String get docLoadError => 'حدث خطأ في تحميل الأطباء';

  @override
  String get docTryOtherWords => 'جرب البحث بكلمات أخرى أو مسح البحث';

  @override
  String get docWillBeAddedSoon => 'سيتم إضافة الأطباء قريباً';

  @override
  String get docClearSearch => 'مسح البحث';

  @override
  String docResultsCount(int count) {
    return '$count نتيجة';
  }

  @override
  String get profProfile => 'الملف الشخصي';

  @override
  String get profEditProfile => 'تعديل الملف الشخصي';

  @override
  String get profMedicalRecords => 'السجلات الطبية';

  @override
  String get profPayments => 'المدفوعات';

  @override
  String get profSettings => 'الإعدادات';

  @override
  String get profHelpSupport => 'المساعدة والدعم';

  @override
  String get profLanguage => 'اللغة';

  @override
  String get profArabic => 'العربية';

  @override
  String get profEnglish => 'English';

  @override
  String get profComingSoon => 'سيتم تطوير هذه الميزة قريباً';

  @override
  String get profPersonalSettings => 'الإعدادات الشخصية';

  @override
  String get profGeneralSettings => 'الإعدادات العامة';

  @override
  String get profAccount => 'الحساب';

  @override
  String get profDataUpdated => 'تم تحديث البيانات بنجاح';

  @override
  String get profSessionExpired =>
      'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى';

  @override
  String get profUnauthorized => 'غير مصرح - يرجى تسجيل الدخول';

  @override
  String get profConnectionError =>
      'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت';

  @override
  String get profNoUserData => 'لا توجد بيانات للمستخدم';

  @override
  String get profPatient => 'مريض';

  @override
  String get profAppointments => 'المواعيد';

  @override
  String get profSessions => 'الجلسات';

  @override
  String get profLogoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get profImagePickFailed => 'فشل اختيار الصورة';

  @override
  String get profProfileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get profUpdateFailed => 'فشل تحديث البيانات';

  @override
  String get profPhoneAlreadyUsed => 'رقم الهاتف مستخدم بالفعل';

  @override
  String get profEnterName => 'يرجى إدخال الاسم';

  @override
  String get profEnterPhone => 'يرجى إدخال رقم الهاتف';

  @override
  String get profSaveChanges => 'حفظ التغييرات';

  @override
  String get drDashboard => 'لوحة التحكم';

  @override
  String get drAppointments => 'المواعيد';

  @override
  String get drSchedule => 'الجدول';

  @override
  String get drServices => 'الخدمات';

  @override
  String get drReject => 'رفض';

  @override
  String get drAccept => 'قبول';

  @override
  String get drRejectReason => 'سبب الرفض';

  @override
  String get drEnterReason => 'أدخل السبب';

  @override
  String get drCancel => 'إلغاء';

  @override
  String get drSave => 'حفظ';

  @override
  String get drCreateRecord => 'إنشاء سجل طبي';

  @override
  String get commonLoading => 'جاري التحميل...';

  @override
  String get commonError => 'حدث خطأ';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonOk => 'موافق';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get apptDetailsTitle => 'تفاصيل الموعد';

  @override
  String get apptDetailsStatus => 'حالة الموعد';

  @override
  String get apptDetailsDoctor => 'الطبيب';

  @override
  String get apptDetailsService => 'الخدمة';

  @override
  String get apptDetailsDateTime => 'التاريخ والوقت';

  @override
  String get apptDetailsDuration => 'المدة';

  @override
  String get apptDetailsType => 'النوع';

  @override
  String get apptDetailsPrice => 'السعر';

  @override
  String get apptDetailsPayment => 'الدفع';

  @override
  String get apptTypeInPerson => 'حضور شخصي';

  @override
  String get apptTypeVideo => 'مكالمة فيديو';

  @override
  String get apptTypeChat => 'محادثة نصية';

  @override
  String get apptStatusNoShow => 'لم يحضر';

  @override
  String get apptStatusRejected => 'مرفوض';

  @override
  String get apptTimeRemaining => 'متبقي';

  @override
  String get apptTimeOngoing => 'جاري';

  @override
  String get apptTimeFinished => 'انتهى';

  @override
  String get apptMorning => 'صباحاً';

  @override
  String get apptEvening => 'مساءً';

  @override
  String get apptUnauthorizedDoctor => 'غير مصرح - يجب أن تكون طبيباً';

  @override
  String get apptOnlyCompleted =>
      'يمكن إنشاء السجل الطبي فقط للمواعيد المكتملة';

  @override
  String get apptRecordCreated => 'تم إنشاء السجل الطبي بنجاح';

  @override
  String get apptSelectDoctorFirst => 'يرجى اختيار الطبيب أولاً';

  @override
  String get apptSelectServiceFirst => 'يرجى اختيار الخدمة أولاً';

  @override
  String get apptSelectDateAndSlot => 'يرجى اختيار التاريخ وفتحة زمنية متاحة';

  @override
  String get apptSelectFutureTime => 'يرجى اختيار وقت في المستقبل';

  @override
  String get apptBookSuccess => 'تم حجز الموعد بنجاح';

  @override
  String get apptBookConfirmSuccess => 'تم حجز وتأكيد الموعد بنجاح ✓';

  @override
  String get apptBookPendingConfirm =>
      'تم حجز الموعد بنجاح. سيتم تأكيده من قبل الطبيب.';

  @override
  String get apptTypeTitle => 'نوع الموعد';

  @override
  String get apptDateTitle => 'التاريخ';

  @override
  String get apptSelectDate => 'اختر التاريخ';

  @override
  String get apptSelectDateHelp => 'اختر تاريخ الموعد';

  @override
  String get apptSelectTimeTitle => 'اختر وقتاً من الفتحات المتاحة';

  @override
  String get apptNoSlotsAvailable =>
      'لا توجد فتحات متاحة في هذا اليوم. الرجاء اختيار تاريخ آخر.';

  @override
  String get apptSelectDoctorWarning => 'يرجى اختيار الطبيب أولاً قبل الحجز';

  @override
  String get apptSelectDoctor => 'اختر طبيب';

  @override
  String get apptDoctor => 'الطبيب';

  @override
  String get apptDoctorNotSelected => 'طبيب غير محدد';

  @override
  String get apptChangeDoctor => 'تغيير الطبيب';

  @override
  String get apptServiceSpecialty => 'الخدمة / التخصص';

  @override
  String get apptBooking => 'جاري الحجز...';

  @override
  String get apptBookingConfirming => 'جاري الحجز والتأكيد...';

  @override
  String get apptSelectAvailableTime => 'اختر وقتاً متاحاً';

  @override
  String get apptBookConfirmedTest => 'حجز مؤكد للاختبار ✓';

  @override
  String get apptTestModeDoctor => 'وضع الاختبار: حجز مؤكد مباشرة (كطبيب)';

  @override
  String get apptTestModePatient =>
      'وضع الاختبار: الحجز سيحتاج تأكيد من الطبيب';

  @override
  String apptMinimumMinutes(int minutes) {
    return 'يرجى اختيار وقت بعد $minutes دقائق على الأقل من الآن';
  }

  @override
  String apptError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get apptBookSuccessDoctorLogin =>
      '⚠️ تم الحجز بنجاح. يرجى تسجيل الدخول كطبيب لتأكيد الموعد تلقائياً، أو سيتم تأكيده يدوياً من قبل الطبيب.';

  @override
  String apptBookSuccessConfirmFailed(String error) {
    return 'تم الحجز بنجاح، لكن فشل التأكيد التلقائي: $error';
  }

  @override
  String get supportTitle => 'المساعدة والدعم';

  @override
  String get supportNewTicket => 'تذكرة جديدة';

  @override
  String get supportNoTickets => 'لا توجد تذاكر دعم حالياً';

  @override
  String get supportCreateTitle => 'إنشاء تذكرة جديدة';

  @override
  String get supportCategory => 'الفئة';

  @override
  String get supportSubject => 'الموضوع';

  @override
  String get supportDescription => 'الوصف';

  @override
  String get supportSubjectRequired => 'يرجى إدخال الموضوع';

  @override
  String get supportDescriptionRequired => 'يرجى إدخال الوصف';

  @override
  String get supportSend => 'إرسال التذكرة';

  @override
  String get supportCreateSuccess => 'تم إنشاء التذكرة بنجاح';

  @override
  String get supportDetails => 'تفاصيل التذكرة';

  @override
  String get supportOriginalTicket => 'التذكرة الأصلية';

  @override
  String get supportReplyHint => 'اكتب ردك هنا...';

  @override
  String get supportStatusOpen => 'مفتوحة';

  @override
  String get supportStatusInProgress => 'قيد التنفيذ';

  @override
  String get supportStatusResolved => 'تم الحل';

  @override
  String get supportStatusClosed => 'مغلقة';

  @override
  String get supportCatTechnical => 'مشكلة تقنية';

  @override
  String get supportCatBilling => 'مشكلة في الدفع';

  @override
  String get supportCatMedical => 'استفسار طبي';

  @override
  String get supportCatOther => 'أخرى';

  @override
  String get apptPaymentRequired => 'يرجى إكمال الدفع لتأكيد الحجز';

  @override
  String get paymentTitle => 'الدفع';

  @override
  String get paymentRequired => 'الدفع مطلوب لتأكيد الحجز';

  @override
  String get paymentCompleteToConfirm => 'أكمل الدفع لتأكيد حجزك';

  @override
  String get paymentDetails => 'تفاصيل الدفع';

  @override
  String get paymentAmount => 'المبلغ';

  @override
  String get paymentStatus => 'حالة الدفع';

  @override
  String get paymentStatusPending => 'في انتظار الدفع';

  @override
  String get paymentStatusCompleted => 'تم الدفع';

  @override
  String get paymentStatusFailed => 'فشل الدفع';

  @override
  String get paymentPayNow => 'ادفع الآن';

  @override
  String get paymentProcessing => 'جاري معالجة الدفع...';

  @override
  String get paymentSuccess => 'تم الدفع بنجاح! تم تأكيد حجزك';

  @override
  String get paymentCancelled => 'تم إلغاء عملية الدفع';

  @override
  String get paymentError => 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى';

  @override
  String get paymentReservationExpiry =>
      'ملاحظة: سينتهي الحجز إذا لم يتم الدفع خلال 15 دقيقة';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات';

  @override
  String get notificationsEmptyDescription => 'ستظهر إشعاراتك هنا';

  @override
  String get notificationsMarkAllRead => 'تعيين الكل كمقروء';

  @override
  String get notificationsClearAll => 'مسح الكل';

  @override
  String get notificationsDelete => 'حذف';

  @override
  String get notificationsJustNow => 'الآن';

  @override
  String notificationsMinutesAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String notificationsHoursAgo(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String notificationsDaysAgo(int count) {
    return 'منذ $count يوم';
  }
}
