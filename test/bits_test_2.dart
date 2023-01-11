import 'dart:math';

import 'package:bits/bit_buffer.dart';
import 'package:bits/bits.dart';
import 'package:test/test.dart';

void main() {
  List<int> testInts = [
    0,
    1,
    -1,
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

  test('Basic Copying & Loading & Exporting', () {
    int v = -23495995555553;
    BitBuffer buf = BitBuffer();
    buf.writer().writeInt(v);
    buf.writer().writeInt(-v * 33);
    buf.writer().writeInt(16);
    BitBuffer buf2 = BitBuffer.fromBB(buf);
    expect(buf2.getLongs(), equals(buf.getLongs()));
  });

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
