import 'package:bits/bits.dart';

const int initialPaletteBits = 3;
const int linearBitsLimit = 5;

typedef void BitWriter<T>(BitBuffer buf, T value);

typedef T BitReader<T>(BitBuffer buf);

class PaletteData<T> {
  final BitCodec<T> codec;
  Palette<T> _palette = LinearPalette<T>();
  List<int> _out = [];

  List<T> getAllData() =>
      _out.map((e) => _palette.get(e)).toList(growable: false);

  List<int> getAllEntries() => _out.toList(growable: false);

  PaletteData({required this.codec});

  int getPaletteSize() => _palette.size();

  int getEntrySize() => _out.length;

  int getEntryBits() => getBitsNeeded(getPaletteSize() - 1);

  void write(T t) {
    int id = !_palette.contains(t) ? _grow(t) : _palette.idOf(t);

    if (!_palette.contains(t)) {
      _grow(t);
    }

    _out.add(id);
  }

  int _grow(T t) {
    if (_palette is LinearPalette<T> &&
        getBitsNeeded(_palette.size() + 1) > linearBitsLimit) {
      _palette = HashPalette<T>()..from(_palette);
    }

    return _palette.add(t);
  }

  factory PaletteData.fromBitBufferReader(
      {required BitCodec<T> codec, required BitBufferReader reader}) {
    PaletteData<T> data = PaletteData<T>(codec: codec);
    int paletteSize = reader.readLinearVarInt(
        signed: false, maxBits: 16); // TODO: Read palette size
    for (int i = 0; i < paletteSize; i++) {
      data._palette.add(reader.readCodec(codec)); // TODO: Read palette values
    }

    int entryBits = getBitsNeeded(paletteSize - 1);
    int entrySize = reader.readLinearVarInt(
        signed: false, maxBits: 32); // TODO: Read Palette entry size

    for (int i = 0; i < entrySize; i++) {
      int f = reader.readLinearVarInt(signed: false, maxBits: entryBits);
      data._out.add(f); // TODO: Read palette entry values
    }

    return data;
  }

  factory PaletteData.fromBitBuffer(
      {required BitCodec<T> codec, required BitBuffer buf}) {
    PaletteData<T> data = PaletteData<T>(codec: codec);
    BitBufferReader reader = buf.reader();
    int paletteSize = reader.readLinearVarInt(
        signed: false, maxBits: 16); // TODO: Read palette size
    for (int i = 0; i < paletteSize; i++) {
      data._palette.add(reader.readCodec(codec)); // TODO: Read palette values
    }

    int entryBits = getBitsNeeded(paletteSize - 1);
    int entrySize = reader.readLinearVarInt(
        signed: false, maxBits: 32); // TODO: Read Palette entry size

    for (int i = 0; i < entrySize; i++) {
      int f = reader.readLinearVarInt(signed: false, maxBits: entryBits);
      data._out.add(f); // TODO: Read palette entry values
    }

    return data;
  }

  BitBuffer toBitBuffer([BitBufferWriter? writer]) {
    BitBuffer buf = writer?.buffer ?? BitBuffer();
    writer ??= buf.writer();
    writer.writeLinearVarInt(_palette.size(),
        signed: false, maxBits: 16); // TODO: Write Palette Size
    for (int i = 0; i < _palette.size(); i++) {
      writer.writeCodec(codec, _palette.get(i)); // TODO: Write Palette values
    }
    int entryBits = getEntryBits();
    writer.writeLinearVarInt(_out.length,
        signed: false, maxBits: 32); // TODO: Write Entry Size
    for (int i = 0; i < _out.length; i++) {
      writer.writeLinearVarInt(_out[i],
          signed: false,
          maxBits: entryBits); // TODO: Write Palette Entry Values
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
