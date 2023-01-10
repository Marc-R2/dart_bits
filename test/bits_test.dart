import 'dart:convert';
import 'dart:math';

import 'package:bits/bits.dart';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

void main() {
  // Map<String, dynamic> j = {};
  //
  // for (int i = 0; i < 20; i++) {
  //   j["${i}"] = i;
  // }
  //
  // print(jsonEncode(j));
  // print(jsonEncode(compressJson(j)));
  // print(jsonEncode(decompressJson(compressJson(j))));
  //
  // print(
  //     "Input hash  is ${sha256.convert(utf8.encode(jsonEncode(j))).toString()}");
  // print(
  //     "Output hash is ${sha256.convert(utf8.encode(jsonEncode(decompressJson(compressJson(j))))).toString()}");
  // return;

  for (int i = 1; i < 512; i++) {
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

  test('Basic String', () {
    BitBuffer buf = BitBuffer();
    String s = 'Hello World!';
    buf.writeString(s);
    expect(s, equals(BitBuffer.fromBytes(buf.toBytes()).readString()),
        reason: 'BitBuffer String failed');
  });

  test('Complex String', () {
    String x = "abcdefghijklmnopqrstuvwxyz";
    String s =
        List.generate(1024, (index) => x[Random().nextInt(x.length)]).join();
    BitBuffer buf = BitBuffer();
    buf.writeString(s);
    expect(s, equals(BitBuffer.fromBytes(buf.toBytes()).readString()),
        reason: 'BitBuffer String failed');
  });

  test('Hypercomplex String', () {
    String x =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+-=[]{};':\",./<>?`~";
    String s =
        List.generate(2048, (index) => x[Random().nextInt(x.length)]).join();
    BitBuffer buf = BitBuffer();
    buf.writeString(s);
    expect(s, equals(BitBuffer.fromBytes(buf.toBytes()).readString()),
        reason: 'BitBuffer String failed');
  });

  test('Palette Data 2x', () {
    PaletteData<int> p = PaletteData<int>(
      writer: (buf, value) => buf.writeInt(value),
      reader: (buf) => buf.readInt(),
    );

    p.write(4);
    p.write(1);
    p.write(4);
    p.write(1);
    p.write(1);
    p.write(4);
    p.write(1);
    p.write(4);
    p.write(4);
    p.write(1);

    PaletteData<int> pp = PaletteData<int>.fromBitBuffer(
      buf: p.toBitBuffer(),
      writer: (buf, value) => buf.writeInt(value),
      reader: (buf) => buf.readInt(),
    );

    expect(pp.toBitBuffer().toBytes(), equals(p.toBitBuffer().toBytes()),
        reason: 'PaletteData to/from BitBuffer failed');
    expect(pp.getAllData(), equals(p.getAllData()),
        reason: "Palette Data failed not equal");
  });

  test('Palette Data', () {
    PaletteData<int> p = PaletteData<int>(
      writer: (buf, value) => buf.writeInt(value),
      reader: (buf) => buf.readInt(),
    );

    p.write(4);
    p.write(47);
    p.write(412123);
    p.write(4);
    p.write(7567);
    p.write(4);
    p.write(56756);
    p.write(-43546);

    PaletteData<int> pp = PaletteData<int>.fromBitBuffer(
      buf: p.toBitBuffer(),
      writer: (buf, value) => buf.writeInt(value),
      reader: (buf) => buf.readInt(),
    );

    expect(pp.toBitBuffer().toBytes(), equals(p.toBitBuffer().toBytes()),
        reason: 'PaletteData to/from BitBuffer failed');
    expect(pp.getAllData(), equals(p.getAllData()),
        reason: "Palette Data failed not equal");
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
