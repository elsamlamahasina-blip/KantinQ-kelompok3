import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

@JS('document')
external _JSDocument get _document;

extension type _JSDocument(JSObject _) implements JSObject {
  external _JSInputElement createElement(String tagName);
}

extension type _JSInputElement(JSObject _) implements JSObject {
  external set type(String value);
  external set accept(String value);
  external set multiple(bool value);
  external set onchange(JSFunction? value);
  external set oncancel(JSFunction? value);
  external _JSFileList? get files;
  external void click();
}

extension type _JSFileList(JSObject _) implements JSObject {
  external int get length;
  external _JSFile? item(int index);
}

extension type _JSFile(JSObject _) implements JSObject {
  external String get name;
  external int get size;
  external JSPromise<JSArrayBuffer> arrayBuffer();
}

bool get isDeviceImagePickerSupportedImpl => true;

Future<({Uint8List bytes, String name})?> pickImageBytesImpl() async {
  final completer = Completer<({Uint8List bytes, String name})?>();
  final input = _document.createElement('input');
  input.type = 'file';
  input.accept = 'image/*';
  input.multiple = false;

  void finish(({Uint8List bytes, String name})? value) {
    input.onchange = null;
    input.oncancel = null;
    if (!completer.isCompleted) {
      completer.complete(value);
    }
  }

  input.oncancel = ((JSAny? _) {
    finish(null);
  }).toJS;

  Future<void> handleFileChange() async {
    try {
      final files = input.files;
      if (files == null || files.length == 0) {
        finish(null);
        return;
      }
      final file = files.item(0);
      if (file == null) {
        finish(null);
        return;
      }
      // Limit to 5 MB to protect in-memory browser storage
      if (file.size > 5 * 1024 * 1024) {
        finish(null);
        return;
      }
      final buffer = await file.arrayBuffer().toDart;
      final bytes = buffer.toDart.asUint8List();
      finish((bytes: bytes, name: file.name));
    } catch (_) {
      finish(null);
    }
  }

  input.onchange = ((JSAny? _) {
    unawaited(handleFileChange());
  }).toJS;

  input.click();
  return completer.future;
}

