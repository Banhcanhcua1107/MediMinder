import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('en'),
    Locale('vi'),
  ];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'MediMinder'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @testAlarm.
  ///
  /// In en, this message translates to:
  /// **'Test Alarm'**
  String get testAlarm;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @termsPolicy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Policy'**
  String get termsPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @featureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature in development'**
  String get featureInDevelopment;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get pleaseLogin;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @emailExample.
  ///
  /// In en, this message translates to:
  /// **'email@example.com'**
  String get emailExample;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'This is your alarm notification!'**
  String get testNotificationBody;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get testNotificationSent;

  /// No description provided for @checkSound.
  ///
  /// In en, this message translates to:
  /// **'Check sound now'**
  String get checkSound;

  /// No description provided for @errorTesting.
  ///
  /// In en, this message translates to:
  /// **'Error during test'**
  String get errorTesting;

  /// No description provided for @turnOnDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Turn on dark mode'**
  String get turnOnDarkMode;

  /// No description provided for @turnOffDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Turn off dark mode'**
  String get turnOffDarkMode;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Logout error'**
  String get logoutError;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MediMinder'**
  String get welcome;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginWithGoogle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @medicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicine;

  /// No description provided for @editMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit Medicine'**
  String get editMedicine;

  /// No description provided for @deleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Delete Medicine'**
  String get deleteMedicine;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicineName;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @medicineType.
  ///
  /// In en, this message translates to:
  /// **'Medicine Type'**
  String get medicineType;

  /// No description provided for @tablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get tablet;

  /// No description provided for @capsule.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get capsule;

  /// No description provided for @syrup.
  ///
  /// In en, this message translates to:
  /// **'Syrup'**
  String get syrup;

  /// No description provided for @injection.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get injection;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @everyOtherDay.
  ///
  /// In en, this message translates to:
  /// **'Every Other Day'**
  String get everyOtherDay;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose Time'**
  String get chooseTime;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date (optional)'**
  String get endDate;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this medicine? This action cannot be undone'**
  String get deleteConfirmation;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning 👋'**
  String get goodMorning;

  /// No description provided for @noScheduleToday.
  ///
  /// In en, this message translates to:
  /// **'No schedules for today.'**
  String get noScheduleToday;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Medicine'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteConfirmMessage(String name);

  /// No description provided for @errorLoadingUserInfo.
  ///
  /// In en, this message translates to:
  /// **'Error loading user info'**
  String get errorLoadingUserInfo;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading'**
  String get errorLoading;

  /// No description provided for @medicineSaved.
  ///
  /// In en, this message translates to:
  /// **'✅ Medicine saved'**
  String get medicineSaved;

  /// No description provided for @medicineDeleted.
  ///
  /// In en, this message translates to:
  /// **'Medicine deleted'**
  String get medicineDeleted;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving'**
  String get errorSaving;

  /// No description provided for @errorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting medicine'**
  String get errorDeleting;

  /// No description provided for @medicineHistory.
  ///
  /// In en, this message translates to:
  /// **'Medicine History'**
  String get medicineHistory;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get pleaseTryAgain;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get signOutConfirm;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// No description provided for @codeNotValid.
  ///
  /// In en, this message translates to:
  /// **'Verification code is not valid'**
  String get codeNotValid;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code has been sent'**
  String get codeSent;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Please check your email'**
  String get checkEmail;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password Changed!'**
  String get passwordChanged;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully.'**
  String get passwordChangedSuccess;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset code'**
  String get resetPasswordDesc;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordNotMatching.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotMatching;

  /// No description provided for @savingData.
  ///
  /// In en, this message translates to:
  /// **'Saving data...'**
  String get savingData;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @medicineTaken.
  ///
  /// In en, this message translates to:
  /// **'Medicine taken'**
  String get medicineTaken;

  /// No description provided for @medicineNotTaken.
  ///
  /// In en, this message translates to:
  /// **'Medicine not taken'**
  String get medicineNotTaken;

  /// No description provided for @takenAt.
  ///
  /// In en, this message translates to:
  /// **'Taken at'**
  String get takenAt;

  /// No description provided for @missedIntake.
  ///
  /// In en, this message translates to:
  /// **'Missed intake'**
  String get missedIntake;

  /// No description provided for @intakeHistory.
  ///
  /// In en, this message translates to:
  /// **'Intake History'**
  String get intakeHistory;

  /// No description provided for @editMedicineInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Medicine Information'**
  String get editMedicineInfo;

  /// No description provided for @deleteMedicineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Medicine'**
  String get deleteMedicineConfirm;

  /// No description provided for @healthMetrics.
  ///
  /// In en, this message translates to:
  /// **'Health Metrics'**
  String get healthMetrics;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @glucose.
  ///
  /// In en, this message translates to:
  /// **'Glucose'**
  String get glucose;

  /// No description provided for @cholesterol.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get cholesterol;

  /// No description provided for @medicineType_Tablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get medicineType_Tablet;

  /// No description provided for @medicineType_Capsule.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get medicineType_Capsule;

  /// No description provided for @medicineType_Syrup.
  ///
  /// In en, this message translates to:
  /// **'Syrup'**
  String get medicineType_Syrup;

  /// No description provided for @medicineType_Injection.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get medicineType_Injection;

  /// No description provided for @frequency_Daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get frequency_Daily;

  /// No description provided for @frequency_EveryOtherDay.
  ///
  /// In en, this message translates to:
  /// **'Every Other Day'**
  String get frequency_EveryOtherDay;

  /// No description provided for @frequency_Custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get frequency_Custom;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @selectReminder.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectReminder;

  /// No description provided for @addMedicineSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medicine saved successfully'**
  String get addMedicineSuccess;

  /// No description provided for @updateMedicineSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medicine updated successfully'**
  String get updateMedicineSuccess;

  /// No description provided for @emptyField.
  ///
  /// In en, this message translates to:
  /// **'This field cannot be empty'**
  String get emptyField;

  /// No description provided for @googleSignInError.
  ///
  /// In en, this message translates to:
  /// **'Google Sign In Error'**
  String get googleSignInError;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google Sign In failed'**
  String get googleSignInFailed;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @manageHealth.
  ///
  /// In en, this message translates to:
  /// **'Manage Health'**
  String get manageHealth;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @noMedicines.
  ///
  /// In en, this message translates to:
  /// **'No medicines yet'**
  String get noMedicines;

  /// No description provided for @addFirstMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add your first medicine'**
  String get addFirstMedicine;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history available'**
  String get noHistory;

  /// No description provided for @yourMedicines.
  ///
  /// In en, this message translates to:
  /// **'Your Medicines'**
  String get yourMedicines;

  /// No description provided for @medicinesInUse.
  ///
  /// In en, this message translates to:
  /// **'medicines in use'**
  String get medicinesInUse;

  /// No description provided for @noMedicinesAdded.
  ///
  /// In en, this message translates to:
  /// **'You have no medicines yet. Press + button to add.'**
  String get noMedicinesAdded;

  /// No description provided for @selectIntakeTimes.
  ///
  /// In en, this message translates to:
  /// **'Select Intake Times'**
  String get selectIntakeTimes;

  /// No description provided for @saveMedicine.
  ///
  /// In en, this message translates to:
  /// **'Save Medicine'**
  String get saveMedicine;

  /// No description provided for @intakeTimes.
  ///
  /// In en, this message translates to:
  /// **'Intake Times'**
  String get intakeTimes;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @medicineInfo.
  ///
  /// In en, this message translates to:
  /// **'Medicine Information'**
  String get medicineInfo;

  /// No description provided for @editMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Medicine'**
  String get editMedicineTitle;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recorded;

  /// No description provided for @youTookDose.
  ///
  /// In en, this message translates to:
  /// **'You\'ve taken 1 dose'**
  String get youTookDose;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get deleteConfirm;

  /// No description provided for @enterBmi.
  ///
  /// In en, this message translates to:
  /// **'Please enter BMI'**
  String get enterBmi;

  /// No description provided for @enterBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Please enter blood pressure'**
  String get enterBloodPressure;

  /// No description provided for @enterHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Please enter heart rate'**
  String get enterHeartRate;

  /// No description provided for @enterGlucose.
  ///
  /// In en, this message translates to:
  /// **'Please enter glucose level'**
  String get enterGlucose;

  /// No description provided for @enterCholesterol.
  ///
  /// In en, this message translates to:
  /// **'Please enter cholesterol level'**
  String get enterCholesterol;

  /// No description provided for @healthSaved.
  ///
  /// In en, this message translates to:
  /// **'Health profile saved'**
  String get healthSaved;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Email is not valid'**
  String get emailInvalid;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @codeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Code is not valid'**
  String get codeInvalid;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendVerificationCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Update Successful'**
  String get updateSuccess;

  /// No description provided for @savedChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get savedChanges;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @chooseGender.
  ///
  /// In en, this message translates to:
  /// **'Choose gender'**
  String get chooseGender;

  /// No description provided for @uploadImageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully'**
  String get uploadImageSuccess;

  /// No description provided for @yourAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your avatar has been updated'**
  String get yourAvatarUpdated;

  /// No description provided for @uploadImageError.
  ///
  /// In en, this message translates to:
  /// **'Image upload error'**
  String get uploadImageError;

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload error'**
  String get uploadError;

  /// No description provided for @bmiIndex.
  ///
  /// In en, this message translates to:
  /// **'BMI Index'**
  String get bmiIndex;

  /// No description provided for @enterBmiValue.
  ///
  /// In en, this message translates to:
  /// **'Enter BMI value'**
  String get enterBmiValue;

  /// No description provided for @glucoseLevel.
  ///
  /// In en, this message translates to:
  /// **'Glucose Level'**
  String get glucoseLevel;

  /// No description provided for @cholesterolLevel.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol Level'**
  String get cholesterolLevel;

  /// No description provided for @saveSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get saveSuccessfully;

  /// No description provided for @healthIndicatorsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your health indicators have been updated'**
  String get healthIndicatorsUpdated;

  /// No description provided for @medicalIntakeHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical Intake History'**
  String get medicalIntakeHistory;

  /// No description provided for @taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get taken;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @medicineScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get medicineScheduled;

  /// No description provided for @noNotesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No notes available. You can add notes when editing the medicine'**
  String get noNotesAvailable;

  /// No description provided for @medicineDeletedFromList.
  ///
  /// In en, this message translates to:
  /// **'Medicine has been deleted from the list'**
  String get medicineDeletedFromList;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @selectAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one day to take medicine'**
  String get selectAtLeastOneDay;

  /// No description provided for @saveToSupabase.
  ///
  /// In en, this message translates to:
  /// **'Save to Supabase'**
  String get saveToSupabase;

  /// No description provided for @deletedMedicine.
  ///
  /// In en, this message translates to:
  /// **'Deleted medicine'**
  String get deletedMedicine;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting: '**
  String get deleteError;

  /// No description provided for @cannotDeleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete medicine'**
  String get cannotDeleteMedicine;

  /// No description provided for @updateLastDate.
  ///
  /// In en, this message translates to:
  /// **'Updated on 15/07'**
  String get updateLastDate;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get selectMonth;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @chooseMonth.
  ///
  /// In en, this message translates to:
  /// **'Choose month'**
  String get chooseMonth;

  /// No description provided for @takenOut.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get takenOut;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @editMedication.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get editMedication;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @updateInfo.
  ///
  /// In en, this message translates to:
  /// **'Update Information'**
  String get updateInfo;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!\nGreat to see you again!'**
  String get welcomeBack;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @pleaseCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check again'**
  String get pleaseCheckAgain;

  /// No description provided for @signInError.
  ///
  /// In en, this message translates to:
  /// **'Sign in error'**
  String get signInError;

  /// No description provided for @helloSignUp.
  ///
  /// In en, this message translates to:
  /// **'Hello! Sign up to\nget started'**
  String get helloSignUp;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccount;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please check your email'**
  String get checkYourEmail;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get tryAgain;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! This happens. Please enter the email address associated with your account.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @enterFullOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete 6-digit code'**
  String get enterFullOtp;

  /// No description provided for @verificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification successful!'**
  String get verificationSuccess;

  /// No description provided for @invalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code:'**
  String get invalidVerificationCode;

  /// No description provided for @wrongVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Wrong verification code'**
  String get wrongVerificationCode;

  /// No description provided for @resendCodeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Resend code successful'**
  String get resendCodeSuccess;

  /// No description provided for @resendError.
  ///
  /// In en, this message translates to:
  /// **'Resend error'**
  String get resendError;

  /// No description provided for @tryLaterAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tryLaterAgain;

  /// No description provided for @enterOtpSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we just sent to:\n'**
  String get enterOtpSent;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resendCodeIn;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorMessage;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidCode;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to your email and your new password.'**
  String get resetPasswordDescription;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdated;

  /// No description provided for @pleaseLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'Please log in again'**
  String get pleaseLoginAgain;

  /// No description provided for @passwordUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Password update error'**
  String get passwordUpdateError;

  /// No description provided for @newPasswordDifferent.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be different from previously used passwords.'**
  String get newPasswordDifferent;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Your personal assistant helps you manage your medicine schedule every day.'**
  String get appDescription;

  /// No description provided for @testAlarmSet.
  ///
  /// In en, this message translates to:
  /// **'Test alarm set'**
  String get testAlarmSet;

  /// No description provided for @willFireIn10Seconds.
  ///
  /// In en, this message translates to:
  /// **'Will fire in 10 seconds...'**
  String get willFireIn10Seconds;

  /// No description provided for @medicineIntakeStatus.
  ///
  /// In en, this message translates to:
  /// **'Took {count} out of {total} doses'**
  String medicineIntakeStatus(String count, String total);

  /// No description provided for @medicineDosageDisplay.
  ///
  /// In en, this message translates to:
  /// **'{strength}, {dose} tablets'**
  String medicineDosageDisplay(String strength, String dose);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @yourInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Your information has been saved'**
  String get yourInfoSaved;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving'**
  String get saveError;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @avatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your avatar has been updated'**
  String get avatarUpdated;

  /// No description provided for @imageUploadError.
  ///
  /// In en, this message translates to:
  /// **'Image upload error'**
  String get imageUploadError;

  /// No description provided for @pleaseEnter.
  ///
  /// In en, this message translates to:
  /// **'Please enter'**
  String get pleaseEnter;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccessfully;

  /// No description provided for @healthIndicesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your health indices have been updated'**
  String get healthIndicesUpdated;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add notes...'**
  String get addNotes;

  /// No description provided for @timeToTakeMedicine.
  ///
  /// In en, this message translates to:
  /// **'Time to take your medicine! 💊'**
  String get timeToTakeMedicine;

  /// No description provided for @medicineDetails.
  ///
  /// In en, this message translates to:
  /// **'{name} - {dosage}, {quantity} tablets'**
  String medicineDetails(String name, String dosage, String quantity);

  /// No description provided for @scheduleSet.
  ///
  /// In en, this message translates to:
  /// **'Medicine reminder schedule set'**
  String get scheduleSet;

  /// No description provided for @addNewMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add New Medicine'**
  String get addNewMedicine;

  /// No description provided for @enterMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Enter medicine name'**
  String get enterMedicineName;

  /// No description provided for @endDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End Date (Optional)'**
  String get endDateOptional;

  /// No description provided for @medicineSchedule.
  ///
  /// In en, this message translates to:
  /// **'Medicine Schedule'**
  String get medicineSchedule;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @selectDaysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Select days of week'**
  String get selectDaysOfWeek;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String days(String count);

  /// No description provided for @confirmDeleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String confirmDeleteMedicine(String name);

  /// No description provided for @defaultDosage.
  ///
  /// In en, this message translates to:
  /// **'1 tablet, 1000mg'**
  String get defaultDosage;

  /// No description provided for @defaultMedicineType.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get defaultMedicineType;

  /// No description provided for @quantityDisplay.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {count}'**
  String quantityDisplay(String count);

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @guestOneFone.
  ///
  /// In en, this message translates to:
  /// **'You took 1 dose'**
  String get guestOneFone;

  /// No description provided for @noNotesMessage.
  ///
  /// In en, this message translates to:
  /// **'No notes available. You can add notes when editing medicine.'**
  String get noNotesMessage;

  /// No description provided for @youTookOneDose.
  ///
  /// In en, this message translates to:
  /// **'You took 1 dose'**
  String get youTookOneDose;

  /// No description provided for @medicineDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Medicine has been successfully removed'**
  String get medicineDeletedSuccessfully;

  /// No description provided for @medicineRemovedFromList.
  ///
  /// In en, this message translates to:
  /// **'Medicine has been removed from your list'**
  String get medicineRemovedFromList;

  /// No description provided for @addMedicinesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your medicines to get reminders at the right time and monitor your health'**
  String get addMedicinesDescription;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @tookDoses.
  ///
  /// In en, this message translates to:
  /// **'Took {taken} out of {total} doses'**
  String tookDoses(String taken, String total);

  /// No description provided for @todaySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get todaySchedule;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'{dosage}, {quantity} units'**
  String units(String dosage, String quantity);

  /// No description provided for @markTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark Taken'**
  String get markTaken;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select type'**
  String get selectType;

  /// No description provided for @exampleDosage.
  ///
  /// In en, this message translates to:
  /// **'e.g. 500mg'**
  String get exampleDosage;

  /// No description provided for @exampleQuantity.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1'**
  String get exampleQuantity;

  /// No description provided for @timeFrame.
  ///
  /// In en, this message translates to:
  /// **'Time Frame'**
  String get timeFrame;

  /// No description provided for @timeTaken.
  ///
  /// In en, this message translates to:
  /// **'Time to take'**
  String get timeTaken;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'+ Add Time'**
  String get addTime;

  /// No description provided for @exampleNotes.
  ///
  /// In en, this message translates to:
  /// **'e.g. Take after meals...'**
  String get exampleNotes;

  /// No description provided for @medicineAdded.
  ///
  /// In en, this message translates to:
  /// **'Medicine has been added'**
  String get medicineAdded;

  /// No description provided for @reminderSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder set'**
  String get reminderSet;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'Duration (days)'**
  String get durationDays;

  /// No description provided for @healthMetricsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your health metrics have been updated'**
  String get healthMetricsUpdated;

  /// No description provided for @myHealth.
  ///
  /// In en, this message translates to:
  /// **'My Health'**
  String get myHealth;

  /// No description provided for @noHealthInfo.
  ///
  /// In en, this message translates to:
  /// **'No health information'**
  String get noHealthInfo;

  /// No description provided for @addInfoToStart.
  ///
  /// In en, this message translates to:
  /// **'Add information to get started'**
  String get addInfoToStart;

  /// No description provided for @enterInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter Info'**
  String get enterInfo;

  /// No description provided for @bmiStatus.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmiStatus;

  /// No description provided for @bloodPressureStatus.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressureStatus;

  /// No description provided for @heartRateStatus.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRateStatus;

  /// No description provided for @mmHg.
  ///
  /// In en, this message translates to:
  /// **'mmHg'**
  String get mmHg;

  /// No description provided for @bpm.
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get bpm;

  /// No description provided for @healthAssessment.
  ///
  /// In en, this message translates to:
  /// **'Health Assessment'**
  String get healthAssessment;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @caution.
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get caution;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @bmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiUnderweight;

  /// No description provided for @bmiNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal weight'**
  String get bmiNormal;

  /// No description provided for @bmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiOverweight;

  /// No description provided for @bmiObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmiObese;

  /// No description provided for @bpNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get bpNormal;

  /// No description provided for @bpElevated.
  ///
  /// In en, this message translates to:
  /// **'Elevated'**
  String get bpElevated;

  /// No description provided for @bpStage1.
  ///
  /// In en, this message translates to:
  /// **'Stage 1 Hypertension'**
  String get bpStage1;

  /// No description provided for @bpStage2.
  ///
  /// In en, this message translates to:
  /// **'Stage 2 Hypertension'**
  String get bpStage2;

  /// No description provided for @bpCritical.
  ///
  /// In en, this message translates to:
  /// **'Hypertensive Crisis'**
  String get bpCritical;

  /// No description provided for @hrNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get hrNormal;

  /// No description provided for @hrSlow.
  ///
  /// In en, this message translates to:
  /// **'Too slow'**
  String get hrSlow;

  /// No description provided for @hrFast.
  ///
  /// In en, this message translates to:
  /// **'Too fast'**
  String get hrFast;

  /// No description provided for @recommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// No description provided for @bmiRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Maintain healthy diet and exercise regularly'**
  String get bmiRecommendation;

  /// No description provided for @bpRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Monitor blood pressure regularly and consult doctor if elevated'**
  String get bpRecommendation;

  /// No description provided for @hrRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Check heart rate again and consult doctor if abnormal'**
  String get hrRecommendation;

  /// No description provided for @addHealthInfo.
  ///
  /// In en, this message translates to:
  /// **'Add Health Information'**
  String get addHealthInfo;

  /// No description provided for @healthInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Health information saved successfully'**
  String get healthInfoSaved;

  /// No description provided for @glucoseStatus.
  ///
  /// In en, this message translates to:
  /// **'Glucose'**
  String get glucoseStatus;

  /// No description provided for @cholesterolStatus.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get cholesterolStatus;

  /// No description provided for @mgDL.
  ///
  /// In en, this message translates to:
  /// **'mg/dL'**
  String get mgDL;

  /// No description provided for @glucoseLow.
  ///
  /// In en, this message translates to:
  /// **'Low blood sugar'**
  String get glucoseLow;

  /// No description provided for @glucoseNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get glucoseNormal;

  /// No description provided for @glucosePrediabetic.
  ///
  /// In en, this message translates to:
  /// **'Prediabetic'**
  String get glucosePrediabetic;

  /// No description provided for @glucoseDiabetic.
  ///
  /// In en, this message translates to:
  /// **'Diabetic'**
  String get glucoseDiabetic;

  /// No description provided for @glucoseHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get glucoseHigh;

  /// No description provided for @cholesterolDesirable.
  ///
  /// In en, this message translates to:
  /// **'Desirable'**
  String get cholesterolDesirable;

  /// No description provided for @cholesterolBorderline.
  ///
  /// In en, this message translates to:
  /// **'Borderline high'**
  String get cholesterolBorderline;

  /// No description provided for @cholesterolHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get cholesterolHigh;

  /// No description provided for @glucoseRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Monitor blood sugar regularly and consult doctor if elevated'**
  String get glucoseRecommendation;

  /// No description provided for @cholesterolRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Maintain healthy diet low in saturated fats and exercise regularly'**
  String get cholesterolRecommendation;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @enterHeightAndWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter height & weight to calculate'**
  String get enterHeightAndWeight;

  /// No description provided for @pleaseEnterHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter height'**
  String get pleaseEnterHeight;

  /// No description provided for @pleaseEnterWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter weight'**
  String get pleaseEnterWeight;

  /// No description provided for @invalidHeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid height'**
  String get invalidHeight;

  /// No description provided for @invalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid weight'**
  String get invalidWeight;

  /// No description provided for @enterPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a positive number'**
  String get enterPositiveNumber;

  /// No description provided for @medicinesScheduled.
  ///
  /// In en, this message translates to:
  /// **'Medicines Scheduled'**
  String get medicinesScheduled;

  /// No description provided for @nextIntake.
  ///
  /// In en, this message translates to:
  /// **'Next Intake'**
  String get nextIntake;

  /// No description provided for @dosageInfo.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosageInfo;

  /// No description provided for @intakeTime.
  ///
  /// In en, this message translates to:
  /// **'Intake Time'**
  String get intakeTime;

  /// No description provided for @medicineStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get medicineStatus;

  /// No description provided for @untaken.
  ///
  /// In en, this message translates to:
  /// **'Untaken'**
  String get untaken;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @allMedicinesTaken.
  ///
  /// In en, this message translates to:
  /// **'All medicines taken!'**
  String get allMedicinesTaken;

  /// No description provided for @noMedicinesScheduled.
  ///
  /// In en, this message translates to:
  /// **'No medicines scheduled for today'**
  String get noMedicinesScheduled;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @markAllTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark All Taken'**
  String get markAllTaken;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @notificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Get reminders for your medicines'**
  String get notificationDescription;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// No description provided for @medicineReminders.
  ///
  /// In en, this message translates to:
  /// **'MEDICINE REMINDERS'**
  String get medicineReminders;

  /// No description provided for @enableMedicineReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable Medicine Reminders'**
  String get enableMedicineReminders;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @reminderTimeSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder time set'**
  String get reminderTimeSet;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @reminderBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get reminderBefore;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @remindBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind before'**
  String get remindBefore;

  /// No description provided for @repeatInterval.
  ///
  /// In en, this message translates to:
  /// **'Repeat every'**
  String get repeatInterval;

  /// No description provided for @repeatIntervalSet.
  ///
  /// In en, this message translates to:
  /// **'Repeat every'**
  String get repeatIntervalSet;

  /// No description provided for @soundAndVibration.
  ///
  /// In en, this message translates to:
  /// **'SOUND & VIBRATION'**
  String get soundAndVibration;

  /// No description provided for @notificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get notificationSound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @testNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Send test notification with alarm'**
  String get testNotificationDescription;

  /// No description provided for @notificationInfo.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to receive timely reminders for taking your medicines. Customize sound, vibration, and reminder timing.'**
  String get notificationInfo;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
