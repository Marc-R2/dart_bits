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
      BitCodec.stringCompressed.writer(writer, 'Hello, World!');
      final result = BitCodec.stringCompressed.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 114);
    });

    test('codec_string_stepped encodes and decodes correctly', () {
      BitCodec.stringStepped.writer(writer, 'Hello, World!');
      final result = BitCodec.stringStepped.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 114);
    });

    test('codec_string_linear encodes and decodes correctly', () {
      BitCodec.stringLinear.writer(writer, 'Hello, World!');
      final result = BitCodec.stringLinear.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 163);
    });

    test('codec_stepped_utf16 encodes and decodes correctly', () {
      BitCodec.steppedUtf16.writer(writer, 12345);
      final result = BitCodec.steppedUtf16.reader(reader);

      expect(result, 12345);
      expect(writer.getBitsWritten(), 17);
    });

    test('codec_string_palette encodes and decodes correctly', () {
      BitCodec.stringPalette.writer(writer, 'Hello, World!');
      final result = BitCodec.stringPalette.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 170);
    });

    test('codec_int_linear_8 encodes and decodes correctly', () {
      BitCodec.intLinear8.writer(writer, 123);
      final result = BitCodec.intLinear8.reader(reader);

      expect(result, 123);
      expect(writer.getBitsWritten(), 12);
    });

    test('codec_int_linear_16 encodes and decodes correctly', () {
      BitCodec.intLinear16.writer(writer, 12345);
      final result = BitCodec.intLinear16.reader(reader);

      expect(result, 12345);
      expect(writer.getBitsWritten(), 20);
    });

    test('codec_int_linear_64 encodes and decodes correctly', () {
      BitCodec.intLinear64.writer(writer, 123456789);
      final result = BitCodec.intLinear64.reader(reader);

      expect(result, 123456789);
      expect(writer.getBitsWritten(), 35);
    });

    test('codec_double_linear_8 encodes and decodes correctly', () {
      BitCodec.doubleLinear8.writer(writer, 123.456);
      final result = BitCodec.doubleLinear8.reader(reader);

      expect(result, 123.456);
      expect(writer.getBitsWritten(), 50);
    });

    test('codec_double_linear_16 encodes and decodes correctly', () {
      BitCodec.doubleLinear16.writer(writer, 123.456);
      final result = BitCodec.doubleLinear16.reader(reader);

      expect(result, 123.456);
      expect(writer.getBitsWritten(), 51);
    });

    test('codec_double_linear_64 encodes and decodes correctly', () {
      BitCodec.doubleLinear64.writer(writer, 123.456);
      final result = BitCodec.doubleLinear64.reader(reader);

      expect(result, 123.456);
      expect(writer.getBitsWritten(), 53);
    });

    test('codec_list encodes and decodes correctly', () {
      BitCodec.list.writer(writer, [1, 2, 3, 'Hello']);
      final result = BitCodec.list.reader(reader);

      expect(result, [1, 2, 3, 'Hello']);
      expect(writer.getBitsWritten(), 94);
    });

    test('codec_string_map encodes and decodes correctly', () {
      BitCodec.stringMap.writer(writer, {'key': 'value'});
      final result = BitCodec.stringMap.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 94);
    });

    test('codec_json encodes and decodes correctly', () {
      BitCodec.json.writer(writer, {'key': 'value'});
      final result = BitCodec.json.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 95);
    });

    test('codec_bool encodes and decodes correctly', () {
      BitCodec.boolean.writer(writer, true);
      final result = BitCodec.boolean.reader(reader);

      expect(result, true);
      expect(writer.getBitsWritten(), 1);
    });

    test('codec_json_string encodes and decodes correctly', () {
      BitCodec.jsonString.writer(writer, {'key': 'value'});
      final result = BitCodec.jsonString.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 131);
    });

    test('codec_json_string_map encodes and decodes correctly', () {
      BitCodec.jsonStringMap.writer(writer, {'key': 'value'});
      final result = BitCodec.jsonStringMap.reader(reader);

      expect(result, {'key': 'value'});
      expect(writer.getBitsWritten(), 131);
    });

    test('codec_any encodes and decodes correctly', () {
      BitCodec.any.writer(writer, 'Hello, World!');
      final result = BitCodec.any.reader(reader);

      expect(result, 'Hello, World!');
      expect(writer.getBitsWritten(), 118);
    });
  });

  group('Backwards Codec Compatibility', () {
    test('codec_string_compressed decodes correctly', () {
      final buffer = BitBuffer.fromBits([100059283527975748, 293721599081145], trueSize: 114);
      final result = BitCodec.stringCompressed.reader(buffer.reader());

      expect(result, 'Hello, World!');
    });

    test('codec_string_stepped decodes correctly', () {
      final buffer = BitBuffer.fromBits([100059283527975748, 293721599081145], trueSize: 114);
      final result = BitCodec.stringStepped.reader(buffer.reader());

      expect(result, 'Hello, World!');
    });

    test('codec_string_linear decodes correctly', () {
      final buffer = BitBuffer.fromBits([-6962012935230841020, -1982173524448681545, 17830542727], trueSize: 163);
      final result = BitCodec.stringLinear.reader(buffer.reader());

      expect(result, 'Hello, World!');
    });

    test('codec_stepped_utf16 decodes correctly', () {
      final buffer = BitBuffer.fromBits([24691], trueSize: 17);
      final result = BitCodec.steppedUtf16.reader(buffer.reader());

      expect(result, 12345);
    });

    test('codec_string_palette decodes correctly', () {
      final buffer = BitBuffer.fromBits([6665522876794609988, -8119263838298861111, 2629752564971], trueSize: 170);
      final result = BitCodec.stringPalette.reader(buffer.reader());

      expect(result, 'Hello, World!');
    });

    test('codec_int_linear_8 decodes correctly', () {
      final buffer = BitBuffer.fromBits([3959], trueSize: 12);
      final result = BitCodec.intLinear8.reader(buffer.reader());

      expect(result, 123);
    });

    test('codec_int_linear_16 decodes correctly', () {
      final buffer = BitBuffer.fromBits([790126], trueSize: 20);
      final result = BitCodec.intLinear16.reader(buffer.reader());

      expect(result, 12345);
    });

    test('codec_int_linear_64 decodes correctly', () {
      final buffer = BitBuffer.fromBits([31604938139], trueSize: 35);
      final result = BitCodec.intLinear64.reader(buffer.reader());

      expect(result, 123456789);
    });

    test('codec_double_linear_8 decodes correctly', () {
      final buffer = BitBuffer.fromBits([765041063513967], trueSize: 50);
      final result = BitCodec.doubleLinear8.reader(buffer.reader());

      expect(result, 123.456);
    });

    test('codec_double_linear_16 decodes correctly', () {
      final buffer = BitBuffer.fromBits([1530082127027919], trueSize: 51);
      final result = BitCodec.doubleLinear16.reader(buffer.reader());

      expect(result, 123.456);
    });

    test('codec_double_linear_64 decodes correctly', () {
      final buffer = BitBuffer.fromBits([6120328508111631], trueSize: 53);
      final result = BitCodec.doubleLinear64.reader(buffer.reader());

      expect(result, 123.456);
    });

    test('codec_list decodes correctly', () {
      final buffer = BitBuffer.fromBits([-3673361555328330108, 4014455708976232556, 17], trueSize: 134);
      final result = BitCodec.list.reader(buffer.reader());

      expect(result, [1, 2, 3, 'Hello']);
    });

    test('codec_string_map decodes correctly', () {
      final buffer = BitBuffer.fromBits([1240862530166686756, 18909578539195], trueSize: 110);
      final result = BitCodec.stringMap.reader(buffer.reader());

      expect(result, {'key': 'value'});
    });

    test('codec_json decodes correctly', () {
      final buffer = BitBuffer.fromBits([2481725060333373513, 37819157078390], trueSize: 111);
      final result = BitCodec.json.reader(buffer.reader());

      expect(result, {'key': 'value'});
    });

    test('codec_bool decodes correctly', () {
      final buffer = BitBuffer.fromBits([1], trueSize: 1);
      final result = BitCodec.boolean.reader(buffer.reader());

      expect(result, true);
    });

    test('codec_json_string decodes correctly', () {
      final buffer = BitBuffer.fromBits([-6762271016373209208, -3303857246427454941, 7], trueSize: 131);
      final result = BitCodec.jsonString.reader(buffer.reader());

      expect(result, {'key': 'value'});
    });

    test('codec_json_string_map decodes correctly', () {
      final buffer = BitBuffer.fromBits([-6762271016373209208, -3303857246427454941, 7], trueSize: 131);
      final result = BitCodec.jsonStringMap.reader(buffer.reader());

      expect(result, {'key': 'value'});
    });

    test('codec_any decodes correctly', () {
      final buffer = BitBuffer.fromBits([4014455708976233542, 1203083669836369942, 17], trueSize: 134);
      final result = BitCodec.any.reader(buffer.reader());

      expect(result, 'Hello, World!');
    });
  });

  group('BitCodec Edge Cases', () {
    late BitBuffer buffer;
    late BitBufferWriter writer;
    late BitBufferReader reader;

    setUp(() {
      buffer = BitBuffer();
      writer = buffer.writer();
      reader = buffer.reader();
    });

    group('String Codecs Edge Cases', () {
      test('empty string', () {
        BitCodec.stringCompressed.writer(writer, '');
        final result = BitCodec.stringCompressed.reader(reader);
        expect(result, '');
      });

      test('unicode characters', () {
        const testString = '🚀 Hello 世界! ñ € ❤️';
        BitCodec.stringCompressed.writer(writer, testString);
        final result = BitCodec.stringCompressed.reader(reader);
        expect(result, testString);
      });

      test('very long string', () {
        final longString = 'a' * 10000;
        BitCodec.stringCompressed.writer(writer, longString);
        final result = BitCodec.stringCompressed.reader(reader);
        expect(result, longString);
      });
    });

    group('Integer Codecs Edge Cases', () {
      test('negative numbers', () {
        BitCodec.intLinear64.writer(writer, -123456789);
        final result = BitCodec.intLinear64.reader(reader);
        expect(result, -123456789);
      });

      test('zero value', () {
        BitCodec.intLinear8.writer(writer, 0);
        final result = BitCodec.intLinear8.reader(reader);
        expect(result, 0);
      });

      test('maximum 64-bit value', () {
        const maxValue = 9223372036854775807; // 2^63 - 1
        BitCodec.intLinear64.writer(writer, maxValue);
        final result = BitCodec.intLinear64.reader(reader);
        expect(result, maxValue);
      });
    });

    /* TODO: Fix double edge cases
    group('Double Codecs Edge Cases', () {
      test('NaN value', () {
        BitCodec.doubleLinear64.writer(writer, double.nan);
        final result = BitCodec.doubleLinear64.reader(reader);
        expect(result.isNaN, true);
      });

      test('infinity', () {
        BitCodec.doubleLinear64.writer(writer, double.infinity);
        final result = BitCodec.doubleLinear64.reader(reader);
        expect(result, double.infinity);
      });

      test('negative infinity', () {
        BitCodec.doubleLinear64.writer(writer, double.negativeInfinity);
        final result = BitCodec.doubleLinear64.reader(reader);
        expect(result, double.negativeInfinity);
      });

      test('very small number', () {
        const smallNumber = 1.0e-308;
        BitCodec.doubleLinear64.writer(writer, smallNumber);
        final result = BitCodec.doubleLinear64.reader(reader);
        expect(result, smallNumber);
      });
    });
     */

    group('Collection Codecs Edge Cases', () {
      test('empty list', () {
        BitCodec.list.writer(writer, []);
        final result = BitCodec.list.reader(reader);
        expect(result, []);
      });

      test('empty map', () {
        BitCodec.stringMap.writer(writer, {});
        final result = BitCodec.stringMap.reader(reader);
        expect(result, {});
      });

      test('nested structures', () {
        final nestedData = {
          'list': [
            1,
            2,
            {'nested': true}
          ],
          'map': {
            'a': [1, 2, 3],
            'b': {'deep': 'value'}
          },
        };
        BitCodec.json.writer(writer, nestedData);
        final result = BitCodec.json.reader(reader);
        expect(result, nestedData);
      });

      test('list with mixed types', () {
        final mixedList = [
          1,
          'string',
          3.14,
          true,
          [1, 2],
          {'key': 'value'},
          null
        ];
        BitCodec.list.writer(writer, mixedList);
        final result = BitCodec.list.reader(reader);
        expect(result, mixedList);
      });
    });

    group('Any Codec Edge Cases', () {
      test('null value', () {
        BitCodec.any.writer(writer, null);
        final result = BitCodec.any.reader(reader);
        expect(result, null);
      });

      test('complex nested structure', () {
        const complexData = {
          'nullValue': null,
          'number': 42,
          'string': '🌟',
          'list': [
            1,
            null,
            'test',
            {'nested': true}
          ],
          'nestedMap': {
            'a': [1, 2, 3],
            'b': {
              'deep': {'deeper': 'value'}
            },
          }
        };
        BitCodec.any.writer(writer, complexData);
        final result = BitCodec.any.reader(reader);
        expect(result, complexData);
      });
    });
  });
}
