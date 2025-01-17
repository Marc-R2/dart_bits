import 'dart:convert';

import 'package:bits/bits.dart';
import 'package:threshold/threshold.dart';

typedef BitCodecWriter<T> = void Function(BitBufferWriter writer, T t);
typedef BitCodecReader<T> = T Function(BitBufferReader reader);

abstract class BitCodec<T> {
  void writer(BitBufferWriter writer, T t);

  T reader(BitBufferReader reader);

  BitCodec<T> variant(BitCodec<T> codec);

  static const codec_string_compressed = SimpleBitCodec<String>(
    writer: _string_compressed_write,
    reader: _string_compressed_read,
  );

  static void _string_compressed_write(BitBufferWriter w, String t) =>
      w.writeSteppedVarString(compress(t));

  static String _string_compressed_read(BitBufferReader r) =>
      decompress(r.readSteppedVarString());

  static const codec_string_stepped = SimpleBitCodec<String>(
    writer: _string_stepped_write,
    reader: _string_stepped_read,
  );

  static void _string_stepped_write(BitBufferWriter w, String t) =>
      w.writeSteppedVarString(t);

  static String _string_stepped_read(BitBufferReader r) =>
      r.readSteppedVarString();

  static const codec_string_linear = SimpleBitCodec<String>(
    writer: _string_linear_write,
    reader: _string_linear_read,
  );

  static void _string_linear_write(BitBufferWriter w, String t) =>
      w.writeLinearVarString(t);

  static String _string_linear_read(BitBufferReader r) =>
      r.readLinearVarString();

  static const codec_stepped_utf16 = SimpleBitCodec<int>(
    writer: _stepped_utf16_write,
    reader: _stepped_utf16_read,
  );

  static void _stepped_utf16_write(BitBufferWriter w, int t) =>
      w.writeSteppedVarInt(t, signed: false, bitLimits: stepCharList1b);

  static int _stepped_utf16_read(BitBufferReader r) =>
      r.readSteppedVarInt(signed: false, bitLimits: stepCharList1b);

  static BitCodec<String> codec_string_palette = SimpleBitCodec<String>(
    writer: _string_palette_write,
    reader: _string_palette_read,
  );

  static void _string_palette_write(BitBufferWriter w, String t) {
    PaletteData<int> palette = PaletteData<int>(codec: codec_stepped_utf16);
    t.codeUnits.forEach((c) => palette.write(c));
    palette.toBitBuffer(w);
  }

  static String _string_palette_read(BitBufferReader r) {
    PaletteData<int> palette = PaletteData<int>.fromBitBufferReader(
        codec: codec_stepped_utf16, reader: r);
    return palette.getAllData().map((e) => String.fromCharCode(e)).join();
  }

  static const codec_string_best = BestBitCodec<String>(codecs: [
    codec_string_compressed,
    codec_string_stepped,
  ]);

  static const codec_int_stepped_4_low = SimpleBitCodec<int>(
    writer: _int_stepped_4_low_write,
    reader: _int_stepped_4_low_read,
  );

  static void _int_stepped_4_low_write(BitBufferWriter w, int t) =>
      w.writeSteppedVarInt(t, bitLimits: stepIntLow4_16);

  static int _int_stepped_4_low_read(BitBufferReader r) =>
      r.readSteppedVarInt(bitLimits: stepIntLow4_16);

  static const codec_int_linear_8 = SimpleBitCodec<int>(
    writer: _int_linear_8_write,
    reader: _int_linear_8_read,
  );

  static void _int_linear_8_write(BitBufferWriter w, int t) =>
      w.writeLinearVarInt(t, maxBits: 8);

  static int _int_linear_8_read(BitBufferReader r) =>
      r.readLinearVarInt(maxBits: 8);

  static const codec_int_linear_16 = SimpleBitCodec<int>(
    writer: _int_linear_16_write,
    reader: _int_linear_16_read,
  );

  static void _int_linear_16_write(BitBufferWriter w, int t) =>
      w.writeLinearVarInt(t, maxBits: 16);

  static int _int_linear_16_read(BitBufferReader r) =>
      r.readLinearVarInt(maxBits: 16);

  static const codec_int_linear_64 = SimpleBitCodec<int>(
    writer: _int_linear_64_write,
    reader: _int_linear_64_read,
  );

  static void _int_linear_64_write(BitBufferWriter w, int t) =>
      w.writeLinearVarInt(t);

  static int _int_linear_64_read(BitBufferReader r) => r.readLinearVarInt();

  static const codec_int_best = BestBitCodec<int>(codecs: [
    codec_int_stepped_4_low,
    codec_int_linear_8,
    codec_int_linear_16,
    codec_int_linear_64,
  ]);

  static const codec_double_stepped_4_low = SimpleBitCodec<double>(
    writer: _double_stepped_4_low_write,
    reader: _double_stepped_4_low_read,
  );

  static void _double_stepped_4_low_write(BitBufferWriter w, double t) =>
      w.writeSteppedVarDouble(t, bitLimits: stepIntLow4_16);

