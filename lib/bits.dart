library bits;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:jpatch/jpatch.dart';
import 'package:threshold/threshold.dart';

const List<int> _bits4x8_64 = [8, 16, 32, 64];
const List<int> _bits4xLIST = [2, 7, 10, 64];
const List<int> _bits8xLOW = [2, 5, 8, 9, 10, 13, 24, 64];
const List<int> _bits4xLOW = [3, 8, 13, 64];
const List<int> _bits2xLOWx6 = [2, 6];
const List<int> _bits2x32_64 = [32, 64];
const List<int> _bits2x16_32 = [16, 32];
const List<int> _defaultSteps = _bits4x8_64;
const int initialPaletteBits = 3;
const int linearBitsLimit = 5;
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

typedef void BitWriter<T>(BitBufferOld buf, T value);

typedef T BitReader<T>(BitBufferOld buf);

class PaletteData<T> {
  final BitWriter<T> writer;
  final BitReader<T> reader;
  Palette<T> _palette = LinearPalette<T>();
  List<int> _out = [];

  List<T> getAllData() =>
      _out.map((e) => _palette.get(e)).toList(growable: false);

  List<int> getAllEntries() => _out.toList(growable: false);

  PaletteData({required this.writer, required this.reader});

  int getPaletteSize() => _palette.size();

  int getEntrySize() => _out.length;

  int getEntryBits() => BitBufferOld.getBitsNeeded(getPaletteSize() - 1);

  void write(T t) {
    int id = !_palette.contains(t) ? _grow(t) : _palette.idOf(t);

    if (!_palette.contains(t)) {
      _grow(t);
    }

    _out.add(id);
  }

  int _grow(T t) {
    if (_palette is LinearPalette<T> &&
        BitBufferOld.getBitsNeeded(_palette.size() + 1) > linearBitsLimit) {
      _palette = HashPalette<T>()..from(_palette);
    }

    return _palette.add(t);
  }

  factory PaletteData.fromBitBuffer(
      {required BitWriter<T> writer,
      required BitReader<T> reader,
      required BitBufferOld buf}) {
    PaletteData<T> data = PaletteData<T>(writer: writer, reader: reader);
    int paletteSize = buf.readInt(signed: false);

    for (int i = 0; i < paletteSize; i++) {
      data._palette.add(reader(buf));
    }

    int entrySize = buf.readInt(signed: false);
    for (int i = 0; i < entrySize; i++) {
      data._out.add(buf.read(data.getEntryBits()));
    }

    return data;
  }

  BitBufferOld toBitBuffer() {
    BitBufferOld buf = BitBufferOld();
    buf.writeInt(_palette.size(), signed: false); // TODO: Write Palette Size

    for (int i = 0; i < _palette.size(); i++) {
      writer(buf, _palette.get(i)); // TODO: Write Palette values
    }

    buf.writeInt(_out.length, signed: false); // TODO: Write Entry Size
    for (int i in _out) {
      buf.writeBits(i, getEntryBits()); // Write Palette Entry Values
    }

    return buf;
  }
}

abstract class Palette<T> {
  int idOf(T value);
  T get(int id);
  int size();
  bool contains(T value);
  int add(T value);
  void iterate(void Function(T value, int id) biConsumer);
  void from(Palette<T> other) => other.iterate((T value, int id) => add(value));
}

class LinearPalette<T> extends Palette<T> {
  final List<T> _list = [];

  @override
  int idOf(T value) => _list.indexOf(value);

  @override
  T get(int id) => _list[id];

  @override
  int size() => _list.length;

  @override
  bool contains(T value) => _list.contains(value);

  @override
  int add(T value) {
    if (!contains(value)) {
      int s = size();
      _list.add(value);
      return s;
    }

    return idOf(value);
  }

  @override
  void iterate(void Function(T value, int id) biConsumer) {
    for (int i = 0; i < _list.length; i++) {
      biConsumer(_list[i], i);
    }
  }
}

class HashPalette<T> extends Palette<T> {
  final Map<T, int> _palette = {};
  final Map<int, T> _lookup = {};
  int _size = 0;

  @override
  int idOf(T value) => _palette[value]!;

  @override
  T get(int id) => _lookup[id]!;

  @override
  int size() => _size;

  @override
  bool contains(T value) => _palette.containsKey(value);

  @override
  int add(T value) {
    if (!contains(value)) {
      int id = _size++;
      _palette[value] = id;
      _lookup[id] = value;
      return id;
    }

    return idOf(value);
  }

  @override
  void iterate(void Function(T value, int id) biConsumer) {
    for (int i = 0; i < _size; i++) {
      biConsumer(_lookup[i]!, i);
    }
  }
}

class BitLogger {
  Map<String, String> values = {};
  Map<String, int> sections = {};

  void log(String name, int postBitsWritten, dynamic value) {
    values["$name$postBitsWritten"] = "$value";
    sections["$name$postBitsWritten"] = postBitsWritten;
  }

