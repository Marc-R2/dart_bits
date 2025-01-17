import 'dart:math';

import 'package:bits/bits.dart';
import 'package:test/test.dart';

void main() {
  List<int> testInts = [
    0,
    1,
    -1,
    3,
    2,
    3854,
    -3346,
    1234567890,
    -1234567890,
    2147483647,
    -2147483748,
    4294967295,
    -4294967295,
    9223372036854775807,
    -922337203685477580
  ];
  List<double> testDoubles = [
    0,
    1,
    -1,
    0.1,
    3.5584,
    2.345666,
    2838455.12,
    29345588585.1118,
    -28388383838383.7771
  ];

  test('Palettes', () {
    List<String> data = [
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "noise",
      "noise",
      "ff",
      "sdds",
      "a",
      "c"
    ];
    BitCodec<String> codec = SingleBitCodec<String>(
      writer: (BitBufferWriter writer, String t) => writer.writeString(t),
      reader: (BitBufferReader reader) => reader.readString(),
    );

    PaletteData<String> p = PaletteData<String>(codec: codec);
    data.forEach((e) => p.write(e));
    BitBuffer buffer = p.toBitBuffer();
    PaletteData<String> p2 =
        PaletteData<String>.fromBitBuffer(codec: codec, buf: buffer);
    expect(data, equals(p2.getAllData()));
  });

  test('Basic Copying & Loading & Exporting', () {
    int v = -23495995555553;
    BitBuffer buf = BitBuffer();
    buf.writer().writeInt(v);
    buf.writer().writeInt(-v * 33);
    buf.writer().writeInt(16);
    BitBuffer buf2 = BitBuffer.fromBB(buf);
    expect(buf2.getLongs(), equals(buf.getLongs()));
  });

  test('To/from bytes', () {
    int v = -2349599555553;
    BitBuffer buf = BitBuffer();
    buf.writer().writeInt(v);
    buf.writer().writeInt(-v * 33);
    buf.writer().writeInt(16);
    BitBuffer buf2 = BitBuffer.fromUInt8List(buf.toUInt8List());
    expect(buf2.getLongs(), equals(buf.getLongs()));
  });

  test('To/from Strings', () {
    int v = -2349599555553;
    BitBuffer buf = BitBuffer();
    buf.writer().writeInt(v);
    buf.writer().writeInt(-v * 33);
    buf.writer().writeInt(16);
    BitBuffer buf2 = BitBuffer.fromBase64Compressed(buf.toBase64Compressed());
    expect(buf2.getLongs(), equals(buf.getLongs()));
  });
  String x =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+-=[]{};':\",./<>?`~";

  test(
      'Test writeString',
      () => expect(x,
          equals((BitBuffer()..writer().writeString(x)).reader().readString()),
          reason: 'Failed to readString ${x}'));

  for (int i = 0; i < 32; i++) {
    String s = List.generate(
            Random().nextInt(32) + 32, (index) => x[Random().nextInt(x.length)])
        .join();
    test(
        'Test writeString rng$i',
        () => expect(
            s,
            equals(
                (BitBuffer()..writer().writeString(s)).reader().readString()),
            reason: 'Failed to readString ${s}'));

    test(
        'Test writeLinearVarString rng$i',
        () => expect(
            s,
            equals((BitBuffer()..writer().writeLinearVarString(s))
                .reader()
                .readLinearVarString()),
            reason: 'Failed to readLinearVarString ${s}'));

    test(
        'Test writeSteppedVarString rng$i',
        () => expect(
            s,
            equals((BitBuffer()..writer().writeSteppedVarString(s))
                .reader()
                .readSteppedVarString()),
            reason: 'Failed to readSteppedVarString ${s}'));
  }

  test(
      'Test writeLinearVarString',
      () => expect(
          x,
          equals((BitBuffer()..writer().writeLinearVarString(x))
              .reader()
              .readLinearVarString()),
          reason: 'Failed to readLinearVarString ${x}'));

  test(
      'Test writeSteppedVarString',
      () => expect(
          x,
          equals((BitBuffer()..writer().writeSteppedVarString(x))
              .reader()
              .readSteppedVarString()),
          reason: 'Failed to readSteppedVarString ${x}'));

  for (double i in testDoubles) {
    test(
        'Test writeDouble',
        () => expect(
            i,
            equals(
                (BitBuffer()..writer().writeDouble(i)).reader().readDouble()),
            reason: 'Failed to writeDouble ${i}'));
    test(
        'Test writeUDouble',
        () => expect(
            i.abs(),
            equals((BitBuffer()..writer().writeDouble(i.abs(), signed: false))
                .reader()
                .readDouble(signed: false)),
            reason: 'Failed to writeDouble ${i.abs()}'));
    test(
        'Test writeLinearVarDouble',
        () => expect(
            i,
            equals((BitBuffer()..writer().writeLinearVarDouble(i))
                .reader()
                .readLinearVarDouble()),
            reason: 'Failed to writeDouble ${i}'));
    test(
        'Test writeSteppedVarDouble',
        () => expect(
            i,
            equals((BitBuffer()..writer().writeSteppedVarDouble(i))
                .reader()
                .readSteppedVarDouble()),
            reason: 'Failed to writeDouble ${i}'));
  }

  for (int id = 1; id < 63; id++) {
    for (int i = (-pow(2, id).toInt()) + 1;
        i < (pow(2, id).toInt()) - 1;
        i += ((pow(2, id).toInt() ~/ 4) + 1)) {
      test(
          'Test writeLinearVarInt with $id max bits',
          () => expect(
              i,
              equals((BitBuffer()..writer().writeLinearVarInt(i, maxBits: id))
                  .reader()
                  .readLinearVarInt(maxBits: id)),
              reason: 'Failed to writeLinearVarInt[$id max bits] ${i}'));
      test(
          'Test writeInt with $id max bits',
          () => expect(
              i,
              equals((BitBuffer()..writer().writeInt(i, bits: id))
                  .reader()
                  .readInt(bits: id)),
              reason: 'Failed to writeInt[$id bits] ${i}'));
    }
  }

  for (int i in testInts) {
    test(
        'Test writeInt',
        () => expect(
            i, equals((BitBuffer()..writer().writeInt(i)).reader().readInt()),
            reason: 'Failed to writeInt ${i}'));
    test(
        'Test writeUInt',
        () => expect(
            i.abs(),
            equals((BitBuffer()..writer().writeInt(i.abs(), signed: false))
                .reader()
                .readInt(signed: false)),
            reason: 'Failed to writeInt ${i.abs()}'));
    test(
        'Test writeLinearVarInt',
        () => expect(
            i,
            equals((BitBuffer()..writer().writeLinearVarInt(i))
                .reader()
                .readLinearVarInt()),
            reason: 'Failed to writeLinearVarInt ${i}'));
    test(
        'Test writeSteppedVarInt',
        () => expect(
            i,
            equals((BitBuffer()..writer().writeSteppedVarInt(i))
                .reader()
                .readSteppedVarInt()),
            reason: 'Failed to writeSteppedVarInt ${i}'));
  }

  test('Test BitBuffer.fromBB - expect copied Buffer to have same size', () {
    final buffer = BitBuffer();
    buffer.writer()
      ..writeInt(0x12345678)
      ..writeInt(0x87654321);

    final buffer2 = BitBuffer.fromBB(buffer);
    expect(buffer2.getSize(), equals(buffer.getSize()));
    expect(buffer2.endian, equals(buffer.endian));
    expect(buffer2.getLongs(), equals(buffer.getLongs()));
  });

  group('BitBufferWriter.writeBuffer', () {
    test('Test BitBufferWriter.writeBuffer', () {
      final buffer = BitBuffer();
      buffer.writer()
        ..writeInt(0x12345678)
        ..writeInt(0x87654321);

      final buffer2 = BitBuffer();
      buffer2.writer()
        ..writeInt(0x347865, bits: 42)
        ..writeBuffer(buffer);

      final reader = buffer2.reader();
      expect(reader.readInt(bits: 42), equals(0x347865));
      expect(reader.readInt(), equals(0x12345678));
      expect(reader.readInt(), equals(0x87654321));
      expect(buffer2.getSize(), equals(43 + 65 + 65));
    });

    test('writeBuffer writes entire buffer when no limit is set', () {
      final sourceBuffer = BitBuffer();
      final writer = BitBufferWriter(sourceBuffer);
      writer.writeInt(12345, bits: 32);
      writer.writeDouble(123.456, bits: 64);

      final targetBuffer = BitBuffer();
      final targetWriter = BitBufferWriter(targetBuffer);
      targetWriter.writeBuffer(sourceBuffer);

      final reader = targetBuffer.reader();
      expect(reader.readInt(bits: 32), 12345);
      expect(reader.readDouble(bits: 64), 123.456);
    });

    test('writeBuffer skips initial bytes when skip is set', () {
      final sourceBuffer = BitBuffer();
      final writer = BitBufferWriter(sourceBuffer);
      writer.writeInt(12345, bits: 32, signed: false);
      writer.writeDouble(123.456, bits: 64, signed: false);

      final targetBuffer = BitBuffer();
      final targetWriter = BitBufferWriter(targetBuffer);
      targetWriter.writeBuffer(sourceBuffer, skip: 32);

      final reader = targetBuffer.reader();
      expect(reader.readDouble(bits: 64, signed: false), 123.456);
    });

    test('writeBuffer respects limit when set', () {
      final sourceBuffer = BitBuffer();
      sourceBuffer.writer()
        ..writeInt(12345, bits: 32, signed: false)
        ..writeDouble(123.456, bits: 64, signed: false);

      final targetBuffer = BitBuffer();
      targetBuffer.writer().writeBuffer(sourceBuffer, limit: 32);

      final reader = targetBuffer.reader();
      expect(reader.readInt(bits: 32, signed: false), 12345);
      expect(() => reader.readDouble(bits: 64), throwsRangeError);
    });

    test('writeBuffer handles empty buffer', () {
      final sourceBuffer = BitBuffer();
      final targetBuffer = BitBuffer();

      targetBuffer.writer().writeBuffer(sourceBuffer);
      expect(targetBuffer.getSize(), 0);
    });
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
