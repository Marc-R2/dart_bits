library bits;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:threshold/threshold.dart';

void main() {
  BitBuffer buf = BitBuffer();
  List<int> set = [3, 8];

  buf.writeVarInt(7, steps: set, signed: false);
  buf.writeVarInt(3, steps: set, signed: false);
  buf.writeVarInt(211, steps: set, signed: false);

  print(buf.getAvailableBits());
  print(buf.toString());
}

const List<int> _bits4x8_64 = [8, 16, 32, 64];
const List<int> _bits4xLIST = [2, 7, 10, 64];
const List<int> _bits8xLOW = [2, 5, 8, 9, 10, 13, 24, 64];
const List<int> _bits4xLOW = [3, 8, 13, 64];
const List<int> _bits2x32_64 = [32, 64];
const List<int> _bits2x16_32 = [16, 32];
const List<int> _defaultSteps = _bits4x8_64;

const List<List<int>> _defaultPackedSet = [
  _bits4x8_64,
  _bits4xLOW,
  _bits8xLOW,
];

const List<List<int>> _listPackedSet = [
  _bits4x8_64,
  _bits4xLIST,
  _bits8xLOW,
];

class BitEvent<T> {
  final BitValueReader<T> reader;
  final BitValueWriter<T> writer;

  BitEvent({required this.reader, required this.writer});
}

typedef BitValueReader<T> = T Function();
typedef BitValueWriter<T> = void Function(T value);

class BitInteger extends BitEvent<int> {
  BitInteger(
      {required BitValueReader<int> reader,
      required BitValueWriter<int> writer})
      : super(reader: reader, writer: writer);
}

class BitDouble extends BitEvent<double> {
  BitDouble(
      {required BitValueReader<double> reader,
      required BitValueWriter<double> writer})
      : super(reader: reader, writer: writer);
}

class BitPlan {
  List<BitEvent> events = [];

  BitPlan();

  BitPlan write(BitEvent<dynamic> k) {
    events.add(k);
    return this;
  }

  Iterable<int> pullInts() sync* {
    for (var e in events) {
      if (e is BitInteger) {
        yield e.reader();
      }
    }
  }

  Iterable<double> pullDoubles() sync* {
    for (var e in events) {
      if (e is BitDouble) {
        yield e.reader();
      }
    }
  }
}

class BitBuffer {
  List<bool> _bits = [];

  BitBuffer();

  factory BitBuffer.fromBytes(List<int> bytes) => BitBuffer().._setBytes(bytes);

  factory BitBuffer.fromByteBuilder(BytesBuilder builder) =>
      BitBuffer.fromBytes(builder.toBytes());

  factory BitBuffer.fromByteBuffer(ByteBuffer buffer) =>
      BitBuffer.fromBytes(buffer.asUint8List());

  factory BitBuffer.fromByteData(ByteData data) =>
      BitBuffer.fromByteBuffer(data.buffer);

  factory BitBuffer.fromBase64Compressed(String compressed) =>
      BitBuffer.fromBytes(base64Decode(decompress(compressed)));

  factory BitBuffer.fromBase64(String compressed) =>
      BitBuffer.fromBytes(base64Decode(compressed));

  void writePackedVarInt(int i,
      {bool signed = true, List<List<int>> stepSet = _defaultPackedSet}) {
    int bits = getBitsNeeded(i.abs());
    BitBuffer a = BitBuffer();
    a.writeBits(1, 2); // 1 = packed
    a.writeBits(bits, 6);
    a.writeBits(i.abs(), bits);
    if (signed) {
      a.writeSign(i);
    }

    BitBuffer b = BitBuffer();
    b.writeBits(0, 2);
    b.writeVarInt(i, signed: signed, steps: stepSet[0]);

    BitBuffer c = BitBuffer();
    c.writeBits(2, 2);
    c.writeVarInt(i, signed: signed, steps: stepSet[1]);

    BitBuffer d = BitBuffer();
    d.writeBits(3, 2);
    d.writeVarInt(i, signed: signed, steps: stepSet[2]);
    List<BitBuffer> bx = [a, b, c, d];
    addBits(bx
        .reduce((a, b) => a.getAvailableBits() < b.getAvailableBits() ? a : b)
        ._bits);
  }

