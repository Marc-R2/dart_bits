import 'dart:math';
import 'dart:typed_data';

const int bitsPerInt = 64;

int getBitsNeeded(int value) {
  assert(value >= 0, "Value must be positive");
  int bits = 0;
  while (value > 0) {
    value >>= 1;
    bits++;
  }
  return max(1, bits);
}

class BitBufferWriter {
  int _written = 0;
  final BitBuffer _buffer;

  BitBufferWriter(this._buffer);

  int _i([int f = 1]) {
    int t = _written;
    _written += f;
    return t;
  }

  void writeBits(int value, int bits) {
    _buffer.allocate(bits);
    _buffer.setBits(_i(bits), bits, value);
  }

  void writeBit(bool state) {
    _buffer.allocate(1);
    _buffer.setBit(_i(), state);
  }

  void writeDouble(double value,
      {bool signed = true, int bits = 64, int decimalBits = 16}) {
    if (signed) {
      writeBit(value > 0);
    }
    writeInt(value.abs().truncate(), signed: false, bits: bits);
// dont write int just truncate thingy
    double v = value.abs() - value.abs().truncate();

    while (v != v.truncate() && getBitsNeeded(v.truncate()) <= decimalBits) {
      v *= 10;
    }

    writeInt(v.truncate(), signed: false, bits: decimalBits);
  }

  void writeInt(int value, {bool signed = true, int bits = 64}) {
    if (signed) {
      writeBit(bits > 0);
    }
    writeBits(value.abs(), bits);
  }
}

class BitBufferReader {
  int _read = 0;
  final BitBuffer _buffer;

  int _i([int f = 1]) {
    int t = _read;
    _read += f;
    return t;
  }

  double readDouble({bool signed = true, int bits = 64, int decimalBits = 16}) {
    double sign = signed
        ? !readBit()
            ? -1.0
            : 1.0
        : 1.0;
    double base = readInt(signed: false, bits: bits).toDouble();
    int m = readInt(signed: false, bits: decimalBits);
    base += m.toDouble() / pow(10, m.toString().length);
    return base * sign;
  }

  bool readBit() => _buffer.getBit(_i());

  int readBits(int bits) => _buffer.getBits(_i(bits), bits);

  int readInt({bool signed = true, int bits = 64}) =>
      (signed && !readBit()) ? -readBits(bits) : readBits(bits);

  BitBufferReader(this._buffer);
}

class BitBuffer {
  int _size = 0;
  List<int> _longs = [];

  BitBuffer();

  BitBufferWriter writer() => BitBufferWriter(this);

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
    for (int i = 0; i < bb._size; i++) {
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
