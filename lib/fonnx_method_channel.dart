import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fonnx_platform_interface.dart';

/// An implementation of [FonnxPlatform] that uses method channels.
class MethodChannelFonnx extends FonnxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fonnx');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Create embeddings for [inputs].
  /// Inputs are BERT tokens. Use [WordpieceTokenizer] to convert a [String].
  @override
  Future<List<Float32List>?> miniLmL6V2({
    required String modelPath,
    required List<List<int>> inputs,
  }) async {
    final result = await methodChannel.invokeListMethod<Float32List>(
      'miniLmL6V2',
      [modelPath, inputs],
    );
    return result;
  }
}
