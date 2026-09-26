enum AppLanguage {
  vietnamese('vi', 'Tiếng Việt'),
  english('en', 'English');

  const AppLanguage(this.languageCode, this.label);

  final String languageCode;
  final String label;

  static AppLanguage fromLanguageCode(String? value) =>
      AppLanguage.values.firstWhere(
        (language) => language.languageCode == value,
        orElse: () => AppLanguage.vietnamese,
      );
}
