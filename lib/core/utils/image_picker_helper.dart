import 'dart:typed_data';

import 'image_picker_helper_stub.dart'
    if (dart.library.js_interop) 'image_picker_helper_web.dart' as impl;

typedef PickedImageData = ({Uint8List bytes, String name});

/// Returns true on platforms that support native file/image picking without extra plugins.
bool get isDeviceImagePickerSupported => impl.isDeviceImagePickerSupportedImpl;

/// Opens a file chooser on supported platforms and returns the chosen image bytes & file name.
Future<PickedImageData?> pickImageBytes() => impl.pickImageBytesImpl();

