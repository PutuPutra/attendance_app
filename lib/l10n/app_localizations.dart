import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee Attendance'**
  String get appTitle;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'PT. ARRTU PLANTATION'**
  String get companyName;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @attendanceRecord.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendanceRecord;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @breakTime.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get breakTime;

  /// No description provided for @returnToWork.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnToWork;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @faceSaved.
  ///
  /// In en, this message translates to:
  /// **'Face Saved'**
  String get faceSaved;

  /// No description provided for @getPersonalFaceData.
  ///
  /// In en, this message translates to:
  /// **'Get Personal Face Data'**
  String get getPersonalFaceData;

  /// No description provided for @clearAllFaceData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Face Data'**
  String get clearAllFaceData;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all face data?'**
  String get confirmDelete;

  /// No description provided for @dataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Face data has been deleted.'**
  String get dataDeleted;

  /// No description provided for @notImplemented.
  ///
  /// In en, this message translates to:
  /// **'This feature is not yet implemented.'**
  String get notImplemented;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @attendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance History'**
  String get attendanceHistory;

  /// No description provided for @liveAttendance.
  ///
  /// In en, this message translates to:
  /// **'Live Attendance'**
  String get liveAttendance;

  /// No description provided for @officeHours.
  ///
  /// In en, this message translates to:
  /// **'Office Hours'**
  String get officeHours;

  /// No description provided for @officeHoursTime.
  ///
  /// In en, this message translates to:
  /// **'08:00 AM - 05:00 PM'**
  String get officeHoursTime;

  /// No description provided for @faceScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Face Scan for {type}'**
  String faceScanTitle(String type);

  /// No description provided for @pointCameraToFace.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at your face'**
  String get pointCameraToFace;

  /// No description provided for @noCameraAvailable.
  ///
  /// In en, this message translates to:
  /// **'No camera available.'**
  String get noCameraAvailable;

  /// No description provided for @cameraInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize camera: {error}'**
  String cameraInitFailed(String error);

  /// No description provided for @faceDetectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Face detected! {type} process successful.'**
  String faceDetectedSuccess(String type);

  /// No description provided for @noFaceDetected.
  ///
  /// In en, this message translates to:
  /// **'No face detected. Please try again.'**
  String get noFaceDetected;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No description provided for @scanFace.
  ///
  /// In en, this message translates to:
  /// **'Scan Face'**
  String get scanFace;

  /// No description provided for @faceDataSection.
  ///
  /// In en, this message translates to:
  /// **'Face Data'**
  String get faceDataSection;

  /// No description provided for @getSelectedFaceData.
  ///
  /// In en, this message translates to:
  /// **'Get Data Selected Face'**
  String get getSelectedFaceData;

  /// No description provided for @personalizationSection.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalizationSection;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @passwordOrBiometric.
  ///
  /// In en, this message translates to:
  /// **'Password or biometric'**
  String get passwordOrBiometric;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterUsernameAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter username and password'**
  String get pleaseEnterUsernameAndPassword;

  /// No description provided for @invalidUsernameOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidUsernameOrPassword;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @confirmDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {username}?'**
  String confirmDeleteUser(String username);

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @employeeId.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employeeId;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @karyawan.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get karyawan;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @allEmployeeHistory.
  ///
  /// In en, this message translates to:
  /// **'All Employee History'**
  String get allEmployeeHistory;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
