// The dashboard runs on the web; the stub keeps `flutter test` (Dart VM) compiling.
export 'file_download_stub.dart'
    if (dart.library.js_interop) 'file_download_web.dart';
