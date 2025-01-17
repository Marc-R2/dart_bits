import 'dart:convert';

import 'package:bits/bits.dart';
import 'package:threshold/threshold.dart';

typedef BitCodecWriter<T> = void Function(BitBufferWriter writer, T t);
typedef BitCodecReader<T> = T Function(BitBufferReader reader);

abstract class BitCodec<T> {
  void writer(BitBufferWriter writer, T t);

  T reader(BitBufferReader reader);

  BitCodec<T> variant(BitCodec<T> codec);

  static const stringCompressed = SimpleBitCodec<String>(
    writer: _stringCompressedWrite,
    reader: _stringCompressedRead,
  );

  static void _stringCompressedWrite(BitBufferWriter w, String t) =>
      w.writeSteppedVarString(compress(t));

  static String _stringCompressedRead(BitBufferReader r) {
    final compressed = r.readSteppedVarString();
    if (compressed.isEmpty) return '';
    return decompress(compressed);
  }

  static const stringStepped = SimpleBitCodec<String>(
    writer: _stringSteppedWrite,
    reader: _stringSteppedRead,
  );

  static void _stringSteppedWrite(BitBufferWriter w, String t) =>
      w.writeSteppedVarString(t);

  static String _stringSteppedRead(BitBufferReader r) =>
      r.readSteppedVarString();

  static const stringLinear = SimpleBitCodec<String>(
    writer: _stringLinearWrite,
    reader: _stringLinearRead,
  );

  static void _stringLinearWrite(BitBufferWriter w, String t) =>
      w.writeLinearVarString(t);

  static String _stringLinearRead(BitBufferReader r) => r.readLinearVarString();

  static const steppedUtf16 = SimpleBitCodec<int>(
    writer: _steppedUtf16Write,
    reader: _steppedUtf16Read,
  );

  static void _steppedUtf16Write(BitBufferWriter w, int t) =>
      w.writeSteppedVarInt(t, signed: false, bitLimits: stepCharList1b);

  static int _steppedUtf16Read(BitBufferReader r) =>
      r.readSteppedVarInt(signed: false, bitLimits: stepCharList1b);

  static BitCodec<String> stringPalette = SimpleBitCodec<String>(
    writer: _stringPaletteWrite,
    reader: _stringPaletteRead,
  );

  static void _stringPaletteWrite(BitBufferWriter w, String t) {
    PaletteData<int> palette = PaletteData<int>(codec: steppedUtf16);
    t.codeUnits.forEach(palette.write);
    palette.toBitBuffer(w);
  }

  static String _stringPaletteRead(BitBufferReader r) {
    PaletteData<int> palette =
        PaletteData<int>.fromBitBufferReader(codec: steppedUtf16, reader: r);
    return palette.getAllData().map((e) => String.fromCharCode(e)).join();
  }

  static const stringBest = BestBitCodec<String>(codecs: [
    stringCompressed,
    stringStepped,
  ]);

  static const intStepped4Low = SimpleBitCodec<int>(
    writer: _intStepped4LowWrite,
    reader: _intStepped4LowRead,
  );

  static void _intStepped4LowWrite(BitBufferWriter w, int t) =>
      w.writeSteppedVarInt(t, bitLimits: stepIntLow4_16);

  static int _intStepped4LowRead(BitBufferReader r) =>
      r.readSteppedVarInt(bitLimits: stepIntLow4_16);

  static const intLinear8 = SimpleBitCodec<int>(
    writer: _intLinear8Write,
    reader: _intLinear8Read,
  );

  static void _intLinear8Write(BitBufferWriter w, int t) =>
      w.writeLinearVarInt(t, maxBits: 8);

  static int _intLinear8Read(BitBufferReader r) =>
      r.readLinearVarInt(maxBits: 8);

  static const intLinear16 = SimpleBitCodec<int>(
    writer: _intLinear16Write,
    reader: _intLinear16Read,
  );

  static void _intLinear16Write(BitBufferWriter w, int t) =>
      w.writeLinearVarInt(t, maxBits: 16);

