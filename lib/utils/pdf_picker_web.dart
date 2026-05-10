// Web implementation \u2014 uses dart:html to trigger a native browser file input.
// This always works on web because it directly creates an <input type="file"> element.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';

/// Opens a native browser PDF file picker.
/// Returns a map with 'name' and 'bytes', or null if cancelled.
/// Throws 'size_exceeded' if the file is larger than [maxBytes].
Future<Map<String, dynamic>?> pickPdfFilePlatform(int maxBytes) {
  final completer = Completer<Map<String, dynamic>?>();

  final input = html.FileUploadInputElement()
    ..accept = '.pdf,application/pdf';

  // Listen BEFORE clicking to avoid missing the event
  input.onChange.listen((_) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      completer.complete(null);
      return;
    }
    final file = files.first;

    if (file.size > maxBytes) {
      completer.completeError('size_exceeded');
      return;
    }

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

    reader.onLoad.listen((_) {
      // result is a ByteBuffer on web
      final data = reader.result;
      Uint8List bytes;
      if (data is Uint8List) {
        bytes = data;
      } else {
        bytes = Uint8List.fromList((data as List<dynamic>).cast<int>());
      }
      completer.complete({'name': file.name, 'bytes': bytes});
    });

    reader.onError.listen((_) => completer.complete(null));
  });

  // Clicking the hidden input triggers the browser's file chooser dialog
  input.click();

  return completer.future;
}
