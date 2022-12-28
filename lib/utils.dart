/// Convenience method to remove a given number of characters from the end of a
/// string
String removeLastCharacters(String text, int count) {
  if (text.length < count) return "";
  return text.substring(0, text.length - count);
}

/// Convenience method to remove a given number of characters from the beginning
/// of a string
String removeFirstCharacters(String text, int count) {
  if (text.length < count) return "";
  return text.substring(count);
}
