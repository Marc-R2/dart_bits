import 'dart:convert';
import 'dart:math';

import 'package:bits/bit_buffer.dart';
import 'package:bits/bits.dart';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

void main() {
  test('Test', () {
    BitBuffer bb = BitBuffer();
    bb.writer().writeDouble(3.1111111111111);
    bb.printBinary();
    print(bb.reader().readDouble());
  });
}

Iterable<int> randomInts(int count) sync* {
  final random = Random();
  for (var i = 0; i < count; i++) {
    yield random.nextInt(0x100000000) * (random.nextBool() ? -1 : 1);
  }
}

Iterable<double> randomDoubles(int count) sync* {
  final random = Random();
  for (var i = 0; i < count; i++) {
    yield random.nextDouble() *
        212949.113456345634564 *
        (random.nextBool() ? -1 : 1);
  }
}

BitBufferOld newRandomBuffer() {
  BitBufferOld buf = BitBufferOld();
  buf.writeVarInt(Random().nextInt(10) - Random().nextInt(10));
  buf.writeVarInt(Random().nextInt(100) - Random().nextInt(100));
  buf.writeVarInt(Random().nextInt(1000) - Random().nextInt(1000));
  buf.writeVarInt(Random().nextInt(10000) - Random().nextInt(10000));
  buf.writeVarInt(Random().nextInt(100000) - Random().nextInt(100000));
  buf.writeVarInt(Random().nextInt(1000000) - Random().nextInt(1000000));
  buf.writeVarInt(Random().nextInt(10000000) - Random().nextInt(10000000));
  buf.writeVarInt(Random().nextInt(100000000) - Random().nextInt(100000000));
  return buf;
}
