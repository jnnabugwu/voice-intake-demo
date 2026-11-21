import 'dart:convert';

/// One server-sent event: its name and its JSON data.
typedef SseEvent = ({String event, Map<String, dynamic> data});

/// Turns a byte stream into server-sent events. Events can arrive split
/// across chunks, or several in one chunk; both are handled. Only a block
/// closed by the blank-line delimiter is an event: a truncated tail (the
/// connection dropped mid-event) is discarded, so a half-sent `done` can't end
/// a reply. Malformed data becomes an empty map rather than an error.
Stream<SseEvent> parseSse(Stream<List<int>> bytes) async* {
  var buffer = '';
  await for (final text in bytes.transform(utf8.decoder)) {
    // Normalize the whole buffer, not the chunk: a CRLF can straddle two chunks.
    buffer = (buffer + text).replaceAll('\r\n', '\n');
    var end = buffer.indexOf('\n\n');
    while (end != -1) {
      final event = _parseBlock(buffer.substring(0, end));
      buffer = buffer.substring(end + 2);
      if (event != null) yield event;
      end = buffer.indexOf('\n\n');
    }
  }
}

SseEvent? _parseBlock(String block) {
  String? name;
  final data = StringBuffer();
  for (final line in block.split('\n')) {
    if (line.startsWith('event:')) name = line.substring(6).trim();
    if (line.startsWith('data:')) data.write(line.substring(5).trim());
  }
  if (name == null) return null;
  Map<String, dynamic> json;
  try {
    final decoded = data.isEmpty ? <String, dynamic>{} : jsonDecode(data.toString());
    json = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  } on FormatException {
    json = <String, dynamic>{};
  }
  return (event: name, data: json);
}
