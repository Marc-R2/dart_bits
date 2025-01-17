import 'package:bits/bits.dart';
import 'package:test/test.dart';

void main() {
  group('BitCodec', () {
    late BitBuffer buffer;
    late BitBufferWriter writer;
    late BitBufferReader reader;

    setUp(() {
      buffer = BitBuffer();
      writer = buffer.writer();
      reader = buffer.reader();
    });

    test('codec_string_compressed encodes and decodes correctly', () {
      BitCodec.codec_string_compressed.writer(writer, 'Hello, World!');
      final result = BitCodec.codec_string_compressed.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 114);
    });

    test('codec_string_stepped encodes and decodes correctly', () {
      BitCodec.codec_string_stepped.writer(writer, 'Hello, World!');
      final result = BitCodec.codec_string_stepped.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 114);
    });

    test('codec_string_linear encodes and decodes correctly', () {
      BitCodec.codec_string_linear.writer(writer, 'Hello, World!');
      final result = BitCodec.codec_string_linear.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 163);
    });

    test('codec_stepped_utf16 encodes and decodes correctly', () {
      BitCodec.codec_stepped_utf16.writer(writer, 12345);
      final result = BitCodec.codec_stepped_utf16.reader(reader);

      expect(result, 12345);
      expect(writer.getBitsWritten(), 17);
    });

    test('codec_string_palette encodes and decodes correctly', () {
      BitCodec.codec_string_palette.writer(writer, 'Hello, World!');
      final result = BitCodec.codec_string_palette.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 170);
    });

    test('codec_int_linear_8 encodes and decodes correctly', () {
      BitCodec.codec_int_linear_8.writer(writer, 123);
      final result = BitCodec.codec_int_linear_8.reader(reader);

      expect(result, 123);
      expect(writer.getBitsWritten(), 12);
    });

    test('codec_int_linear_16 encodes and decodes correctly', () {
      BitCodec.codec_int_linear_16.writer(writer, 12345);
      final result = BitCodec.codec_int_linear_16.reader(reader);

      expect(result, 12345);
      expect(writer.getBitsWritten(), 20);
    });

    test('codec_int_linear_64 encodes and decodes correctly', () {
      BitCodec.codec_int_linear_64.writer(writer, 123456789);
      final result = BitCodec.codec_int_linear_64.reader(reader);

      expect(result, 123456789);
      expect(writer.getBitsWritten(), 35);
    });

    test('codec_double_linear_8 encodes and decodes correctly', () {
      BitCodec.codec_double_linear_8.writer(writer, 123.456);
      final result = BitCodec.codec_double_linear_8.reader(reader);

      expect(result, 123.456);
      expect(writer.getBitsWritten(), 50);
    });

    test('codec_double_linear_16 encodes and decodes correctly', () {
      BitCodec.codec_double_linear_16.writer(writer, 123.456);
      final result = BitCodec.codec_double_linear_16.reader(reader);

      expect(result, 123.456);
      expect(writer.getBitsWritten(), 51);
    });

    test('codec_double_linear_64 encodes and decodes correctly', () {
      BitCodec.codec_double_linear_64.writer(writer, 123.456);
      final result = BitCodec.codec_double_linear_64.reader(reader);

      expect(result, 123.456);
      expect(writer.getBitsWritten(), 53);
    });

    test('codec_list encodes and decodes correctly', () {
      BitCodec.codec_list.writer(writer, [1, 2, 3, 'Hello']);
      final result = BitCodec.codec_list.reader(reader);

      expect(result, [1, 2, 3, 'Hello']);
      expect(writer.getBitsWritten(), 134);
    });

    test('codec_string_map encodes and decodes correctly', () {
      BitCodec.codec_string_map.writer(writer, {'key': 'value'});
      final result = BitCodec.codec_string_map.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 110);
    });

    test('codec_json encodes and decodes correctly', () {
      BitCodec.codec_json.writer(writer, {'key': 'value'});
      final result = BitCodec.codec_json.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 111);
    });

    test('codec_bool encodes and decodes correctly', () {
      BitCodec.codec_bool.writer(writer, true);
      final result = BitCodec.codec_bool.reader(reader);

      expect(result, true);
      expect(writer.getBitsWritten(), 1);
    });

    test('codec_json_string encodes and decodes correctly', () {
      BitCodec.codec_json_string.writer(writer, {'key': 'value'});
      final result = BitCodec.codec_json_string.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 131);
    });

    test('codec_json_string_map encodes and decodes correctly', () {
      BitCodec.codec_json_string_map.writer(writer, {'key': 'value'});
      final result = BitCodec.codec_json_string_map.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 131);
    });

    test('codec_any encodes and decodes correctly', () {
      BitCodec.codec_any.writer(writer, 'Hello, World!');
      final result = BitCodec.codec_any.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 134);
    });
  });

  group('Backwards Codec Compatibility', () {
    test('codec_string_compressed decodes correctly', () {
      final buffer = BitBuffer.fromBits([100059283527975748, 293721599081145], trueSize: 114);
      final result = BitCodec.codec_string_compressed.reader(buffer.reader());

      expect(result, 'Hello, World!');
    });

    test('codec_string_stepped decodes correctly', () {
      final buffer = BitBuffer.fromBits([100059283527975748, 293721599081145], trueSize: 114);
      final result = BitCodec.codec_string_stepped.reader(buffer.reader());

      expect(result, 'Hello, World!');
    });

    test('codec_string_linear decodes correctly', () {
      final buffer = BitBuffer.fromBits([-6962012935230841020, -1982173524448681545, 17830542727], trueSize: 163);
      final result = BitCodec.codec_string_linear.reader(buffer.reader());

      expect(result, 'Hello, World!');
    });

    test('codec_stepped_utf16 decodes correctly', () {
      final buffer = BitBuffer.fromBits([24691], trueSize: 17);
      final result = BitCodec.codec_stepped_utf16.reader(buffer.reader());

      expect(result, 12345);
    });

    test('codec_string_palette decodes correctly', () {
      final buffer = BitBuffer.fromBits([6665522876794609988, -8119263838298861111, 2629752564971], trueSize: 170);
      final result = BitCodec.codec_string_palette.reader(buffer.reader());

      expect(result, 'Hello, World!');
    });

    test('codec_int_linear_8 decodes correctly', () {
      final buffer = BitBuffer.fromBits([3959], trueSize: 12);
      final result = BitCodec.codec_int_linear_8.reader(buffer.reader());

      expect(result, 123);
    });

    test('codec_int_linear_16 decodes correctly', () {
      final buffer = BitBuffer.fromBits([790126], trueSize: 20);
      final result = BitCodec.codec_int_linear_16.reader(buffer.reader());

      expect(result, 12345);
    });

    test('codec_int_linear_64 decodes correctly', () {
      final buffer = BitBuffer.fromBits([31604938139], trueSize: 35);
      final result = BitCodec.codec_int_linear_64.reader(buffer.reader());

      expect(result, 123456789);
    });

    test('codec_double_linear_8 decodes correctly', () {
      final buffer = BitBuffer.fromBits([765041063513967], trueSize: 50);
      final result = BitCodec.codec_double_linear_8.reader(buffer.reader());

      expect(result, 123.456);
    });

    test('codec_double_linear_16 decodes correctly', () {
      final buffer = BitBuffer.fromBits([1530082127027919], trueSize: 51);
      final result = BitCodec.codec_double_linear_16.reader(buffer.reader());

      expect(result, 123.456);
    });

    test('codec_double_linear_64 decodes correctly', () {
      final buffer = BitBuffer.fromBits([6120328508111631], trueSize: 53);
      final result = BitCodec.codec_double_linear_64.reader(buffer.reader());

      expect(result, 123.456);
    });

    test('codec_list decodes correctly', () {
      final buffer = BitBuffer.fromBits([-3673361555328330108, 4014455708976232556, 17], trueSize: 134);
      final result = BitCodec.codec_list.reader(buffer.reader());

      expect(result, [1, 2, 3, 'Hello']);
    });

    test('codec_string_map decodes correctly', () {
      final buffer = BitBuffer.fromBits([1240862530166686756, 18909578539195], trueSize: 110);
      final result = BitCodec.codec_string_map.reader(buffer.reader());

      expect(result, {'key': 'value'});
    });

    test('codec_json decodes correctly', () {
      final buffer = BitBuffer.fromBits([2481725060333373513, 37819157078390], trueSize: 111);
      final result = BitCodec.codec_json.reader(buffer.reader());

      expect(result, {'key': 'value'});
    });

    test('codec_bool decodes correctly', () {
      final buffer = BitBuffer.fromBits([1], trueSize: 1);
      final result = BitCodec.codec_bool.reader(buffer.reader());

      expect(result, true);
    });

    test('codec_json_string decodes correctly', () {
      final buffer = BitBuffer.fromBits([-6762271016373209208, -3303857246427454941, 7], trueSize: 131);
      final result = BitCodec.codec_json_string.reader(buffer.reader());

      expect(result, {'key': 'value'});
    });

    test('codec_json_string_map decodes correctly', () {
      final buffer = BitBuffer.fromBits([-6762271016373209208, -3303857246427454941, 7], trueSize: 131);
      final result = BitCodec.codec_json_string_map.reader(buffer.reader());

      expect(result, {'key': 'value'});
    });

    test('codec_any decodes correctly', () {
      final buffer = BitBuffer.fromBits([4014455708976233542, 1203083669836369942, 17], trueSize: 134);
      final result = BitCodec.codec_any.reader(buffer.reader());

      expect(result, 'Hello, World!');
    });
  });
}
