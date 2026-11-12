/// Cleans user text so that keyword matching works for Bangla and English.
class TextNormalizer {
  TextNormalizer._();

  static final RegExp _zeroWidth = RegExp('[\u200B-\u200D\uFEFF]');
  static final RegExp _notWord = RegExp(r'[^\p{L}\p{N}\p{M}\s]', unicode: true);
  static final RegExp _spaces = RegExp(r'\s+');

  /// Lowercase, fix Bangla letter forms, turn Bangla digits into 0-9,
  /// replace punctuation with spaces and collapse extra spaces.
  static String normalize(String input) {
    var text = input.toLowerCase().replaceAll(_zeroWidth, '');

    // Bangla "য়, ড়, ঢ়" can be typed as two characters. Use one form.
    text = text
        .replaceAll('\u09AF\u09BC', '\u09DF')
        .replaceAll('\u09A1\u09BC', '\u09DC')
        .replaceAll('\u09A2\u09BC', '\u09DD');

    text = String.fromCharCodes(
      text.runes.map((code) {
        if (code >= 0x09E6 && code <= 0x09EF) return code - 0x09E6 + 0x30;
        return code;
      }),
    );

    return text.replaceAll(_notWord, ' ').replaceAll(_spaces, ' ').trim();
  }

  /// True if [text] contains [keyword]. English keywords must start at a
  /// word start ("ear pain" does not match "heart pain"). Bangla keywords
  /// match anywhere, so "জ্বরে" still matches "জ্বর".
  static bool containsPhrase(String text, String keyword) {
    if (keyword.isEmpty) return false;
    final isAscii = keyword.codeUnits.every((c) => c < 128);
    if (!isAscii) return text.contains(keyword);
    return RegExp('(^|\\s)${RegExp.escape(keyword)}').hasMatch(text);
  }
}
