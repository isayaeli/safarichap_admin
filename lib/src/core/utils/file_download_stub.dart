/// Non-web builds (unit tests) have no browser download.
void downloadTextFile(
  String filename,
  String content, {
  String mimeType = 'text/csv',
}) {
  throw UnsupportedError('File downloads are only available on the web');
}
