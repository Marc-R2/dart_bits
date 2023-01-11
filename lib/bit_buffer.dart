import 'dart:math';
import 'dart:typed_data';

const int bitsPerInt = 64;
const List<int> stepList1b = [32, 64];
const List<int> stepList2b = [8, 16, 32, 64];
const List<int> stepDecList1b = [2, 4];
const List<int> stepDecList2b = [1, 2, 3, 4];

int _bitStep(int value, List<int> bitSteps) {
  int step = -1;
  for (int i = 0; i < bitSteps.length; i++) {
    if (_getBitsNeeded(value.abs()) <= bitSteps[i]) {
      step = i;
      break;
    }
  }

  return step;
}

int _getMaxBitsNeededForDigits(int decimals) =>
    _getBitsNeeded(int.parse("9" * decimals));

int _getBitsNeeded(int value) {
  assert(value >= 0, "Value must be positive");
  int bits = 0;
  while (value > 0) {
    value >>= 1;
    bits++;
  }
  return max(1, bits);
}

class DummyBitBufferWriter extends BitBufferWriter {
  DummyBitBufferWriter() : super(BitBuffer());

  @override
  void writeBits(int value, int bits) => _i(bits);

  @override
  void writeBit(bool state) => _i();
}

typedef BitCodecWriter<T> = void Function(BitBufferWriter writer, T t);
typedef BitCodecReader<T> = T Function(BitBufferReader reader);

class BitCodec<T> {
  final BitCodecWriter<T> writer;
  final BitCodecReader<T> reader;

  BitCodec({required this.writer, required this.reader});
}

class BitBufferWriter {
  int _written = 0;
  final BitBuffer _buffer;

  BitBufferWriter(this._buffer);

  void seek(int position) {
    _written = position;
    if (_written > _buffer._size) {
      _buffer.allocate(_written - _buffer._size);
    }
  }

  int getBitsWritten() => _written;

  int _i([int f = 1]) {
    int t = _written;
    _written += f;
    return t;
  }

  void allocateIfNeeded(int bits) {
    if (_written + bits > _buffer._size) {
      _buffer.allocate(bits);
    }
  }

  void writeBits(int value, int bits) {
    if (bits < _getBitsNeeded(value.abs())) {
      throw Exception(
          "Value $value is too large for $bits bits. You would need ${_getBitsNeeded(value.abs())} bits to write $value. (or write up to ${pow(2, bits) - 1}) bits");
    }

    allocateIfNeeded(bits);
    _buffer.setBits(_i(bits), bits, value);
  }

  void writeBit(bool state) {
    allocateIfNeeded(1);
    _buffer.setBit(_i(), state);
  }

  void writeBestCodec<T>(List<BitCodec<T>> codecs, T value) {
    int bestCodec = getBestCodec(codecs, value);
    writeInt(bestCodec, signed: false, bits: _getBitsNeeded(codecs.length - 1));
    writeCodec(codecs[bestCodec], value);
  }

  int getBestCodec<T>(List<BitCodec<T>> codecs, T value) {
    int smallest = -1;
    int bestCodec = -1;

    for (int i = 0; i < codecs.length; i++) {
      int size = getCodecWrittenSize(codecs[i], value);

      if (size < 0) {
        continue;
      }

      if (smallest == -1 || size < smallest) {
        smallest = size;
        bestCodec = i;
      }
    }

    if (bestCodec == -1) {
      throw Exception("No codec could write $value");
    }

    return bestCodec;
  }

  void writeCodec<T>(BitCodec<T> method, T value) => method.writer(this, value);

