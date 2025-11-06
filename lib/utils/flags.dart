String countryCodeToEmoji(String? code) {
  if (code == null || code.length != 2) return '';
  final upper = code.toUpperCase();
  final int base = 0x1F1E6;
  final int a = upper.codeUnitAt(0) - 0x41; // 'A'
  final int b = upper.codeUnitAt(1) - 0x41;
  return String.fromCharCode(base + a) + String.fromCharCode(base + b);
}


