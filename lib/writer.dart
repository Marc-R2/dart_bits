import 'dart:math';

import 'package:bits/bits.dart';

class DummyBitBufferWriter extends BitBufferWriter {
  DummyBitBufferWriter() : super(BitBuffer());

  @override
  void writeBits(int value, int bits) {
    if (bits < getBitsNeeded(value.abs())) {
      throw Exception(
          "Value $value is too large for $bits bits. You would need ${getBitsNeeded(value.abs())} bits to write $value. (or write up to ${pow(2, bits) - 1}) bits");
    }
    _i(bits);
  }

  @override
  void writeBit(bool state) => _i();
}

class BitBufferWriter {
  int _written = 0;
  final BitBuffer _buffer;

  BitBuffer get buffer => _buffer;

  BitBufferWriter(this._buffer);

  void seek(int position) {
    _written = position;
    if (_written > _buffer.getSize()) {
      _buffer.allocate(_written - _buffer.getSize());
    }
  }

  int getBitsWritten() => _written;

  int _i([int f = 1]) {
    int t = _written;
    _written += f;
    return t;
  }

  void allocateIfNeeded(int bits) {
    if (_written + bits > _buffer.getSize()) {
      _buffer.allocate(bits);
    }
  }

  void writeString(String value) {
    writeInt(value.length, bits: 32, signed: false);
    for (int i = 0; i < value.length; i++) {
      writeInt(value.codeUnitAt(i), signed: false, bits: 16);
    }
  }

  void writeLinearVarString(String value) {
    writeLinearVarInt(value.length, maxBits: 32, signed: false);
    for (int i = 0; i < value.length; i++) {
      writeLinearVarInt(value.codeUnitAt(i), signed: false, maxBits: 16);
    }
  }

  void writeSteppedVarString(String value, {List<int> steps = stepCharList1b}) {
    writeLinearVarInt(value.length, maxBits: 32, signed: false);
    for (int i = 0; i < value.length; i++) {
      writeSteppedVarInt(value.codeUnitAt(i), signed: false, bitLimits: steps);
    }
  }

  void writeBits(int value, int bits) {
    if (bits < getBitsNeeded(value.abs())) {
      throw Exception(
          "Value $value is too large for $bits bits. You would need ${getBitsNeeded(value.abs())} bits to write $value. (or write up to ${pow(2, bits) - 1}) bits");
    }

    allocateIfNeeded(bits);
    _buffer.setBits(_i(bits), bits, value);
  }

  void writeBit(bool state) {
    allocateIfNeeded(1);
    _buffer.setBit(_i(), state);
  }

  void writeCodec<T>(BitCodec<T> method, T value) => method.writer(this, value);

  void writeLinearVarDouble(double value,
      {bool signed = true, int maxBits = 64, int maxDecimal = 8}) {
    if (signed) {
      writeBit(value > 0);
    }
    writeLinearVarInt(value.truncate().abs(), signed: false, maxBits: maxBits);
    double decimal = double.parse(
        (value.abs() - value.truncate().abs()).toStringAsFixed(maxDecimal));
    int exponent = 0;

    while (decimal != decimal.truncate() && exponent < maxDecimal) {
      exponent++;
      decimal *= 10;
    }

    writeLinearVarInt(exponent,
        signed: false, maxBits: getBitsNeeded(maxDecimal));
    writeLinearVarInt(decimal.truncate(),
        signed: false, maxBits: getMaxBitsNeededForDigits(maxDecimal));
  }

  void writeSteppedVarDouble(double value,
      {bool signed = true,
      List<int> bitLimits = stepList2b,
      List<int> decimalBitLimits = stepDecList2b}) {
    if (signed) {
      writeBit(value > 0);
    }
    int maxDecimal = pow(2, decimalBitLimits.last).toInt() - 1;
    writeSteppedVarInt(value.truncate().abs(),
        signed: false, bitLimits: bitLimits);
    double decimal = double.parse(
        (value.abs() - value.truncate().abs()).toStringAsFixed(maxDecimal));
    int exponent = 0;

    while (decimal != decimal.truncate() && exponent < maxDecimal) {
      exponent++;
      decimal *= 10;
    }

    writeSteppedVarInt(exponent, signed: false, bitLimits: decimalBitLimits);
    writeInt(decimal.truncate(),
        signed: false,
        bits: getMaxBitsNeededForDigits(
            pow(2, decimalBitLimits[findBitStep(exponent, decimalBitLimits)])
                    .toInt() -
                1));
  }

  void writeDouble(double value,
      {bool signed = true, int bits = 64, int maxDecimal = 8}) {
    if (signed) {
      writeBit(value > 0);
    }
    writeInt(value.truncate().abs(), signed: false, bits: bits);
    double decimal = double.parse(
        (value.abs() - value.truncate().abs()).toStringAsFixed(maxDecimal));
    int exponent = 0;

    while (decimal != decimal.truncate() && exponent < maxDecimal) {
      exponent++;
      decimal *= 10;
    }

    writeInt(exponent, signed: false, bits: getBitsNeeded(maxDecimal));
    writeInt(decimal.truncate(),
        signed: false, bits: getMaxBitsNeededForDigits(maxDecimal));
  }

  void writeSteppedVarInt(int value,
      {bool signed = true, List<int> bitLimits = stepList2b}) {
    if (signed) {
      writeBit(value > 0);
    }

    int step = findBitStep(value, bitLimits);

    if (step == -1) {
      throw new Exception("Value too large");
    }

    writeInt(step, signed: false, bits: getBitsNeeded(bitLimits.length - 1));
    writeInt(value.abs(), signed: false, bits: bitLimits[step]);
  }

  void writeLinearVarInt(int value, {bool signed = true, int maxBits = 64}) {
    int bits = getBitsNeeded(value.abs());
    writeInt(bits, signed: false, bits: getBitsNeeded(maxBits));
    writeInt(value, signed: signed, bits: bits);
  }

  void writeInt(int value, {bool signed = true, int bits = 64}) {
    if (signed) {
      writeBit(value > 0);
    }
    writeBits(value.abs(), bits);
  }
}