  int getCodecWrittenSize<T>(BitCodec<T> method, T value) {
    try {
      return (DummyBitBufferWriter()..writeCodec(method, value))
          .getBitsWritten();
    } catch (e) {
      return -1;
    }
  }

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
        signed: false, maxBits: _getBitsNeeded(maxDecimal));
    writeLinearVarInt(decimal.truncate(),
        signed: false, maxBits: _getMaxBitsNeededForDigits(maxDecimal));
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
        bits: _getMaxBitsNeededForDigits(
            pow(2, decimalBitLimits[_bitStep(exponent, decimalBitLimits)])
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

    writeInt(exponent, signed: false, bits: _getBitsNeeded(maxDecimal));
    writeInt(decimal.truncate(),
        signed: false, bits: _getMaxBitsNeededForDigits(maxDecimal));
  }

  void writeSteppedVarInt(int value,
      {bool signed = true, List<int> bitLimits = stepList2b}) {
    if (signed) {
      writeBit(value > 0);
    }

    int step = _bitStep(value, bitLimits);

    if (step == -1) {
      throw new Exception("Value too large");
    }

    writeInt(step, signed: false, bits: _getBitsNeeded(bitLimits.length - 1));
    writeInt(value.abs(), signed: false, bits: bitLimits[step]);
  }

  void writeLinearVarInt(int value, {bool signed = true, int maxBits = 64}) {
    if (signed) {
      writeBit(value > 0);
    }
    int bits = _getBitsNeeded(value.abs());
    writeInt(bits, signed: false, bits: _getBitsNeeded(maxBits));
    writeInt(value.abs(), signed: false, bits: bits);
  }

  void writeInt(int value, {bool signed = true, int bits = 64}) {
    if (signed) {
      writeBit(value > 0);
    }
    writeBits(value.abs(), bits);
  }
}

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

  T readBestCodec<T>(List<BitCodec<T>> codecs) => readCodec(
      codecs[readInt(signed: false, bits: _getBitsNeeded(codecs.length - 1))]);

  T readCodec<T>(BitCodec<T> method) => method.reader(this);

  double readDouble({bool signed = true, int bits = 64, int maxDecimal = 8}) {
    double sign = signed
        ? !readBit()
            ? -1.0
            : 1.0
        : 1.0;
    double base = readInt(signed: false, bits: bits).toDouble();
    int exponent = readInt(signed: false, bits: _getBitsNeeded(maxDecimal));
    int decimal =
        readInt(signed: false, bits: _getMaxBitsNeededForDigits(maxDecimal));
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
    int step = _bitStep(exponent, decimalBitLimits);
    int decimal = readInt(
        signed: false,
        bits: _getMaxBitsNeededForDigits(
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
        readLinearVarInt(signed: false, maxBits: _getBitsNeeded(maxDecimal));
    int decimal = readLinearVarInt(
        signed: false, maxBits: _getMaxBitsNeededForDigits(maxDecimal));
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
        readInt(signed: false, bits: _getBitsNeeded(bitLimits.length - 1));
    return sign * readInt(signed: false, bits: bitLimits[step]);
  }

  int readLinearVarInt({bool signed = true, int maxBits = 64}) {
    int sign = signed
        ? !readBit()
            ? -1
            : 1
        : 1;
    int bits = readInt(signed: false, bits: _getBitsNeeded(maxBits));
    return sign * readInt(signed: false, bits: bits);
  }

  int readInt({bool signed = true, int bits = 64}) =>
      (signed && !readBit()) ? -readBits(bits) : readBits(bits);

  BitBufferReader(this._buffer);
}

class BitBuffer {
  int _size = 0;
  List<int> _longs = [];

  BitBuffer();

  BitBufferWriter writer() => BitBufferWriter(this);

  BitBufferWriter append() => writer()..seek(_size);

  BitBufferReader reader() => BitBufferReader(this);

  List<int> getLongs() => _longs.toList();

  Uint8List toUInt8List() {
    BytesBuilder bb = BytesBuilder();
    for (int i = 0; i < getSize() / 8; i += 8) {
      bb.addByte(getBits(i, 8));
    }

    return bb.toBytes();
  }

  factory BitBuffer.fromBB(BitBuffer obb) => BitBuffer.fromBits(obb.getLongs(),
      bitsPerIndex: bitsPerInt, trueSize: obb._size);

  factory BitBuffer.fromUInt8List(List<int> bytes) =>
      BitBuffer.fromBits(bytes, bitsPerIndex: 8);

  factory BitBuffer.fromBits(List<int> data,
      {int bitsPerIndex = bitsPerInt, int? trueSize}) {
    BitBuffer bb = BitBuffer();
    bb.allocate(trueSize ?? data.length * bitsPerIndex);
    for (int i = 0; i < bb._size - 1; i++) {
      int localBit = i & (bitsPerIndex - 1);
      int localIndex = i >> bitsPerIndex;
      bb.setBit(i, data[localIndex] & (1 << localBit) != 0);
    }
    return bb;
  }

  int getFreeBits() => (_longs.length * bitsPerInt) - getSize();

  void allocate(int bits) {
    int free = getFreeBits();
    if (free > 0) {
      _size += free;
      bits -= free;
    }

    while (bits > 0) {
      _size += min(bits, bitsPerInt);
      bits = max(bits - bitsPerInt, 0);
      _longs.add(0);
    }

    _size += bits;
  }

  void printBinary() => printBinarySection(0, getSize());

  void printBinarySection(int start, int length) {
    int end = min(start + (length), getSize());
    String s = "";
    for (int i = start; i < end; i++) {
      s += (getBit(i) ? "1" : "0");
    }
    print(s + " (" + s.length.toString() + " bits)");
  }

  int getSize() => _size;

  int getStartingBitForSize(int bits) => getSize() - (bits - 1);

  int getStartingBitForIndex(int index) => index * bitsPerInt;

  int getLocalBit(int globalBit) => globalBit & (bitsPerInt - 1);

  int getIndexForBit(int globalBit) => globalBit ~/ bitsPerInt;

  void setBits(int start, int bits, int value) {
    for (int i = 0; i < bits; i++) {
      setBit(start + i, value & (1 << i) != 0);
    }
  }

  int getBits(int start, int bits) {
    int value = 0;
    for (int i = 0; i < bits; i++) {
      value |= (getBit(start + i) ? 1 : 0) << i;
    }
    return value;
  }

  bool getBit(int globalBit) =>
      _longs[getIndexForBit(globalBit)] & (1 << getLocalBit(globalBit)) != 0;

  void setBit(int globalBit, bool state) => state
      ? _longs[getIndexForBit(globalBit)] |= (1 << getLocalBit(globalBit))
      : _longs[getIndexForBit(globalBit)] &= ~(1 << getLocalBit(globalBit));
}