  static double _double_stepped_4_low_read(BitBufferReader r) =>
      r.readSteppedVarDouble(bitLimits: stepIntLow4_16);

  static const codec_double_linear_8 = SimpleBitCodec<double>(
    writer: _double_linear_8_write,
    reader: _double_linear_8_read,
  );

  static void _double_linear_8_write(BitBufferWriter w, double t) =>
      w.writeLinearVarDouble(t, maxBits: 8);

  static double _double_linear_8_read(BitBufferReader r) =>
      r.readLinearVarDouble(maxBits: 8);

  static const codec_double_linear_16 = SimpleBitCodec<double>(
    writer: _double_linear_16_write,
    reader: _double_linear_16_read,
  );

  static void _double_linear_16_write(BitBufferWriter w, double t) =>
      w.writeLinearVarDouble(t, maxBits: 16);

  static double _double_linear_16_read(BitBufferReader r) =>
      r.readLinearVarDouble(maxBits: 16);

  static const codec_double_linear_64 = SimpleBitCodec<double>(
    writer: _double_linear_64_write,
    reader: _double_linear_64_read,
  );

  static void _double_linear_64_write(BitBufferWriter w, double t) =>
      w.writeLinearVarDouble(t);

  static double _double_linear_64_read(BitBufferReader r) =>
      r.readLinearVarDouble();

  static const codec_double_best = BestBitCodec<double>(codecs: [
    codec_double_stepped_4_low,
    codec_double_linear_8,
    codec_double_linear_16,
    codec_double_linear_64
  ]);

  static const codec_list = SimpleBitCodec(
    writer: _list_write,
    reader: _list_read,
  );

  static void _list_write(BitBufferWriter w, List<dynamic> t) {
    w.writeCodec(codec_int_best, t.length);
    t.forEach((e) => w.writeCodec(codec_any, e));
  }

  static List<dynamic> _list_read(BitBufferReader r) {
    int length = r.readCodec(codec_int_best);
    List<dynamic> list = <dynamic>[];
    for (int i = 0; i < length; i++) {
      list.add(r.readCodec(codec_any));
    }
    return list;
  }

  static const codec_string_map = SimpleBitCodec(
    writer: _string_map_write,
    reader: _string_map_read,
  );

  static void _string_map_write(BitBufferWriter w, Map<String, dynamic> t) {
    w.writeCodec(codec_int_best, t.length);
    t.forEach((key, value) {
      w.writeCodec(codec_string_best, key);
      w.writeCodec(codec_any, value);
    });
  }

  static Map<String, dynamic> _string_map_read(BitBufferReader r) {
    int length = r.readCodec(codec_int_best);
    Map<String, dynamic> map = <String, dynamic>{};
    for (int i = 0; i < length; i++) {
      map[r.readCodec(codec_string_best)] = r.readCodec(codec_any);
    }
    return map;
  }

  static const codec_json = BestBitCodec<Map<String, dynamic>>(
    codecs: [codec_json_string_map, codec_string_map],
  );

  static const codec_bool = SimpleBitCodec(
    writer: _bool_write,
    reader: _bool_read,
  );

  static void _bool_write(BitBufferWriter w, bool t) => w.writeBit(t);

  static bool _bool_read(BitBufferReader r) => r.readBit();

  static const codec_json_string = SimpleBitCodec<dynamic>(
    writer: _json_string_write,
    reader: _json_string_read,
  );

  static void _json_string_write(BitBufferWriter w, dynamic t) {
    w.writeCodec(codec_string_best, jsonEncode(t));
  }

  static dynamic _json_string_read(BitBufferReader r) {
    return jsonDecode(r.readCodec(codec_string_best));
  }

  static const codec_json_string_map = SimpleBitCodec<Map<String, dynamic>>(
    writer: _json_string_map_write,
    reader: _json_string_map_read,
  );

  static void _json_string_map_write(
      BitBufferWriter w, Map<String, dynamic> t) {
    w.writeCodec(codec_string_best, jsonEncode(t));
  }

  static Map<String, dynamic> _json_string_map_read(BitBufferReader r) {
    return jsonDecode(r.readCodec(codec_string_best));
  }

  static const codec_any = BestBitCodec(codecs: [
    RWBitCodec<String>(codec: codec_string_best),
    RWBitCodec<bool>(codec: codec_bool),
    RWBitCodec<int>(codec: codec_int_best),
    RWBitCodec<double>(codec: codec_double_best),
    RWBitCodec<List<dynamic>>(codec: codec_list),
    RWBitCodec<Map<String, dynamic>>(codec: codec_string_map),
    RWBitCodec<dynamic>(codec: codec_json_string)
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

  void writer(BitBufferWriter writer, T t) => _writer(writer, t);

  T reader(BitBufferReader reader) => _reader(reader);

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

int getCodecWrittenSize<T>(BitCodec<T> method, T value) {
  try {
    return (DummyBitBufferWriter()..writeCodec(method, value)).getBitsWritten();
  } catch (e) {
    return -1;
  }
}
