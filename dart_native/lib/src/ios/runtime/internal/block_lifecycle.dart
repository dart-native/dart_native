import 'package:dart_native/src/ios/runtime/block.dart';

Map<int, Block> blockForSequence = {};

void removeBlockOnSequence(int seq) {
  Block block = blockForSequence[seq];
  if (block != null) {
    blockForSequence.remove(seq);
  }
}
