import 'package:fonnx/tokenizers/embedding.dart';

import 'mini_lm_l6_v2_stub.dart'
    if (dart.library.io) 'mini_lm_l6_v2_native.dart'
    if (dart.library.js) 'mini_lm_l6_v2_web.dart';

abstract class MiniLmL6V2 {
  static MiniLmL6V2? _instance;

  static MiniLmL6V2 load(String path) {
    _instance ??= getMiniLmL6V2(path);
    return _instance!;
  }

  Future<List<TextAndEmbedding>> getEmbedding(String text);
}
