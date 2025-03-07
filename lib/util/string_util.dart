String keepWord(text) {
  final RegExp emoji = RegExp(
    r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
  );
  String fullText = '';
  List<String> words = text.split(' ');
  for (var i = 0; i < words.length; i++) {
    fullText +=
        emoji.hasMatch(words[i])
            ? words[i]
            : words[i].replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D');
    if (i < words.length - 1) fullText += ' ';
  }
  return fullText;
}
