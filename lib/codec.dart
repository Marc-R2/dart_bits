import 'package:bits/bits.dart';

typedef BitCodecWriter<T> = void Function(BitBufferWriter writer, T t);
typedef BitCodecReader<T> = T Function(BitBufferReader reader);

class BitCodec<T> {
  final BitCodecWriter<T> writer;
  final BitCodecReader<T> reader;

  BitCodec({required this.writer, required this.reader});
}
