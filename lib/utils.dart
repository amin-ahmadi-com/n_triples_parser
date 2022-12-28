String removeLastCharacter(String text) {
  if (text.isEmpty) return "";
  return text.substring(0, text.length - 1);
}
