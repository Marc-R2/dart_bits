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
      codec_string_compressed.writer(writer, 'Hello, World!');
      final result = codec_string_compressed.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 114);
    });

    test('codec_string_stepped encodes and decodes correctly', () {
      codec_string_stepped.writer(writer, 'Hello, World!');
      final result = codec_string_stepped.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 114);
    });

    test('codec_string_linear encodes and decodes correctly', () {
      codec_string_linear.writer(writer, 'Hello, World!');
      final result = codec_string_linear.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 163);
    });

    test('codec_stepped_utf16 encodes and decodes correctly', () {
      codec_stepped_utf16.writer(writer, 12345);
      final result = codec_stepped_utf16.reader(reader);

      expect(result, 12345);
      expect(writer.getBitsWritten(), 17);
    });

    test('codec_string_palette encodes and decodes correctly', () {
      codec_string_palette.writer(writer, 'Hello, World!');
      final result = codec_string_palette.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 170);
    });

    test('codec_int_linear_8 encodes and decodes correctly', () {
      codec_int_linear_8.writer(writer, 123);
      final result = codec_int_linear_8.reader(reader);

      expect(result, 123);
      expect(writer.getBitsWritten(), 12);
    });

    test('codec_int_linear_16 encodes and decodes correctly', () {
      codec_int_linear_16.writer(writer, 12345);
      final result = codec_int_linear_16.reader(reader);

      expect(result, 12345);
      expect(writer.getBitsWritten(), 20);
    });

    test('codec_int_linear_64 encodes and decodes correctly', () {
      codec_int_linear_64.writer(writer, 123456789);
      final result = codec_int_linear_64.reader(reader);

      expect(result, 123456789);
      expect(writer.getBitsWritten(), 35);
    });

    test('codec_double_linear_8 encodes and decodes correctly', () {
      codec_double_linear_8.writer(writer, 123.456);
      final result = codec_double_linear_8.reader(reader);

      expect(result, 123.456);
      expect(writer.getBitsWritten(), 50);
    });

    test('codec_double_linear_16 encodes and decodes correctly', () {
      codec_double_linear_16.writer(writer, 123.456);
      final result = codec_double_linear_16.reader(reader);

      expect(result, 123.456);
      expect(writer.getBitsWritten(), 51);
    });

    test('codec_double_linear_64 encodes and decodes correctly', () {
      codec_double_linear_64.writer(writer, 123.456);
      final result = codec_double_linear_64.reader(reader);

      expect(result, 123.456);
      expect(writer.getBitsWritten(), 53);
    });

    test('codec_list encodes and decodes correctly', () {
      codec_list.writer(writer, [1, 2, 3, 'Hello']);
      final result = codec_list.reader(reader);

      expect(result, [1, 2, 3, 'Hello']);
      expect(writer.getBitsWritten(), 134);
    });

    test('codec_string_map encodes and decodes correctly', () {
      codec_string_map.writer(writer, {'key': 'value'});
      final result = codec_string_map.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 110);
    });

    test('codec_json encodes and decodes correctly', () {
      codec_json.writer(writer, {'key': 'value'});
      final result = codec_json.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 111);
    });

    test('codec_bool encodes and decodes correctly', () {
      codec_bool.writer(writer, true);
      final result = codec_bool.reader(reader);

      expect(result, true);
      expect(writer.getBitsWritten(), 1);
    });

    test('codec_json_string encodes and decodes correctly', () {
      codec_json_string.writer(writer, {'key': 'value'});
      final result = codec_json_string.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 131);
    });

    test('codec_json_string_map encodes and decodes correctly', () {
      codec_json_string_map.writer(writer, {'key': 'value'});
      final result = codec_json_string_map.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 131);
    });

    test('codec_any encodes and decodes correctly', () {
      codec_any.writer(writer, 'Hello, World!');
      final result = codec_any.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 134);
    });
  });
}
