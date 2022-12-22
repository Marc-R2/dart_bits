import 'dart:math';

import 'package:bits/bits.dart';
import 'package:test/test.dart';

void main() {
  for (double iff = 1; iff < 123456; iff *= 2.3456789123456789) {
    for (int t = 1; t < 9; t += 3) {
      final double i = iff - (123456 / 2);
      final double it = BitBuffer.truncate(i, t);
      test('Write VarDouble ${i} with $t precision', () {
        BitBuffer buf = BitBuffer();
        buf.writeDouble(i, maxPrecision: t);
        double out = buf.readDouble(maxPrecision: t);
        expect(out, equals(it),
            reason:
                'Reading VarDouble ${it}, got ${out} instead (truncated to ${t} digits)');
        expect(buf.getAvailableBits(), equals(0),
            reason:
                'Reading VarDouble had leftover bits from write! (truncated to ${t} digits)');
      });
    }
  }

  for (int i = 1; i < 123456; i *= 3) {
    test('Write UInt ${i}', () {
      BitBuffer buf = BitBuffer();
      buf.writeInt(i, signed: false);
      int out = buf.readInt(signed: false);
      expect(out, equals(i), reason: 'Reading UInt ${i}, got ${out} instead');
      expect(buf.getAvailableBits(), equals(0),
          reason: 'Reading UInt had leftover bits from write!');
    });

    test('Write Int ${i}', () {
      BitBuffer buf = BitBuffer();
      buf.writeInt(i);
      int out = buf.readInt();
      expect(out, equals(i), reason: 'Reading Int ${i}, got ${out} instead');
      expect(buf.getAvailableBits(), equals(0),
          reason: 'Reading Int had leftover bits from write!');
    });

    test('Write VarUInt ${i}', () {
      BitBuffer buf = BitBuffer();
      buf.writeVarInt(i, signed: false);
      int out = buf.readVarInt(signed: false);
      expect(out, equals(i),
          reason: 'Reading VarUInt ${i}, got ${out} instead');
      expect(buf.getAvailableBits(), equals(0),
          reason: 'Reading VarUInt had leftover bits from write!');
    });

    test('Write VarInt ${i}', () {
      BitBuffer buf = BitBuffer();
      buf.writeVarInt(i);
      int out = buf.readVarInt();
      expect(out, equals(i), reason: 'Reading VarInt ${i}, got ${out} instead');
      expect(buf.getAvailableBits(), equals(0),
          reason: 'Reading VarInt had leftover bits from write!');
    });

    test('Write VarInt ${-i}', () {
      BitBuffer buf = BitBuffer();
      buf.writeVarInt(-i);
      int out = buf.readVarInt();
      expect(out, equals(-i),
          reason: 'Reading VarInt ${-i}, got ${out} instead');
      expect(buf.getAvailableBits(), equals(0),
          reason: 'Reading VarInt had leftover bits from write!');
    });
  }

  test('VarUIntLists', () {
    BitBuffer buf = BitBuffer();
    List<int> ints = randomInts(4).map((e) => e.abs()).toList();
    buf.writeVarInts(ints, signed: false);
    List<int> out = buf.readVarInts(signed: false);
    expect(out, equals(ints),
        reason: 'Reading VarUInts ${ints}, got ${out} instead');
  });

  test('VarIntLists', () {
    BitBuffer buf = BitBuffer();
    List<int> ints = randomInts(4).toList();
    buf.writeVarInts(ints);
    List<int> out = buf.readVarInts();
    expect(out, equals(ints),
        reason: 'Reading VarInts ${ints}, got ${out} instead');
  });

  test('BitBuffer to/from base64', () {
    BitBuffer buf = newRandomBuffer();
    expect(
        BitBuffer.fromBase64(buf.toBase64()).toBase64(), equals(buf.toBase64()),
        reason: 'BitBuffer to/from base64 failed');
  });

  test('BitBuffer to/from compressedBase64', () {
    BitBuffer buf = newRandomBuffer();
    expect(
        BitBuffer.fromBase64Compressed(buf.toBase64Compressed())
            .toBase64Compressed(),
        equals(buf.toBase64Compressed()),
        reason: 'BitBuffer to/from compressedBase64 failed');
  });

  test('BitBuffer to/from bytes', () {
    BitBuffer buf = newRandomBuffer();
    expect(BitBuffer.fromBytes(buf.toBytes()).toBytes(), equals(buf.toBytes()),
        reason: 'BitBuffer to/from bytes failed');
  });

  test('BitBuffer to/from bytesBuilder', () {
    BitBuffer buf = newRandomBuffer();
    expect(
        BitBuffer.fromByteBuilder(buf.toByteBuilder())
            .toByteBuilder()
            .toBytes(),
        equals(buf.toByteBuilder().toBytes()),
        reason: 'BitBuffer to/from bytesBuilder failed');
  });

  test('BitBuffer to/from byteBuffer', () {
    BitBuffer buf = newRandomBuffer();
    expect(
        BitBuffer.fromByteBuffer(buf.toByteBuffer())
            .toByteBuffer()
            .asUint8List(),
        equals(buf.toByteBuffer().asUint8List()),
        reason: 'BitBuffer to/from byteBuffer failed');
  });

  test('BitBuffer to/from byteData', () {
    BitBuffer buf = newRandomBuffer();
    expect(
        BitBuffer.fromByteData(buf.toByteData())
            .toByteData()
            .buffer
            .asUint8List(),
        equals(buf.toByteData().buffer.asUint8List()),
        reason: 'BitBuffer to/from byteData failed');
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

BitBuffer newRandomBuffer() {
  BitBuffer buf = BitBuffer();
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