  void printExplainedBinary(BitBufferOld buffer) {
    String bu = "";
    String bits = buffer.toLiteralBinary();
    List<int> sects = sections.values.toList();
    sects.sort();
    int prev = 0;
    for (int i in sects) {
      String key =
          sections.keys.firstWhere((element) => sections[element] == i);
      bu += "${bits.substring(prev, i)} ";
      print("[${prev + 1}-$i = ${i - prev}]: ${key} (${values[key]})");
      prev = i;
    }
    print(bu);
  }
}

class BitBufferOld {
  bool debug = false;
  List<bool> _bits = [];

  BitBufferOld();

  factory BitBufferOld.fromBytes(Uint8List bytes) =>
      BitBufferOld().._setBytes(bytes);

  factory BitBufferOld.fromByteBuilder(BytesBuilder builder) =>
      BitBufferOld.fromBytes(builder.toBytes());

  factory BitBufferOld.fromByteBuffer(ByteBuffer buffer) =>
      BitBufferOld.fromBytes(buffer.asUint8List());

  factory BitBufferOld.fromByteData(ByteData data) =>
      BitBufferOld.fromByteBuffer(data.buffer);

  factory BitBufferOld.fromBase64Compressed(String compressed) =>
      BitBufferOld.fromBytes(base64Decode(decompress(compressed)));

  factory BitBufferOld.fromBase64(String compressed) =>
      BitBufferOld.fromBytes(base64Decode(compressed));

  String toLiteralBinary() => _bits.map((e) => e ? '1' : '0').join();

  void writeByteArray(Uint8List list, {bool writeSize = true}) {
    if (writeSize) {
      writeInt(list.lengthInBytes, signed: false);
    }

    for (int i = 0; i < list.lengthInBytes; i++) {
      writeInt(list[i], signed: false);
    }

    print("Wrorte " + list.lengthInBytes.toString() + " bytes");
  }

  Uint8List readByteArray([int? bytes]) {
    bytes ??= readInt(signed: false);
    Uint8List list = Uint8List(bytes);
    for (int i = 0; i < bytes; i++) {
      list[i] = read(8);
    }
    return list;
  }

  String readString() => readBit()
      ? String.fromCharCodes(PaletteData<int>.fromBitBuffer(
              buf: this,
              writer: (buf, value) =>
                  buf.writeVarInt(value, signed: false, steps: _bits4xLOW),
              reader: (buf) => buf.readVarInt(signed: false, steps: _bits4xLOW))
          .getAllData())
      : String.fromCharCodes(List.generate(readInt(signed: false),
          (index) => readVarInt(signed: false, steps: _bits4xLOW)));

  void writeString(String text) {
    BitBufferOld buf = BitBufferOld();
    buf.writeInt(text.length, signed: false);
    text.codeUnits.forEach((element) =>
        buf.writeVarInt(element, signed: false, steps: _bits4xLOW));

    PaletteData<int> stringWriter = PaletteData<int>(
        writer: (BitBufferOld buf, int value) =>
            buf.writeVarInt(value, signed: false, steps: _bits4xLOW),
        reader: (BitBufferOld buf) =>
            buf.readVarInt(signed: false, steps: _bits4xLOW));
    for (int i = 0; i < text.length; i++) {
      stringWriter.write(text.codeUnitAt(i));
    }
    BitBufferOld buf2 = stringWriter.toBitBuffer();

    if (buf2.getAvailableBits() < buf.getAvailableBits()) {
      writeBits(1, 1);
      addBits(buf2._bits);
    } else {
      writeBits(0, 1);
      addBits(buf._bits);
    }
  }

  void writePackedVarInt(int i,
      {bool signed = true, List<List<int>> stepSet = _defaultPackedSet}) {
    int bits = getBitsNeeded(i.abs());
    BitBufferOld a = BitBufferOld();
    a.writeBits(1, 2); // 1 = packed
    a.writeBits(bits, 6);
    a.writeBits(i.abs(), bits);
    if (signed) {
      a.writeSign(i);
    }

    BitBufferOld b = BitBufferOld();
    b.writeBits(0, 2);
    b.writeVarInt(i, signed: signed, steps: stepSet[0]);

    BitBufferOld c = BitBufferOld();
    c.writeBits(2, 2);
    c.writeVarInt(i, signed: signed, steps: stepSet[1]);

    BitBufferOld d = BitBufferOld();
    d.writeBits(3, 2);
    d.writeVarInt(i, signed: signed, steps: stepSet[2]);
    List<BitBufferOld> bx = [a, b, c, d];
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

  bool readBit() => _bits.removeAt(0);

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

  static double truncate(double d, int precision) {
    int fac = pow(10, precision).toInt();
    return (d * fac).toInt() / fac;
  }

  void _setBytes(Uint8List bytes) {
    _bits = [];
    writeByteArray(bytes);
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
      on ? (value | (1 << bit)) : (value & ~(1 << bit));

  String toBase64Compressed() => compress(toBase64());

  String toBase64() => base64Encode(toBytes());

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
    return max(1, bits);
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
