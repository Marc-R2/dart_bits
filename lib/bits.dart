library bits;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:threshold/threshold.dart';

void main() {
  List<double> m = [
    1.5555555555,
    2.2345345345,
    3.777456456,
    4.4445656456456,
    5.223434234234,
    6.4,
    7.3,
    8.2,
    9.1
  ];

  // Max precision = 4
  // 2.234
  // 2234 x10^3

  // 2234

  // 1011100100010111010
  // 000110101110010101011010010110101100011010111111

  print(m);
  BitBuffer buffer = BitBuffer();
  buffer.writeVarDoubles(m, maxPrecision: 1);
  print(buffer.toString());

  buffer = BitBuffer();
  buffer.writeVarDoubles(m, maxPrecision: 4);
  print(buffer.toString());

  buffer = BitBuffer();
  buffer.writeVarDoubles(m, maxPrecision: 8);
  print(buffer.toString());

  buffer = BitBuffer();
  buffer.writeVarDoubles(m, maxPrecision: 16);
  print(buffer.toString());
}

class BitBuffer {
  List<bool> _bits = [];

  BitBuffer();

  factory BitBuffer.fromString(String compressed) =>
      BitBuffer()..load(base64Decode(decompress(compressed)));

  void writeSign(int i) => _bits.add(i >= 0);

  bool readSign() => _bits.removeAt(0);

  void writeVarInt(int i) => (this..writeSign(i)).writeVarUInt(i.abs());

  int readVarInt() => readSign() ? readVarUInt() : -readVarUInt();

  String toString() => compress(base64Encode(toBytes().toBytes()));

  double readVarDouble({int maxPrecision = 8}) {
    int precision = readBits(getBitsNeeded(maxPrecision));
    return readVarInt().toDouble() / pow(10, precision).toDouble();
  }

  void writeVarDouble(double d, {int maxPrecision = 8}) {
    int moves = _getDecimalMoves(d, maxPrecision: maxPrecision);
    writeBits(moves, getBitsNeeded(getBitsNeeded(maxPrecision)));
    writeVarInt((d * pow(10, moves)).toInt());
  }

  int _getDecimalMoves(double d, {int maxPrecision = 8}) {
    if (d == d.toInt()) {
      return 0;
    }

    int g = 1;

    while (pow(10, g) * d != (pow(10, g) * d).toInt()) {
      g++;

      if (g > maxPrecision) {
        return 8;
      }
    }

    return g;
  }

  double readDouble32() =>
      (ByteData(4)..setInt32(0, readVarInt())).getFloat32(0);

  double readDouble64() =>
      (ByteData(8)..setInt64(0, readVarInt())).getFloat64(0);

  void writeDouble32(double d) =>
      writeVarInt((ByteData(4)..setFloat32(0, d)).getInt32(0));

  void writeDouble64(double d) =>
      writeVarInt((ByteData(8)..setFloat64(0, d)).getInt64(0));

  void load(List<int> bytes) {
    _bits = [];
    for (int i = 0; i < bytes.length; i++) {
      for (int j = 0; j < 8; j++) {
        _bits.add((bytes[i] & (1 << j)) != 0);
      }
    }
  }

  bool _getBit(int value, int bit) => (value & (1 << bit)) != 0;

  int _setBit(int value, int bit, bool on) =>
      on ? value | (1 << bit) : value & ~(1 << bit);

  void writeVarDoubles(List<double> m, {int maxPrecision = 8}) {
    writeVarUInt(m.length);
    for (int i = 0; i < m.length; i++) {
      writeVarDouble(m[i], maxPrecision: maxPrecision);
    }
  }

  List<double> readVarDoubles({int maxPrecision = 8}) {
    List<double> m = [];
    int length = readVarUInt();
    for (int i = 0; i < length; i++) {
      m.add(readVarDouble(maxPrecision: maxPrecision));
    }
    return m;
  }

  void writeVarInts(List<int> m) {
    int maxBits = m.map((i) => getBitsNeeded(i)).reduce(max);
    writeVarUInt(m.length);
    writeVarUInt(maxBits);
    for (int i = 0; i < m.length; i++) {
      writeSign(m[i]);
      writeBits(m[i], maxBits);
    }
  }

  List<int> readVarInts() {
    int count = readVarUInt();
    int maxBits = readVarUInt();
    List<int> m = [];
    for (int i = 0; i < count; i++) {
      m.add(readSign() ? readBits(maxBits) : -readBits(maxBits));
    }
    return m;
  }

  void writeVarUInts(List<int> m) {
    int maxBits = m.map((i) => getBitsNeeded(i)).reduce(max);
    writeVarUInt(m.length);
    writeVarUInt(maxBits);
    for (int i = 0; i < m.length; i++) {
      writeBits(m[i], maxBits);
    }
  }

  List<int> readVarUInts() {
    int count = readVarUInt();
    int maxBits = readVarUInt();
    List<int> m = [];
    for (int i = 0; i < count; i++) {
      m.add(readBits(maxBits));
    }
    return m;
  }

  int readVarUInt() {
    int indicator = readBits(2);
    int bits = 0;
    if (indicator == 0) {
      bits = 8;
    } else if (indicator == 1) {
      bits = 16;
    } else if (indicator == 2) {
      bits = 32;
    } else if (indicator == 3) {
      bits = 64;
    }
    return readBits(bits);
  }

  void writeVarUInt(int value) {
    int bits = getBitsNeeded(value);
    int indicator = 0;

    if (bits <= 8) {
      indicator = 0;
      bits = 8;
    } else if (bits <= 16) {
      indicator = 1;
      bits = 16;
    } else if (bits <= 32) {
      indicator = 2;
      bits = 32;
    } else if (bits <= 64) {
      indicator = 3;
      bits = 64;
    }

    writeBits(indicator, 2);
    writeBits(value, bits);
  }

  int readBits(int bits) {
    int value = 0;
    for (int i = 0; i < bits; i++) {
      value = _setBit(value, i, _bits[i]);
    }
    _bits = _bits.sublist(bits);
    return value;
  }

  int getBitsNeeded(int value) {
    int bits = 0;
    while (value > 0) {
      value >>= 1;
      bits++;
    }
    return bits;
  }

  void writeBits(int byte, int bits) {
    for (int i = 0; i < bits; i++) {
      _bits.add(_getBit(byte, i));
    }
  }

  BytesBuilder toBytes() {
    BytesBuilder builder = BytesBuilder();
    int byte = 0;
    int bits = 0;
    for (bool bit in _bits) {
      byte = _setBit(byte, bits, bit);
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
