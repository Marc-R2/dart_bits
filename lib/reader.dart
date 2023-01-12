import 'dart:math';

import 'package:bits/bits.dart';

class BitBufferReader {
  int _read = 0;
  final BitBuffer _buffer;

  void skip(int bits) => _read += bits;

  void seekTo(int bit) => _read = bit;

  int _i([int f = 1]) {
    int t = _read;
    _read += f;
    return t;
  }

  T readCodec<T>(BitCodec<T> method) => method.reader(this);

  double readDouble({bool signed = true, int bits = 64, int maxDecimal = 8}) {
    double sign = signed
        ? !readBit()
            ? -1.0
            : 1.0
        : 1.0;
    double base = readInt(signed: false, bits: bits).toDouble();
    int exponent = readInt(signed: false, bits: getBitsNeeded(maxDecimal));
    int decimal =
        readInt(signed: false, bits: getMaxBitsNeededForDigits(maxDecimal));
    return double.parse((sign * (base + (decimal / pow(10, exponent))))
        .toStringAsFixed(maxDecimal));
  }

  double readSteppedVarDouble(
      {bool signed = true,
      List<int> bitLimits = stepList2b,
      List<int> decimalBitLimits = stepDecList2b}) {
    double sign = signed
        ? !readBit()
            ? -1.0
            : 1.0
        : 1.0;

    int maxDecimal = pow(2, decimalBitLimits.last).toInt() - 1;
    double base =
        readSteppedVarInt(signed: false, bitLimits: bitLimits).toDouble();
    int exponent =
        readSteppedVarInt(signed: false, bitLimits: decimalBitLimits);
    int step = findBitStep(exponent, decimalBitLimits);
    int decimal = readInt(
        signed: false,
        bits: getMaxBitsNeededForDigits(
            pow(2, decimalBitLimits[step]).toInt() - 1));
    return double.parse((sign * (base + (decimal / pow(10, exponent))))
        .toStringAsFixed(maxDecimal));
  }

  double readLinearVarDouble(
      {bool signed = true, int maxBits = 64, int maxDecimal = 8}) {
    double sign = signed
        ? !readBit()
            ? -1.0
            : 1.0
        : 1.0;
    double base = readLinearVarInt(signed: false, maxBits: maxBits).toDouble();
    int exponent =
        readLinearVarInt(signed: false, maxBits: getBitsNeeded(maxDecimal));
    int decimal = readLinearVarInt(
        signed: false, maxBits: getMaxBitsNeededForDigits(maxDecimal));
    return double.parse((sign * (base + (decimal / pow(10, exponent))))
        .toStringAsFixed(maxDecimal));
  }

  bool readBit() => _buffer.getBit(_i());

  int readBits(int bits) => _buffer.getBits(_i(bits), bits);

  int readSteppedVarInt(
      {bool signed = true, List<int> bitLimits = stepList2b}) {
    int sign = signed
        ? !readBit()
            ? -1
            : 1
        : 1;
    int step =
        readInt(signed: false, bits: getBitsNeeded(bitLimits.length - 1));
    return sign * readInt(signed: false, bits: bitLimits[step]);
  }

  String readLinearVarString() {
    int length = readLinearVarInt(signed: false, maxBits: 32);
    String s = "";
    for (int i = 0; i < length; i++) {
      s += String.fromCharCode(readLinearVarInt(signed: false, maxBits: 16));
    }
    return s;
  }

  String readSteppedVarString({List<int> steps = stepCharList1b}) {
    int length = readLinearVarInt(signed: false, maxBits: 32);
    String s = "";
    for (int i = 0; i < length; i++) {
      s += String.fromCharCode(
          readSteppedVarInt(signed: false, bitLimits: steps));
    }
    return s;
  }

  String readString() {
    int length = readInt(signed: false, bits: 32);
    String s = "";
    for (int i = 0; i < length; i++) {
      s += String.fromCharCode(readInt(signed: false, bits: 16));
    }
    return s;
  }

  int readLinearVarInt({bool signed = true, int maxBits = 64}) => readInt(
      signed: signed,
      bits: readInt(signed: false, bits: getBitsNeeded(maxBits)));

  int readInt({bool signed = true, int bits = 64}) =>
      (signed && !readBit()) ? -readBits(bits) : readBits(bits);

  BitBufferReader(this._buffer);
}
