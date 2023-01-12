import 'dart:convert';

import 'package:bits/bits.dart';
import 'package:threshold/threshold.dart';

BitCodec<String> codec_string_compressed = BitCodec<String>(
    writer: (w, t) => w.writeSteppedVarString(compress(t)),
    reader: (r) => decompress(r.readSteppedVarString()));
BitCodec<String> codec_string_stepped = BitCodec<String>(
    writer: (w, t) => w.writeSteppedVarString(t),
    reader: (r) => r.readSteppedVarString());
BitCodec<String> codec_string_linear = BitCodec<String>(
    writer: (w, t) => w.writeLinearVarString(t),
    reader: (r) => r.readLinearVarString());
BitCodec<int> codec_stepped_utf16 = BitCodec<int>(
    writer: (w, t) =>
        w.writeSteppedVarInt(t, signed: false, bitLimits: stepCharList1b),
    reader: (r) =>
        r.readSteppedVarInt(signed: false, bitLimits: stepCharList1b));
BitCodec<String> codec_string_palette = BitCodec<String>(
    writer: (w, t) {
      PaletteData<int> palette = PaletteData<int>(codec: codec_stepped_utf16);
      t.codeUnits.forEach((c) => palette.write(c));
      palette.toBitBuffer(w);
    },
    reader: (r) =>
        PaletteData.fromBitBufferReader(codec: codec_stepped_utf16, reader: r)
            .getAllData()
            .map((e) => String.fromCharCode(e))
            .join());
BitCodec<String> codec_string_best = BestBitCodec<String>(codecs: [
  codec_string_compressed,
  codec_string_stepped,
]);

BitCodec<int> codec_int_stepped_4_low = BitCodec<int>(
    writer: (w, t) => w.writeSteppedVarInt(t, bitLimits: stepIntLow4_16),
    reader: (r) => r.readSteppedVarInt(bitLimits: stepIntLow4_16));
BitCodec<int> codec_int_linear_8 = BitCodec<int>(
    writer: (w, t) => w.writeLinearVarInt(t, maxBits: 8),
    reader: (r) => r.readLinearVarInt(maxBits: 8));
BitCodec<int> codec_int_linear_16 = BitCodec<int>(
    writer: (w, t) => w.writeLinearVarInt(t, maxBits: 16),
    reader: (r) => r.readLinearVarInt(maxBits: 16));
BitCodec<int> codec_int_linear_64 = BitCodec<int>(
    writer: (w, t) => w.writeLinearVarInt(t),
    reader: (r) => r.readLinearVarInt());
BitCodec<int> codec_int_best = BestBitCodec<int>(codecs: [
  codec_int_stepped_4_low,
  codec_int_linear_8,
  codec_int_linear_16,
  codec_int_linear_64
]);

BitCodec<double> codec_double_stepped_4_low = BitCodec<double>(
    writer: (w, t) => w.writeSteppedVarDouble(t, bitLimits: stepIntLow4_16),
    reader: (r) => r.readSteppedVarDouble(bitLimits: stepIntLow4_16));
BitCodec<double> codec_double_linear_8 = BitCodec<double>(
    writer: (w, t) => w.writeLinearVarDouble(t, maxBits: 8),
    reader: (r) => r.readLinearVarDouble(maxBits: 8));
BitCodec<double> codec_double_linear_16 = BitCodec<double>(
    writer: (w, t) => w.writeLinearVarDouble(t, maxBits: 16),
    reader: (r) => r.readLinearVarDouble(maxBits: 16));
BitCodec<double> codec_double_linear_64 = BitCodec<double>(
    writer: (w, t) => w.writeLinearVarDouble(t),
    reader: (r) => r.readLinearVarDouble());
BitCodec<double> codec_double_best = BestBitCodec<double>(codecs: [
  codec_double_stepped_4_low,
  codec_double_linear_8,
  codec_double_linear_16,
  codec_double_linear_64
]);

BitCodec<List<dynamic>> codec_list = BitCodec(writer: (writer, t) {
  writer.writeCodec(codec_int_best, t.length);
  t.forEach((e) => writer.writeCodec(codec_any, e));
}, reader: (reader) {
  int length = reader.readCodec(codec_int_best);
  List<dynamic> list = <dynamic>[];
  for (int i = 0; i < length; i++) {
    list.add(reader.readCodec(codec_any));
  }
  return list;
});

BitCodec<Map<String, dynamic>> codec_string_map = BitCodec(writer: (writer, t) {
  writer.writeCodec(codec_int_best, t.length);
  t.forEach((key, value) {
    writer.writeCodec(codec_string_best, key);
    writer.writeCodec(codec_any, value);
  });
}, reader: (reader) {
  int length = reader.readCodec(codec_int_best);
  Map<String, dynamic> map = <String, dynamic>{};
  for (int i = 0; i < length; i++) {
    map[reader.readCodec(codec_string_best)] = reader.readCodec(codec_any);
  }
  return map;
});

BitCodec<Map<String, dynamic>> codec_json = BestBitCodec<Map<String, dynamic>>(
    codecs: [codec_json_string_map, codec_string_map]);

BitCodec<bool> codec_bool = BitCodec(
    writer: (writer, t) => writer.writeBit(t),
    reader: (reader) => reader.readBit());

BitCodec<dynamic> codec_json_string = BitCodec<dynamic>(
    writer: (writer, t) => writer.writeCodec(codec_string_best, jsonEncode(t)),
    reader: (reader) => jsonDecode(reader.readCodec(codec_string_best)));

BitCodec<Map<String, dynamic>> codec_json_string_map =
    BitCodec<Map<String, dynamic>>(
        writer: (writer, t) =>
            writer.writeCodec(codec_string_best, jsonEncode(t)),
        reader: (reader) => jsonDecode(reader.readCodec(codec_string_best)));

BitCodec<dynamic> codec_any = BestBitCodec(codecs: [
  forceAcceptCodec<String>(codec_string_best),
  forceAcceptCodec<bool>(codec_bool),
  forceAcceptCodec<int>(codec_int_best),
  forceAcceptCodec<double>(codec_double_best),
  forceAcceptCodec<List<dynamic>>(codec_list),
  forceAcceptCodec<Map<String, dynamic>>(codec_string_map),
  forceAcceptCodec<dynamic>(codec_json_string)
]);

BitCodec<dynamic> forceAcceptCodec<T>(BitCodec<T> codec) {
  return BitCodec(
      writer: (writer, t) => writer.writeCodec(codec, t as T),
      reader: (reader) => reader.readCodec(codec) as T);
}

typedef BitCodecWriter<T> = void Function(BitBufferWriter writer, T t);
typedef BitCodecReader<T> = T Function(BitBufferReader reader);

class BitCodec<T> {
  final BitCodecWriter<T> writer;
  final BitCodecReader<T> reader;

  BitCodec({required this.writer, required this.reader});

  BitCodec<T> variant(BitCodec<T> codec) => BestBitCodec(codecs: [this, codec]);
}

class BestBitCodec<T> extends BitCodec<T> {
  final List<BitCodec<T>> codecs;

  BestBitCodec({required this.codecs})
      : super(
            writer: (buf, d) {
              int bestCodec = getBestCodec(codecs, d);
              buf.writeInt(bestCodec,
                  signed: false, bits: getBitsNeeded(codecs.length - 1));
              buf.writeCodec(codecs[bestCodec], d);
            },
            reader: (buf) => buf.readCodec(codecs[buf.readInt(
                signed: false, bits: getBitsNeeded(codecs.length - 1))]));

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
