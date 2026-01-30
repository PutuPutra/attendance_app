# Presensi Karyawan (Employee Attendance App)

A modern Flutter application for employee attendance tracking using face recognition technology. This app allows employees to check in/out using facial recognition and provides comprehensive attendance management features for both regular users and administrators.

## ✨ Features

### 👤 User Features

- **Face Recognition Check-in/Out**: Uses camera and Google ML Kit for secure face detection
- **Multiple Attendance Types**: Check In, Break Time, Return to Work, Check Out
- **Attendance History**: View personal attendance records
- **Real-time Clock**: Live display of current time and office hours
- **Persistent Login**: Automatic login session management

### 👨‍💼 Admin Features

- **User Management**: Add, edit, and manage employee accounts
- **All Employee History**: View attendance records for all employees
- **Comprehensive Reporting**: Monitor attendance across the organization

### 🎨 User Experience

- **Multi-language Support**: Indonesian and English languages
- **Theme Support**: Light, Dark, and System theme modes
- **Persistent Settings**: User preferences saved locally
- **Responsive Design**: Optimized for mobile devices

<!-- ## 📱 Screenshots

_Add screenshots of your app here_ -->

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.7 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Physical device or emulator with camera support

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/PutuPutra/attendance_app.git
   cd presensi_karyawan
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android APK:**

```bash
flutter build apk --release
```

**iOS (on macOS):**

```bash
flutter build ios --release
```

## 📖 Usage

### For Employees

1. **Login**: Enter your employee ID and password
2. **Check In/Out**: Tap the appropriate button and scan your face
3. **View History**: Check your attendance records in the history section
4. **Settings**: Customize language and theme preferences

### For Administrators

1. **Login** with admin credentials
2. **Manage Users**: Add new employees or modify existing accounts
3. **Monitor Attendance**: View attendance data for all employees
4. **System Settings**: Configure app-wide settings

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Face Detection**: Google ML Kit Face Detection
- **Camera**: Flutter Camera Plugin
- **Storage**: Shared Preferences
- **Localization**: Flutter Intl
- **State Management**: Flutter Built-in State Management

### Dependencies

- `camera: ^0.10.6` - Camera access
- `google_mlkit_face_detection: ^0.10.0` - Face detection
- `shared_preferences: ^2.2.3` - Local storage
- `intl: ^0.20.2` - Internationalization
- `path_provider: ^2.1.3` - File system access

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── home.dart                 # Main home screen
├── login_screen.dart         # Authentication screen
├── face_scan_screen.dart     # Face recognition interface
├── attendance_history.dart   # Personal attendance history
├── settings_screen.dart      # App settings
├── user_management_screen.dart    # Admin user management
├── all_employee_history_screen.dart # Admin attendance overview
├── models/
│   └── user.dart            # User data model
├── services/
│   └── user_service.dart    # User data management
└── l10n/                    # Localization files
    ├── app_en.arb          # English translations
    └── app_id.arb          # Indonesian translations
```

## 🌐 Localization

The app supports two languages:

- **Indonesian (id)** - Default language
- **English (en)** - Alternative language

Language settings are automatically saved and persist between app sessions.

## 🎨 Themes

Three theme modes are available:

- **System**: Follows device theme
- **Light**: Bright theme
- **Dark**: Dark theme

Theme preferences are saved locally using SharedPreferences.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support, email support@example.com or create an issue in this repository.

## 🙏 Acknowledgments

- Google ML Kit for face detection capabilities
- Flutter team for the amazing framework
- All contributors and testers
