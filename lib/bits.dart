library bits;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:threshold/threshold.dart';

void main() {
  BitBuffer buf = BitBuffer();
  
  print(buf.toString());
}

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

  void writePackedVarInt(int i) {
    int bits = getBitsNeeded(i.abs());
    BitBuffer a = BitBuffer();
    a.writeBits(1, 2); // 1 = packed
    a.writeBits(bits, 6);
    a.writeBits(i.abs(), bits);
    a.writeSign(i);

    BitBuffer b = BitBuffer();
    b.writeBits(0, 2); // 0 = varint
    b.writeVarInt(i);

    BitBuffer c = BitBuffer();
    c.writeBits(2, 2); // 2 = raw 32
    c.writeBits(i.abs(), 32);
    c.writeSign(i);

    BitBuffer d = BitBuffer();
    d.writeBits(3, 2); // 3 = raw 64
    d.writeBits(i.abs(), 64);
    d.writeSign(i);
    List<BitBuffer> bx = [a, b, if (bits <= 32) c, d];
    addBits(bx
        .reduce((a, b) => a.getAvailableBits() < b.getAvailableBits() ? a : b)
        ._bits);
  }

  int readPackedVarInt() {
    int type = read(2);
    if (type == 0) {
      return readVarInt();
    } else if (type == 1) {
      int bits = read(6);
      int i = read(bits);
      return readSign() ? i : -i;
    } else if (type == 2) {
      int i = read(32);
      return readSign() ? i : -i;
    } else if (type == 3) {
      int i = read(64);
      return readSign() ? i : -i;
    } else {
      throw Exception("Invalid type");
    }
  }

  void writePackedVarUInt(int i) {
    int bits = getBitsNeeded(i.abs());
    BitBuffer a = BitBuffer();
    a.writeBits(1, 2); // 1 = packed
    a.writeBits(bits, 6);
    a.writeBits(i, bits);
    BitBuffer b = BitBuffer();
    b.writeBits(0, 2); // 0 = varint
    b.writeVarUInt(i);
    BitBuffer c = BitBuffer();
    c.writeBits(2, 2); // 2 = raw 32
    c.writeBits(i, 32);
    BitBuffer d = BitBuffer();
    d.writeBits(3, 2); // 3 = raw 64
    d.writeBits(i, 64);
    addBits([a, b, c, d]
        .reduce((a, b) => a.getAvailableBits() < b.getAvailableBits() ? a : b)
        ._bits);
  }

  int readPackedVarUInt() {
    int type = read(2);
    if (type == 0) {
      return readVarUInt();
    } else if (type == 1) {
      int bits = read(6);
      int value = read(bits);
      return value;
    } else if (type == 2) {
      int value = read(32);
      return value;
    } else if (type == 3) {
      int value = read(64);
      return value;
    }
    return 0;
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

  int readInt() => readPackedVarInt();
  int readUInt() => readPackedVarUInt();

  void writeInt(int i) => writePackedVarInt(i);
  void writeUInt(int i) => writePackedVarUInt(i);

  bool hasAvailableBits(int minimum) => _bits.length >= minimum;

  int getAvailableBits() => _bits.length;

  void writeSign(int i) => _bits.add(i >= 0);

  bool readSign() => _bits.removeAt(0);

  int readISign() => _bits.removeAt(0) ? 1 : 0;

  void writeVarInt(int i) => (this..writeSign(i)).writeVarUInt(i.abs());

  int readVarInt() => readSign() ? readVarUInt() : -readVarUInt();

  String toString() => toBase64Compressed();

  void writeVarDouble(double dd, {int maxPrecision = 8}) {
    assert(maxPrecision <= 15, "maxPrecision must be <= 15");
    double d = truncate(dd, maxPrecision);
    int moves = _getDecimalMoves(d, maxPrecision: maxPrecision);
    writeBits(moves, getBitsNeeded(maxPrecision));
    writeInt((d * pow(10, moves)).toInt());
  }

  double readVarDouble({int maxPrecision = 8}) {
    assert(maxPrecision <= 15, "maxPrecision must be <= 15");
    int precision = read(getBitsNeeded(maxPrecision));
    return readInt().toDouble() / pow(10, precision).toDouble();
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

  double readDouble32() => (ByteData(4)..setInt32(0, readInt())).getFloat32(0);

  double readDouble64() => (ByteData(8)..setInt64(0, readInt())).getFloat64(0);

  void writeDouble32(double d) =>
      writeInt((ByteData(4)..setFloat32(0, d)).getInt32(0));

  void writeDouble64(double d) =>
      writeInt((ByteData(8)..setFloat64(0, d)).getInt64(0));

  void _setBytes(List<int> bytes) {
    _bits = [];
    for (int i = 0; i < bytes.length; i++) {
      for (int j = 0; j < 8; j++) {
        _bits.add((bytes[i] & (1 << j)) != 0);
      }
    }
  }

  static bool getBit(int value, int bit) => (value & (1 << bit)) != 0;

  static int setBit(int value, int bit, bool on) =>
      on ? value | (1 << bit) : value & ~(1 << bit);

  void writeVarDoubles(Iterable<double> m, {int maxPrecision = 8}) {
    assert(maxPrecision <= 15, "maxPrecision must be <= 15");
    writeVarUInt(m.length);
    m.forEach((element) => writeVarDouble(element, maxPrecision: maxPrecision));
  }

  String toBase64Compressed() => compress(toBase64());

  String toBase64() => base64Encode(toBytes());

  List<double> readVarDoubles({int maxPrecision = 8}) {
    assert(maxPrecision <= 15, "maxPrecision must be <= 15");
    List<double> m = [];
    int length = readVarUInt();
    for (int i = 0; i < length; i++) {
      m.add(readVarDouble(maxPrecision: maxPrecision));
    }
    return m;
  }

  void writeVarInts(Iterable<int> m) {
    int maxBits = m.map((i) => getBitsNeeded(i.abs())).reduce(max);
    writeVarUInt(m.length);
    writeVarUInt(maxBits);
    m.forEach((i) {
      writeSign(i);
      writeBits(i.abs(), maxBits);
    });
  }

  List<int> readVarInts() {
    int count = readVarUInt();
    int maxBits = readVarUInt();
    List<int> m = [];
    for (int i = 0; i < count; i++) {
      m.add(readSign() ? read(maxBits) : -read(maxBits));
    }
    return m;
  }

  void writeVarUInts(Iterable<int> m) {
    int maxBits = m.map((i) => getBitsNeeded(i)).reduce(max);
    writeVarUInt(m.length);
    writeVarUInt(maxBits);
    m.forEach((element) => writeBits(element, maxBits));
  }

  List<int> readVarUInts() {
    int count = readVarUInt();
    int maxBits = readVarUInt();
    List<int> m = [];
    for (int i = 0; i < count; i++) {
      m.add(read(maxBits));
    }
    return m;
  }

  int readVarUInt() {
    int indicator = read(2);
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
    return read(bits);
  }

  void writeVarUInt(int value) {
    assert(value >= 0, "Value must be positive");

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