  static int _intLinear16Read(BitBufferReader r) =>
      r.readLinearVarInt(maxBits: 16);

  static const intLinear64 = SimpleBitCodec<int>(
    writer: _intLinear64Write,
    reader: _intLinear64Read,
  );

  static void _intLinear64Write(BitBufferWriter w, int t) =>
      w.writeLinearVarInt(t);

  static int _intLinear64Read(BitBufferReader r) => r.readLinearVarInt();

  static const intBest = BestBitCodec<int>(codecs: [
    intStepped4Low,
    intLinear8,
    intLinear16,
    intLinear64,
  ]);

  static const doubleStepped4Low = SimpleBitCodec<double>(
    writer: _doubleStepped4LowWrite,
    reader: _doubleStepped4LowRead,
  );

  static void _doubleStepped4LowWrite(BitBufferWriter w, double t) =>
      w.writeSteppedVarDouble(t, bitLimits: stepIntLow4_16);

  static double _doubleStepped4LowRead(BitBufferReader r) =>
      r.readSteppedVarDouble(bitLimits: stepIntLow4_16);

  static const doubleLinear8 = SimpleBitCodec<double>(
    writer: _doubleLinear8Write,
    reader: _doubleLinear8Read,
  );

  static void _doubleLinear8Write(BitBufferWriter w, double t) =>
      w.writeLinearVarDouble(t, maxBits: 8);

  static double _doubleLinear8Read(BitBufferReader r) =>
      r.readLinearVarDouble(maxBits: 8);

  static const doubleLinear16 = SimpleBitCodec<double>(
    writer: _doubleLinear16Write,
    reader: _doubleLinear16Read,
  );

  static void _doubleLinear16Write(BitBufferWriter w, double t) =>
      w.writeLinearVarDouble(t, maxBits: 16);

  static double _doubleLinear16Read(BitBufferReader r) =>
      r.readLinearVarDouble(maxBits: 16);

  static const doubleLinear64 = SimpleBitCodec<double>(
    writer: _doubleLinear64Write,
    reader: _doubleLinear64Read,
  );

  static void _doubleLinear64Write(BitBufferWriter w, double t) =>
      w.writeLinearVarDouble(t);

  static double _doubleLinear64Read(BitBufferReader r) =>
      r.readLinearVarDouble();

  static const doubleBest = BestBitCodec<double>(codecs: [
    doubleStepped4Low,
    doubleLinear8,
    doubleLinear16,
    doubleLinear64
  ]);

  static const list = SimpleBitCodec(
    writer: _listWrite,
    reader: _listRead,
  );

  static void _listWrite(BitBufferWriter w, List<dynamic> t) {
    w.writeCodec(intBest, t.length);
    for (var e in t) {
      w.writeCodec(any, e);
    }
  }

  static List<dynamic> _listRead(BitBufferReader r) {
    int length = r.readCodec(intBest);
    List<dynamic> list = <dynamic>[];
    for (int i = 0; i < length; i++) {
      list.add(r.readCodec(any));
    }
    return list;
  }

  static const stringMap = SimpleBitCodec(
    writer: _stringMapWrite,
    reader: _stringMapRead,
  );

  static void _stringMapWrite(BitBufferWriter w, Map<String, dynamic> t) {
    w.writeCodec(intBest, t.length);
    t.forEach((key, value) {
      w.writeCodec(stringBest, key);
      w.writeCodec(any, value);
    });
  }

  static Map<String, dynamic> _stringMapRead(BitBufferReader r) {
    int length = r.readCodec(intBest);
    Map<String, dynamic> map = <String, dynamic>{};
    for (int i = 0; i < length; i++) {
      map[r.readCodec(stringBest)] = r.readCodec(any);
    }
    return map;
  }

  static const json = BestBitCodec<Map<String, dynamic>>(
    codecs: [jsonStringMap, stringMap],
  );

  static const boolean = SimpleBitCodec(
    writer: _boolWrite,
    reader: _boolRead,
  );

  static void _boolWrite(BitBufferWriter w, bool t) => w.writeBit(t);

  static bool _boolRead(BitBufferReader r) => r.readBit();

