import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bits/bits.dart';
import 'package:threshold/threshold.dart';

const int bitsPerInt = 64;
const List<int> stepIntLow4_16 = [3, 5, 8, 16];
const List<int> stepList1b = [32, 64];
const List<int> stepCharList1b = [7, 16];
const List<int> stepList2b = [8, 16, 32, 64];
const List<int> stepDecList1b = [2, 4];
const List<int> stepDecList2b = [1, 2, 3, 4];

int findBitStep(int value, List<int> bitSteps) {
  int step = -1;
  for (int i = 0; i < bitSteps.length; i++) {
    if (getBitsNeeded(value.abs()) <= bitSteps[i]) {
      step = i;
      break;
    }
  }

  return step;
}

int getMaxBitsNeededForDigits(int decimals) =>
    getBitsNeeded(int.parse("9" * decimals));

int getBitsNeeded(int value) {
  assert(value >= 0, "Value must be positive");
  int bits = 0;
  while (value > 0) {
    value >>= 1;
    bits++;
  }
  return max(1, bits);
}

class BitBuffer {
  int _size = 0;
  List<int> _longs = [];

  BitBuffer();

  BitBufferWriter writer() => BitBufferWriter(this);

  BitBufferWriter append() => writer()..seek(_size);

  BitBufferReader reader() => BitBufferReader(this);

  List<int> getLongs() => _longs.toList();

  String toBase64Compressed() => compress(toBase64());

  String toBase64() => base64Encode(toUInt8List());

  void trim() {
    while (getFreeBits() > bitsPerInt) {
      _longs.removeLast();
    }
  }

  Uint8List toUInt8List() {
    trim();
    BytesBuilder bb = BytesBuilder();
    for (int i = 0; i < getSize(); i += 8) {
      bb.addByte(getBits(i, min(8, getSize() - i)));
    }

    return bb.toBytes();
  }

  factory BitBuffer.fromBase64Compressed(String compressed) =>
      BitBuffer.fromUInt8List(base64Decode(decompress(compressed)));

  factory BitBuffer.fromBase64(String compressed) =>
      BitBuffer.fromUInt8List(base64Decode(compressed));

  factory BitBuffer.fromBB(BitBuffer obb) => BitBuffer.fromBits(obb.getLongs(),
      bitsPerIndex: bitsPerInt, trueSize: obb._size);

  factory BitBuffer.fromUInt8List(List<int> bytes) =>
      BitBuffer.fromBits(bytes, bitsPerIndex: 8);

  factory BitBuffer.fromBits(List<int> data,
      {int bitsPerIndex = bitsPerInt, int? trueSize}) {
    BitBuffer bb = BitBuffer();
    BitBufferWriter w = bb.writer();
    for (int i in data) {
      w.writeBits(i, bitsPerIndex);
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
