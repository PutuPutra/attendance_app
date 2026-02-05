// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Welcome';

  @override
  String get attendance => 'Attendance';

  @override
  String get companyName => 'Login to your account';

  @override
  String get employee => 'Employee';

  @override
  String get attendanceRecord => 'Attendance';

  @override
  String get checkIn => 'Check In';

  @override
  String get breakTime => 'Break';

  @override
  String get returnToWork => 'Return';

  @override
  String get checkOut => 'Check Out';

  @override
  String get leave => 'Leave';

  @override
  String get settings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get changePassword => 'Change Password';

  @override
  String get faceSaved => 'Face Saved';

  @override
  String get noFaceDataSaved => 'No face data saved.';

  @override
  String faceFeaturesCount(Object count) {
    return 'Face features: $count values';
  }

  @override
  String get getPersonalFaceData => 'Get Personal Face Data';

  @override
  String get clearAllFaceData => 'Clear All Face Data';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Logout';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Are you sure you want to delete all face data?';

  @override
  String get dataDeleted => 'Face data has been deleted.';

  @override
  String get notImplemented => 'This feature is not yet implemented.';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get attendanceHistory => 'Attendance History';

  @override
  String get liveAttendance => 'Live Attendance';

  @override
  String get officeHours => 'Office Hours';

  @override
  String get officeHoursTime => '08:00 AM - 05:00 PM';

  @override
  String faceScanTitle(String type) {
    return 'Face Scan for $type';
  }

  @override
  String get pointCameraToFace => 'Point the camera at your face';

  @override
  String get noCameraAvailable => 'No camera available.';

  @override
  String cameraInitFailed(String error) {
    return 'Failed to initialize camera: $error';
  }

  @override
  String faceDetectedSuccess(String type) {
    return 'Face detected! $type process successful.';
  }

  @override
  String get noFaceDetected => 'No face detected. Please try again.';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get scanFace => 'Scan Face';

  @override
  String get faceDataSection => 'Face Data';

  @override
  String get getSelectedFaceData => 'Get Data Selected Face';

  @override
  String get personalizationSection => 'Personalization';

  @override
  String get themeLabel => 'Theme';

  @override
  String get languageLabel => 'Language';

  @override
  String get generalSection => 'General';

  @override
  String get passwordOrBiometric => 'Login with biometric';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get login => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get incorrectOldPassword => 'Incorrect old password';

  @override
  String get pleaseEnterUsernameAndPassword =>
      'Please enter username and password';

  @override
  String get invalidUsernameOrPassword => 'Invalid username or password';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get userManagement => 'User Management';

  @override
  String get manageUsers => 'Manage Users';

  @override
  String get deleteUser => 'Delete User';

  @override
  String confirmDeleteUser(String username) {
    return 'Are you sure you want to delete $username?';
  }

  @override
  String get editUser => 'Edit User';

  @override
  String get addUser => 'Add User';

  @override
  String get employeeId => 'Employee ID';

  @override
  String get email => 'Email';

  @override
  String get role => 'Role';

  @override
  String get admin => 'Admin';

  @override
  String get karyawan => 'Employee';

  @override
  String get update => 'Update';

  @override
  String get allEmployeeHistory => 'All Employee History';

  @override
  String get fontStyle => 'Font Style';

  @override
  String get systemFont => 'System';

  @override
  String get appFont => 'App Default';

  @override
  String get selectDateRangeTitle => 'Select Date Range for Attendance History';

  @override
  String get selectStartDate => 'Select Start Date';

  @override
  String get selectEndDate => 'Select End Date';

  @override
  String get startLabel => 'Start: ';

  @override
  String get endLabel => 'End: ';

  @override
  String get pleaseSelectBothDates => 'Please select both start and end dates';

  @override
  String get apply => 'Apply';

  @override
  String get lookStraight => 'Look straight at the camera';

  @override
  String get turnRight => 'Turn your head to the right';

  @override
  String get turnLeft => 'Turn your head to the left';

  @override
  String get lookDown => 'Look down';

  @override
  String get lookUp => 'Look up';

  @override
  String get positionCorrect => 'Position correct, capturing...';

  @override
  String get enterFaceName => 'Enter a name for this face';

  @override
  String get faceName => 'Face Name';

  @override
  String get save => 'Save';

  @override
  String belumWaktunya(String type) {
    return 'It\'s not time yet for $type';
  }

  @override
  String get proceedAnyway => 'Proceed Anyway';
}