  static const jsonString = SimpleBitCodec<dynamic>(
    writer: _jsonStringWrite,
    reader: _jsonStringRead,
  );

  static void _jsonStringWrite(BitBufferWriter w, dynamic t) {
    w.writeCodec(stringBest, jsonEncode(t));
  }

  static dynamic _jsonStringRead(BitBufferReader r) {
    return jsonDecode(r.readCodec(stringBest));
  }

  static const jsonStringMap = SimpleBitCodec<Map<String, dynamic>>(
    writer: _jsonStringMapWrite,
    reader: _jsonStringMapRead,
  );

  static void _jsonStringMapWrite(BitBufferWriter w, Map<String, dynamic> t) =>
      w.writeCodec(stringBest, jsonEncode(t));

  static Map<String, dynamic> _jsonStringMapRead(BitBufferReader r) =>
      jsonDecode(r.readCodec(stringBest));

  static const any = BestBitCodec(codecs: [
    RWBitCodec<String>(codec: stringBest),
    RWBitCodec<bool>(codec: boolean),
    RWBitCodec<int>(codec: intBest),
    RWBitCodec<double>(codec: doubleBest),
    RWBitCodec<List<dynamic>>(codec: list),
    RWBitCodec<Map<String, dynamic>>(codec: stringMap),
    RWBitCodec<dynamic>(codec: jsonString)
  ]);
}

class RWBitCodec<T> implements BitCodec<T> {
  const RWBitCodec({required this.codec});

  final BitCodec<T> codec;

  @override
  void writer(BitBufferWriter writer, T t) => writer.writeCodec(codec, t);

  @override
  T reader(BitBufferReader reader) => reader.readCodec(codec);

  @override
  BitCodec<T> variant(BitCodec<T> codec) => BestBitCodec(codecs: [this, codec]);
}

class SimpleBitCodec<T> implements BitCodec<T> {
  const SimpleBitCodec({
    required BitCodecWriter<T> writer,
    required BitCodecReader<T> reader,
  })  : _writer = writer,
        _reader = reader;

  final BitCodecWriter<T> _writer;
  final BitCodecReader<T> _reader;

  @override
  void writer(BitBufferWriter writer, T t) => _writer(writer, t);

  @override
  T reader(BitBufferReader reader) => _reader(reader);

  @override
  BitCodec<T> variant(BitCodec<T> codec) => BestBitCodec(codecs: [this, codec]);
}

class BestBitCodec<T> implements BitCodec<T> {
  final List<BitCodec<T>> codecs;

  const BestBitCodec({required this.codecs});

  @override
  void writer(BitBufferWriter writer, T t) {
    int bestCodec = getBestCodec(codecs, t);
    writer.writeInt(bestCodec,
        signed: false, bits: getBitsNeeded(codecs.length - 1));
    writer.writeCodec(codecs[bestCodec], t);
  }

  @override
  T reader(BitBufferReader reader) => reader.readCodec(codecs[
      reader.readInt(signed: false, bits: getBitsNeeded(codecs.length - 1))]);

  @override
  BestBitCodec<T> variant(BitCodec<T> codec) {
    if (codec is BestBitCodec<T>) {
      return BestBitCodec(codecs: [...codecs, ...codec.codecs]);
    }

    return BestBitCodec(codecs: [...codecs, codec]);
  }

  static int getBestCodec<T>(List<BitCodec<T>> codecs, T value) {
    int bestCodec = -1;
    int smallest = -1;

    for (int i = 0; i < codecs.length; i++) {
      int size = getCodecWrittenSize(codecs[i], value);
      if (size >= 0 && (smallest == -1 || size < smallest)) {
        smallest = size;
        bestCodec = i;
      }
    }

    if (bestCodec == -1) throw Exception("No codec could write $value");

    return bestCodec;
  }

  static int getCodecWrittenSize<T>(BitCodec<T> codec, T value) {
    try {
      return (DummyBitBufferWriter()..writeCodec(codec, value))
          .getBitsWritten();
    } catch (e) {
      return -1;
    }
  }
}
