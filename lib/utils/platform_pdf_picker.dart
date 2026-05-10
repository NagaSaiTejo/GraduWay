// Conditional export: uses dart:html on web, stub on native platforms.
export 'pdf_picker_stub.dart'
    if (dart.library.html) 'pdf_picker_web.dart';
