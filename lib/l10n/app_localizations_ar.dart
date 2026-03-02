// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'لوحة الأولويات';

  @override
  String get board => 'اللوحة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get searchHint => 'ابحث في الملاحظات';

  @override
  String get showDone => 'إظهار المكتمل';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterHideDone => 'إخفاء المكتمل';

  @override
  String get doneFilterControl => 'فلتر المهام المكتملة';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get delete => 'حذف';

  @override
  String get undo => 'تراجع';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get title => 'العنوان';

  @override
  String get description => 'الوصف';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get noDueDate => 'بدون تاريخ';

  @override
  String get markDone => 'مكتمل';

  @override
  String get moveTo => 'نقل إلى';

  @override
  String get themeMode => 'وضع المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'النظام';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get defaultShowDone => 'الإعداد الافتراضي لإظهار المكتمل';

  @override
  String get syncComingSoon => 'المزامنة (قريبًا)';

  @override
  String get syncComingSoonDesc =>
      'تسجيل الدخول والمزامنة السحابية عبر Firebase ستضاف في المرحلة الثانية.';

  @override
  String get syncSectionTitle => 'المزامنة السحابية';

  @override
  String get syncUnavailable => 'المزامنة السحابية غير متاحة';

  @override
  String get syncConnected => 'المزامنة السحابية جاهزة';

  @override
  String get syncNotSignedIn => 'سجّل الدخول لتفعيل المزامنة السحابية';

  @override
  String get syncDisabledByPreference =>
      'المزامنة السحابية معطلة على هذا الجهاز';

  @override
  String get syncNotConfiguredHelp =>
      'لم يتم إعداد Firebase بعد. شغّل FlutterFire configure واستبدل ملف firebase_options.dart.';

  @override
  String get syncEnableCloud => 'تفعيل المزامنة السحابية';

  @override
  String get syncEnableCloudDesc =>
      'السماح بتسجيل الدخول والمزامنة السحابية على هذا الجهاز.';

  @override
  String get syncEnableLive => 'تفعيل المزامنة الحية';

  @override
  String get syncEnableLiveDesc =>
      'تطبيق التغييرات السحابية تلقائيًا أثناء تسجيل الدخول.';

  @override
  String get syncEnableAutoResume => 'مزامنة تلقائية عند العودة للتطبيق';

  @override
  String get syncEnableAutoResumeDesc =>
      'سحب التغييرات السحابية تلقائيًا عند عودة التطبيق للواجهة.';

  @override
  String get syncEnableAutoPush => 'رفع تلقائي للتغييرات المحلية';

  @override
  String get syncEnableAutoPushDesc =>
      'يرفع تعديلاتك المحلية تلقائيًا بعد مهلة قصيرة. وتبقى أزرار الرفع/السحب اليدوي متاحة.';

  @override
  String get syncRecentActivity => 'سجل المزامنة الأخير';

  @override
  String get syncNoRecentActivity => 'لا توجد عمليات مزامنة بعد';

  @override
  String get syncActivityPush => 'رفع يدوي';

  @override
  String get syncActivityAutoPush => 'رفع تلقائي (تغييرات محلية)';

  @override
  String get syncActivityPull => 'سحب يدوي';

  @override
  String get syncActivityAutoPull => 'سحب تلقائي (عند العودة)';

  @override
  String get syncActivityLive => 'تطبيق مزامنة حية';

  @override
  String syncActivityFailed(String action) {
    return 'فشل $action';
  }

  @override
  String syncActivityErrorCode(String code) {
    return 'الخطأ: $code';
  }

  @override
  String syncActivityCounts(
    String summary,
    int upserts,
    int deletes,
    int conflicts,
  ) {
    return '$summary • تحديثات: $upserts، حذف: $deletes، تعارضات: $conflicts';
  }

  @override
  String get syncConflictLocalKeptHint =>
      'تم حل التعارضات بالاحتفاظ بالتعديلات المحلية الأحدث.';

  @override
  String get syncConflictRemoteKeptHint =>
      'تم حل التعارضات بالاحتفاظ بالتعديلات السحابية الأحدث.';

  @override
  String get syncConflictReviewHint =>
      'راجع تفاصيل التعارض لمعرفة معرّفات الملاحظات المتأثرة.';

  @override
  String get syncConflictDetailsAction => 'تفاصيل التعارض';

  @override
  String get syncConflictDetailsTitle => 'تفاصيل التعارض (معرّفات الملاحظات)';

  @override
  String get syncSignInGuestAction => 'المتابعة كضيف';

  @override
  String get syncSignInGoogleAction => 'تسجيل الدخول عبر Google';

  @override
  String get syncEmailSignInAction => 'تسجيل الدخول بالبريد الإلكتروني';

  @override
  String get syncEmailRegisterAction => 'إنشاء حساب';

  @override
  String get syncUpgradeWithGoogle => 'ترقية حساب الضيف عبر Google';

  @override
  String get syncUpgradeWithEmail => 'ترقية حساب الضيف بالبريد الإلكتروني';

  @override
  String get syncGuestUpgradeHint =>
      'حساب الضيف مرتبط بهذا الجهاز فقط. قم بالترقية إلى Google أو البريد الإلكتروني للمزامنة بين الأجهزة.';

  @override
  String get syncAccountGuest => 'الحساب: ضيف (مجهول)';

  @override
  String get syncAccountGoogle => 'الحساب: Google';

  @override
  String syncAccountGoogleEmail(String email) {
    return 'الحساب: Google ($email)';
  }

  @override
  String get syncAccountEmail => 'الحساب: بريد إلكتروني/كلمة مرور';

  @override
  String syncAccountEmailValue(String email) {
    return 'الحساب: $email';
  }

  @override
  String get syncAccountApple => 'الحساب: Apple';

  @override
  String get syncAccountUnknown => 'الحساب: تم تسجيل الدخول';

  @override
  String get syncSignIn => 'تسجيل الدخول';

  @override
  String get syncSignOut => 'تسجيل الخروج';

  @override
  String get syncPush => 'رفع';

  @override
  String get syncPull => 'سحب';

  @override
  String get syncSignedInGuest => 'تم تسجيل الدخول كضيف';

  @override
  String get syncSignedInGoogle => 'تم تسجيل الدخول عبر Google';

  @override
  String get syncSignedInEmail =>
      'تم تسجيل الدخول بالبريد الإلكتروني/كلمة المرور';

  @override
  String get syncEmailRegistered => 'تم إنشاء حساب البريد وربطه';

  @override
  String get syncSignedIn => 'تم تسجيل الدخول بنجاح';

  @override
  String get syncSignedOut => 'تم تسجيل الخروج';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get syncErrorGeneric => 'فشلت عملية المزامنة السحابية';

  @override
  String get syncErrorTimeout => 'انتهت مهلة المزامنة. حاول مرة أخرى.';

  @override
  String get syncErrorTimeoutHelp =>
      'استغرقت العملية وقتًا طويلًا. تحقّق من الاتصال ثم أعد المحاولة.';

  @override
  String get syncErrorNetwork =>
      'الشبكة غير متاحة. تحقّق من الاتصال ثم حاول مرة أخرى.';

  @override
  String get syncErrorNetworkHelp =>
      'تم اكتشاف مشكلة في الشبكة. تحقّق من الاتصال ثم أعد المحاولة.';

  @override
  String get syncErrorPermissionDenied =>
      'تم رفض المزامنة بواسطة قواعد Firestore';

  @override
  String get syncErrorPermissionDeniedHelp =>
      'قواعد Firestore منعت العملية. تأكد أن القواعد تسمح بالمسار users/<uid>/notes للمستخدم الحالي.';

  @override
  String get syncErrorAuthRequired => 'يلزم تسجيل الدخول قبل المزامنة';

  @override
  String get syncErrorAuthOperationNotAllowed =>
      'تسجيل الدخول المجهول غير مفعّل في Firebase Auth';

  @override
  String get syncErrorAuthOperationHelp =>
      'فعّل Anonymous Sign-in من Firebase Console > Authentication > Sign-in method.';

  @override
  String get syncErrorFirestoreSetup =>
      'قاعدة Firestore غير جاهزة لهذا المشروع بعد';

  @override
  String get syncErrorTooManyRequests =>
      'عدد الطلبات كبير جدًا. انتظر قليلًا ثم أعد المحاولة.';

  @override
  String get syncErrorUserNotFound => 'لا يوجد حساب لهذا البريد الإلكتروني';

  @override
  String get syncErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get syncErrorEmailAlreadyInUse =>
      'هذا البريد مستخدم بالفعل. سجّل الدخول بدلًا من ذلك.';

  @override
  String get syncErrorWeakPassword =>
      'كلمة المرور ضعيفة جدًا (الحد الأدنى 6 أحرف).';

  @override
  String get syncErrorInvalidEmail => 'صيغة البريد الإلكتروني غير صحيحة.';

  @override
  String get syncErrorAccountExistsDifferentProvider =>
      'هذا البريد مرتبط بطريقة تسجيل دخول أخرى.';

  @override
  String get syncErrorGoogleCanceled => 'تم إلغاء تسجيل الدخول عبر Google.';

  @override
  String get syncErrorGoogleTokenMissing =>
      'لم تُرجع Google رموز الدخول. حدّث ملفات الإعداد وأعد المحاولة.';

  @override
  String get syncErrorRetryHint =>
      'يمكنك إعادة محاولة آخر عملية مزامنة بعد إصلاح السبب.';

  @override
  String get syncRetrySuccess => 'تمت إعادة محاولة عملية المزامنة';

  @override
  String get retryAction => 'إعادة المحاولة';

  @override
  String get syncStatusUnavailable => 'Firebase غير متاح (وضع محلي فقط).';

  @override
  String get syncStatusIdle => 'جاهز';

  @override
  String get syncStatusAuthRequired => 'يلزم تسجيل الدخول';

  @override
  String get syncStatusPushing => 'جارٍ رفع الملاحظات المحلية إلى السحابة...';

  @override
  String get syncStatusPulling =>
      'جارٍ سحب الملاحظات السحابية إلى هذا الجهاز...';

  @override
  String get syncStatusLiveActive => 'المزامنة الحية مفعّلة';

  @override
  String get syncStatusLiveStopped => 'تم إيقاف المزامنة الحية';

  @override
  String get syncStatusLiveApplied => 'تم تطبيق التغييرات السحابية تلقائيًا';

  @override
  String get syncStatusLiveAppliedConflicts =>
      'تم تطبيق المزامنة الحية (مع الاحتفاظ بالتعديلات المحلية الأحدث)';

  @override
  String get syncLastSyncNever => 'آخر مزامنة: لم تتم بعد';

  @override
  String syncLastSyncSummary(String date, String time, String summary) {
    return 'آخر مزامنة: $date $time ($summary)';
  }

  @override
  String get syncStatusSuccess => 'اكتملت المزامنة';

  @override
  String get syncStatusError => 'فشلت المزامنة';

  @override
  String get syncStatusPushComplete => 'اكتمل الرفع';

  @override
  String get syncStatusPullComplete => 'اكتمل السحب';

  @override
  String get syncStatusPushCompleteConflicts =>
      'اكتمل الرفع (تم الاحتفاظ بالتعديلات الأحدث في السحابة)';

  @override
  String get syncStatusPullCompleteConflicts =>
      'اكتمل السحب (تم الاحتفاظ بالتعديلات الأحدث محليًا)';

  @override
  String get syncStatusPullRemoteEmptyLocalKept =>
      'السحابة فارغة؛ تم الاحتفاظ بالملاحظات المحلية (حماية من الحذف)';

  @override
  String syncUserId(String userId) {
    return 'المستخدم: $userId';
  }

  @override
  String syncPushDone(int upserts, int deletes, int skipped) {
    return 'اكتمل الرفع: تم تحديث $upserts، وحذف $deletes، وتخطي $skipped تعارضات';
  }

  @override
  String syncPullDone(int upserts, int deletes, int skipped) {
    return 'اكتمل السحب: تم تحديث $upserts، وحذف $deletes محليًا، وتخطي $skipped تعارضات';
  }

  @override
  String get q1Title => 'مهم وعاجل';

  @override
  String get q2Title => 'مهم وغير عاجل';

  @override
  String get q3Title => 'غير مهم وعاجل';

  @override
  String get q4Title => 'غير مهم وغير عاجل';

  @override
  String get q1Label => 'ابدأ الآن';

  @override
  String get q2Label => 'خطط له';

  @override
  String get q3Label => 'فوّضه';

  @override
  String get q4Label => 'استبعده';

  @override
  String get q1TabSemantics => 'قسم ابدأ الآن';

  @override
  String get q2TabSemantics => 'قسم خطط له';

  @override
  String get q3TabSemantics => 'قسم فوّضه';

  @override
  String get q4TabSemantics => 'قسم استبعده';

  @override
  String get emptyQuadrant => 'لا توجد ملاحظات بعد';

  @override
  String get emptySearch => 'لا نتائج مطابقة للبحث';

  @override
  String get noteDeleted => 'تم حذف الملاحظة';

  @override
  String get noteMoved => 'تم نقل الملاحظة';

  @override
  String get requiredTitle => 'العنوان مطلوب';

  @override
  String get clearDueDate => 'مسح التاريخ';

  @override
  String get pickDate => 'اختيار تاريخ';

  @override
  String get doneChip => 'منجز';

  @override
  String get dragToReorder => 'اسحب لإعادة الترتيب';

  @override
  String get loadDemoData => 'تحميل بيانات تجريبية';

  @override
  String get loadDemoDataDesc =>
      'استبدال الملاحظات المحلية ببيانات جاهزة لالتقاط لقطات الشاشة.';

  @override
  String demoDataLoaded(int count) {
    return 'تم تحميل $count ملاحظات تجريبية';
  }

  @override
  String get resetLocalData => 'إعادة ضبط البيانات المحلية';

  @override
  String get resetLocalDataDesc =>
      'يمسح كل الملاحظات والإعدادات المحفوظة على هذا الجهاز.';

  @override
  String get resetLocalDataConfirmTitle => 'إعادة ضبط البيانات؟';

  @override
  String get resetLocalDataConfirmBody =>
      'سيؤدي هذا إلى حذف كل الملاحظات والإعدادات نهائيًا من هذا الجهاز.';

  @override
  String get resetAction => 'إعادة ضبط';

  @override
  String get localDataResetSuccess => 'تمت إعادة ضبط البيانات المحلية';
}