  int readPackedVarInt(
      {bool signed = true, List<List<int>> stepSet = _defaultPackedSet}) {
    int type = read(2);
    if (type == 0) {
      return readVarInt(signed: signed, steps: stepSet[0]);
    } else if (type == 1) {
      int bits = read(6);
      int i = read(bits);
      return signed
          ? readSign()
              ? i
              : -i
          : i;
    } else if (type == 2) {
      return readVarInt(signed: signed, steps: stepSet[1]);
    } else if (type == 3) {
      return readVarInt(signed: signed, steps: stepSet[2]);
    } else {
      throw Exception("Invalid type");
    }
  }

  void addBits(List<bool> bits) {
    _bits.addAll(bits);
  }

  void addBit(bool bit) {
    _bits.add(bit);
  }

  List<bool> readBits(int count) {
    var bits = _bits.sublist(0, count);
    _bits = _bits.sublist(count);
    return bits;
  }

  int readInt(
          {bool signed = true, List<List<int>> stepSet = _defaultPackedSet}) =>
      readPackedVarInt(signed: signed, stepSet: stepSet);

  void writeInt(int i,
          {bool signed = true, List<List<int>> stepSet = _defaultPackedSet}) =>
      writePackedVarInt(i, signed: signed, stepSet: stepSet);

  bool hasAvailableBits(int minimum) => _bits.length >= minimum;

  int getAvailableBits() => _bits.length;

  void writeSign(int i) => _bits.add(i >= 0);

  bool readSign() => _bits.removeAt(0);

  String toString() => toBase64Compressed();

  void writeDouble(double dd,
      {int maxPrecision = 8, List<int> steps = _defaultSteps}) {
    assert(maxPrecision <= 15, "maxPrecision must be <= 15");
    double d = truncate(dd, maxPrecision);
    int moves = _getDecimalMoves(d, maxPrecision: maxPrecision);
    writeBits(moves, getBitsNeeded(maxPrecision));
    writeVarInt((d * pow(10, moves)).toInt(), steps: steps);
  }

  double readDouble({int maxPrecision = 8, List<int> steps = _defaultSteps}) {
    assert(maxPrecision <= 15, "maxPrecision must be <= 15");
    int precision = read(getBitsNeeded(maxPrecision));
    return readVarInt(steps: steps).toDouble() / pow(10, precision).toDouble();
  }

  static double truncate(double d, int precision) {
    int fac = pow(10, precision).toInt();
    return (d * fac).toInt() / fac;
  }

  int _getDecimalMoves(double d, {int maxPrecision = 8}) {
    assert(maxPrecision <= 15, "maxPrecision must be <= 15");
    if (d == d.toInt()) {
      return 0;
    }

    int g = 1;

    while (pow(10, g) * d != (pow(10, g) * d).toInt()) {
      g++;

      if (g > maxPrecision) {
        return maxPrecision;
      }
    }

    return g;
  }

  void _setBytes(List<int> bytes) {
    _bits = [];
    for (int i = 0; i < bytes.length; i++) {
      for (int j = 0; j < 8; j++) {
        _bits.add((bytes[i] & (1 << j)) != 0);
      }
    }
  }

  static double lerp(double a, double b, double t) => a + (b - a) * t;

  static int lerpBits(int minBits, int maxBits, double t) =>
      minBits + ((maxBits - minBits) * t).round();

  static List<int> genStepSet({int? minValue, int? maxValue, int steps = 4}) {
    int minBits = max(minValue == null ? 1 : getBitsNeeded(minValue), 1);
    int maxBits = max(maxValue == null ? 64 : getBitsNeeded(maxValue), 2);
    int stepSize = (maxBits - minBits) ~/ steps;
    List<int> stepSet = [];
    for (int i = 0; i < steps; i++) {
      stepSet.add(minBits + (stepSize * i));
    }

    return stepSet;
  }

