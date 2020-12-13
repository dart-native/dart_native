import 'package:dart_native/src/ios/runtime/block.dart';

Map<int, Block> blockForAddress = {};

void removeBlockOnAddress(int addr) {
  Block block = blockForAddress[addr];
  if (block != null) {
    blockForAddress.remove(addr);
  }
}
