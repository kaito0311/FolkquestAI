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
  String get voice => isEnglish ? 'Voice' : 'Giọng đọc';
  String get voiceHint => isEnglish
      ? 'Choose the voice used to read story text'
      : 'Chọn giọng dùng để đọc nội dung truyện';
  String get defaultVoice => isEnglish ? 'Device default' : 'Mặc định thiết bị';
  String get speechRate => isEnglish ? 'Reading speed' : 'Tốc độ đọc';
  String get speechRateHint => isEnglish
      ? 'Adjust how quickly story text is read'
      : 'Điều chỉnh tốc độ đọc nội dung truyện';
  String get small => isEnglish ? 'Small' : 'Nhỏ';
  String get medium => isEnglish ? 'Medium' : 'Trung bình';
  String get large => isEnglish ? 'Large' : 'Lớn';
  String get homeSubtitle =>
      isEnglish ? 'THE STARFRUIT TREE' : 'ĂN KHẾ TRẢ VÀNG';
  String get start => isEnglish ? 'Start' : 'Bắt đầu';
  String get collection => isEnglish ? 'Collection' : 'Bộ sưu tập';
  String get all => isEnglish ? 'All' : 'Tất cả';
  String get opened => isEnglish ? 'Opened' : 'Đã mở';
  String get locked => isEnglish ? 'Locked' : 'Chưa mở';
  String get collectionNote => isEnglish
      ? 'Collect items to discover\nthe story and hidden meanings.'
      : 'Thu thập để khám phá\ncâu chuyện và ý nghĩa ẩn giấu.';
  String get noOpenedItems => isEnglish
      ? 'You have not unlocked any items yet.'
      : 'Bạn chưa mở vật phẩm nào.';
  String get allItemsOpened => isEnglish
      ? 'You have unlocked every item.'
      : 'Bạn đã mở toàn bộ vật phẩm.';
  String get profile => isEnglish ? 'Profile' : 'Hồ sơ';
  String get guide => isEnglish ? 'Guide' : 'Hướng dẫn';
  String get signIn => isEnglish ? 'Sign in' : 'Đăng nhập';
  String get continueLabel => isEnglish ? 'Continue' : 'Tiếp tục';
  String get karma => isEnglish ? 'Karma' : 'Nghiệp lực';
  String get askMagicBird => isEnglish ? 'Ask the Magic Bird' : 'Hỏi Chim Thần';
  String get magicBird => isEnglish ? 'Magic Bird' : 'Chim Thần';
  String get ending => isEnglish ? 'Your ending' : 'Kết cục của bạn';
  String get keyChoices => isEnglish ? 'Key choices' : 'Những lựa chọn chính';
  String get noChoices => isEnglish ? 'No choices yet' : 'Chưa có lựa chọn';
  String get unlockedItems =>
      isEnglish ? 'Unlocked items' : 'Cổ vật đã mở khóa';
  String get unlocked => isEnglish ? 'Unlocked' : 'Đã mở khóa';
  String get viewCollection => isEnglish ? 'View collection' : 'Xem bộ sưu tập';
  String get playAgain => isEnglish ? 'Play again' : 'Chơi lại';
  String get mainMenu => isEnglish ? 'Main menu' : 'Về menu chính';
  String get continueStory =>
      isEnglish ? 'Continue the story' : 'Tiếp tục câu chuyện';
  String get magicBirdThinking => isEnglish
      ? 'The Magic Bird is thinking...'
      : 'Chim Thần đang suy nghĩ...';
  String get messageHint =>
      isEnglish ? 'Type a message...' : 'Nhập tin nhắn ...';
  String get birdGreeting => isEnglish
      ? 'I am the Magic Bird. I can answer your questions about this story. What would you like to ask?'
      : 'Ta là Chim Thần, ta sẽ giải đáp mọi thắc mắc của con. Con có muốn hỏi ta điều gì không?';
  String get pause => isEnglish ? 'Paused' : 'Tạm dừng';
  String get exit => isEnglish ? 'Exit' : 'Thoát';
  String get help => isEnglish ? 'Help' : 'Trợ giúp';
  String get information => isEnglish ? 'Information' : 'Thông tin';
  String get folkQuestPlayer =>
      isEnglish ? 'FolkQuest player' : 'Người chơi FolkQuest';
  String get notSignedInShort => isEnglish ? 'Not signed in' : 'Chưa đăng nhập';
  String get syncing => isEnglish ? 'Syncing' : 'Đang đồng bộ';
  String get localPlay => isEnglish ? 'Local play' : 'Chơi cục bộ';
  String get playCount => isEnglish ? 'Plays' : 'Lượt chơi';
  String get choices => isEnglish ? 'Choices' : 'Lựa chọn';
  String get items => isEnglish ? 'Items' : 'Vật phẩm';
  String get profileSyncedNote => isEnglish
      ? 'Your progress is saved with your account.'
      : 'Tiến trình của bạn đang được lưu cùng tài khoản.';
  String get profileLocalNote => isEnglish
      ? 'Sign in from the home screen to sync your progress.'
      : 'Đăng nhập ở màn hình chính để đồng bộ tiến trình.';
  String get resetGameData =>
      isEnglish ? 'Reset game data' : 'Đặt lại dữ liệu chơi';
  String get resetGameDataTitle =>
      isEnglish ? 'Reset all game progress?' : 'Đặt lại toàn bộ tiến trình?';
  String get resetGameDataMessage => isEnglish
      ? 'Your story progress, choices, karma, unlocked items, and play count will be reset. Account and app settings will be kept.'
      : 'Tiến trình truyện, lựa chọn, nghiệp lực, vật phẩm đã mở và số lượt chơi sẽ bị đặt lại. Tài khoản và cài đặt ứng dụng vẫn được giữ nguyên.';
  String get cancel => isEnglish ? 'Cancel' : 'Hủy';
  String get confirmReset => isEnglish ? 'Reset' : 'Đặt lại';
  String get gameDataResetSuccess =>
      isEnglish ? 'Game data has been reset.' : 'Đã đặt lại dữ liệu chơi.';
  String get gameDataResetError => isEnglish
      ? 'Could not reset game data. Please try again.'
      : 'Không thể đặt lại dữ liệu chơi. Vui lòng thử lại.';
  List<String> get birdPresetQuestions => isEnglish
      ? const [
          'Why a three-span bag?',
          'What lesson does the Magic Bird teach?',
          'How does greed affect us?',
        ]
      : const [
          'Vì sao phải là túi ba gang?',
          'Chim Thần muốn dạy con điều gì?',
          'Lòng tham ảnh hưởng thế nào?',
        ];
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get strings {
    final language = Localizations.localeOf(this).languageCode == 'en'
        ? AppLanguage.english
        : AppLanguage.vietnamese;
    return AppLocalizations(language);
  }
}