  static List<int> genLowStepSet(
      {int? minValue, int? softMaxValue, int? maxValue, int steps = 4}) {
    int minBits = max(minValue == null ? 1 : getBitsNeeded(minValue), 1);
    int maxBits =
        max(softMaxValue == null ? 64 : getBitsNeeded(softMaxValue), 2);
    int maxBits2 = max(maxValue == null ? 64 : getBitsNeeded(maxValue), 2);
    int stepSize = (maxBits - minBits) ~/ (steps - 1);
    List<int> stepSet = [];
    for (int i = 0; i < (steps - 1); i++) {
      stepSet.add(minBits + (stepSize * i));
    }

    stepSet[stepSet.length - 1] = maxBits2;

    return stepSet;
  }

  static bool getBit(int value, int bit) => (value & (1 << bit)) != 0;

  static int setBit(int value, int bit, bool on) =>
      on ? value | (1 << bit) : value & ~(1 << bit);

  String toBase64Compressed() => compress(toBase64());

  String toBase64() => base64Encode(toBytes());

  void writeVarInts(Iterable<int> m, {bool signed = true}) {
    int maxBits = m.map((i) => getBitsNeeded(i.abs())).reduce(max);
    writeInt(m.length, signed: false, stepSet: _listPackedSet);
    writeInt(maxBits, signed: false);
    m.forEach((i) {
      if (signed) {
        writeSign(i);
      }
      writeBits(i.abs(), maxBits);
    });
  }

  List<int> readVarInts({bool signed = true}) {
    int count = readInt(signed: false, stepSet: _listPackedSet);
    int maxBits = readInt(signed: false);
    List<int> m = [];
    for (int i = 0; i < count; i++) {
      m.add(signed
          ? readSign()
              ? read(maxBits)
              : -read(maxBits)
          : read(maxBits));
    }
    return m;
  }

  void writeVarInt(int value,
      {List<int> steps = _defaultSteps, bool signed = true}) {
    if (signed) {
      writeSign(value);
    }

    int groupBitsNeeded = getBitsNeeded(steps.length);
    int bitsNeeded = getBitsNeeded(value.abs());
    for (int i = 0; i < steps.length; i++) {
      if (bitsNeeded <= steps[i]) {
        writeBits(i, groupBitsNeeded);
        writeBits(value.abs(), steps[i]);
        return;
      }
    }
    throw Exception(
        "Value too large for max bits! $value needs $bitsNeeded but the max is ${steps.last}, all steps are $steps");
  }

  int readVarInt({List<int> steps = _defaultSteps, bool signed = true}) {
    bool sign = signed ? readSign() : true;
    int groupBitsNeeded = getBitsNeeded(steps.length);
    int group = read(groupBitsNeeded);
    int bitsNeeded = steps[group];
    int value = read(bitsNeeded);
    return sign ? value : -value;
  }

  int read(int bits) {
    assert(bits >= 1, "Bits must be 1 or more");
    if (!hasAvailableBits(bits)) {
      throw Exception(
          "Not enough bits available! Trying to read $bits, but only ${_bits.length} available!");
    }

    int value = 0;
    for (int i = 0; i < bits; i++) {
      value = setBit(value, i, _bits[i]);
    }
    _bits = _bits.sublist(bits);
    return value;
  }

  static int getBitsNeeded(int value) {
    assert(value >= 0, "Value must be positive");
    int bits = 0;
    while (value > 0) {
      value >>= 1;
      bits++;
    }
    return bits;
  }

  void writeBits(int byte, int bits) {
    assert(byte >= 0, "byte must be positive");
    assert(bits >= 0, "Bit size must be positive");
    for (int i = 0; i < bits; i++) {
      _bits.add(getBit(byte, i));
    }
  }

  ByteBuffer toByteBuffer() => toBytes().buffer;

  ByteData toByteData() {
    Uint8List b = toBytes();

    ByteData data = ByteData(b.length);
    for (int i = 0; i < b.length; i++) {
      data.setInt8(i, b[i]);
    }

    return data;
  }

  Uint8List toBytes() => toByteBuilder().toBytes();

  BytesBuilder toByteBuilder() {
    BytesBuilder builder = BytesBuilder();
    int byte = 0;
    int bits = 0;
    for (bool bit in _bits) {
      byte = setBit(byte, bits, bit);
      bits++;
      if (bits == 8) {
        builder.addByte(byte);
        byte = 0;
        bits = 0;
      }
    }

    if (bits > 0) {
      builder.addByte(byte);
    }

    return builder;
  }
}
