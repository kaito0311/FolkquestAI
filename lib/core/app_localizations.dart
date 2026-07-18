import 'package:flutter/widgets.dart';

import 'package:fqa/models/app_language.dart';

/// Lightweight app copy localizer. Story content is selected separately by the
/// repository so it can retain its branching data and stable node ids.
class AppLocalizations {
  const AppLocalizations(this.language);

  final AppLanguage language;

  bool get isEnglish => language == AppLanguage.english;

  String get settings => isEnglish ? 'Settings' : 'Cài đặt';
  String get languageLabel => isEnglish ? 'Language' : 'Ngôn ngữ';
  String get languageHint => isEnglish
      ? 'Choose the language used in FolkQuest'
      : 'Chọn ngôn ngữ hiển thị trong FolkQuest';
  String get backgroundMusic => isEnglish ? 'Background music' : 'Nhạc nền';
  String get musicHint => isEnglish
      ? 'Turn in-game background music on or off'
      : 'Bật / tắt nhạc nền trong game';
  String get textSize => isEnglish ? 'Text size' : 'Kích thước chữ';
  String get textSizeHint => isEnglish
      ? 'Adjust the displayed text size'
      : 'Điều chỉnh kích thước chữ hiển thị';
  String get brightness => isEnglish ? 'Brightness' : 'Độ sáng';
  String get brightnessHint =>
      isEnglish ? 'Adjust screen brightness' : 'Điều chỉnh độ sáng màn hình';
  String get about => isEnglish ? 'About the app' : 'Giới thiệu ứng dụng';
  String get aboutHint => isEnglish
      ? 'Learn more about FolkQuest AI'
      : 'Tìm hiểu thêm về FolkQuest AI';
  String get restoreDefaults =>
      isEnglish ? 'Restore defaults' : 'Khôi phục mặc định';
  String get restoreDefaultsHint => isEnglish
      ? 'Reset all settings to their defaults'
      : 'Đưa tất cả cài đặt về mặc định ban đầu';
  String get signOut => isEnglish ? 'Sign out' : 'Đăng xuất';
  String get notSignedIn => isEnglish
      ? 'Not signed in to a Google account'
      : 'Chưa đăng nhập tài khoản Google';
  String get signOutHint => isEnglish
      ? 'Sign out of the current account'
      : 'Đăng xuất khỏi tài khoản hiện tại';
  String get syncingProgress =>
      isEnglish ? 'Syncing progress' : 'Đang đồng bộ tiến trình';
  String get back => isEnglish ? 'Back' : 'Quay lại';
  String get version => isEnglish ? 'version 1.0.0' : 'phiên bản 1.0.0';
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get strings {
    final language = Localizations.localeOf(this).languageCode == 'en'
        ? AppLanguage.english
        : AppLanguage.vietnamese;
    return AppLocalizations(language);
  }
}
