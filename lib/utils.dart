String removeLastCharacters(String text, int count) {
  if (text.length < count) return "";
  return text.substring(0, text.length - count);
}

String removeFirstCharacters(String text, int count) {
  if (text.length < count) return "";
  return text.substring(count);
}
