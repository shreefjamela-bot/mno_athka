import 'dart:async';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<Uint8List?> pickImageFromCamera() async {
  try {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/*';
    input.setAttribute('capture', 'environment');
    input.click();
    input.onChange.listen((event) {
      final file = input.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoad.listen((e) => completer.complete(reader.result as Uint8List));
        reader.onError.listen((_) => completer.complete(null));
      } else {
        completer.complete(null);
      }
    });
    return await completer.future;
  } catch (e) {
    return null;
  }
}