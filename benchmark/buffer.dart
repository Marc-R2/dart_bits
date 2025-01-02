import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:bits/bits.dart';

class BenchmarkBufferWriter extends BenchmarkBase {
  BenchmarkBufferWriter(
    String name,
    this.func, {
    this.doSetup = true,
  }) : super('BufferWriter.$name');

  late BitBuffer buffer = BitBuffer();

  late BitBufferWriter writer = BitBufferWriter(buffer);

  final void Function(BitBufferWriter) func;

  final bool doSetup;

  @override
  void setup() {
    if (!doSetup) return;
    buffer = BitBuffer();
    writer = BitBufferWriter(buffer);
  }

  @override
  void run() => func(writer);
}

void main() {
  BenchmarkBufferWriter('writeBit(true)', (w) => w.writeBit(true)).report();
  BenchmarkBufferWriter('writeBit(false)', (w) => w.writeBit(false)).report();

  var bit = true;
  BenchmarkBufferWriter('writeBit', (w) => w.writeBit(bit = !bit)).report();

  var intVal = 0;
  BenchmarkBufferWriter(
    'writeInt(0)',
    (w) => w.writeInt(intVal),
  ).report();
  BenchmarkBufferWriter(
    'writeInt',
    (w) => w.writeInt(intVal++),
  ).report();
  BenchmarkBufferWriter(
    'writeInt($intVal)',
    (w) => w.writeInt(intVal),
  ).report();

  intVal = 0;
  BenchmarkBufferWriter('writeInt25(0)', (w) => w.writeInt(intVal, bits: 25))
      .report();
  BenchmarkBufferWriter(
    'writeInt25',
    (w) => w.writeInt(intVal++, bits: 25),
  ).report();
  BenchmarkBufferWriter(
    'writeInt25($intVal)',
    (w) => w.writeInt(intVal, bits: 25),
  ).report();

  var doubleVal = 0.0;
  BenchmarkBufferWriter(
    'writeDouble(0.0)',
    (w) => w.writeDouble(doubleVal),
  ).report();
  BenchmarkBufferWriter(
    'writeDouble',
    (w) => w.writeDouble(doubleVal++),
  ).report();
  BenchmarkBufferWriter(
    'writeDouble($doubleVal)',
    (w) => w.writeDouble(doubleVal),
  ).report();

  var stringNr = 0;
  BenchmarkBufferWriter(
    'writeString("")',
    (w) => w.writeString(stringNr.toString()),
  ).report();
  BenchmarkBufferWriter(
    'writeString',
    (w) => w.writeString((stringNr++).toString()),
  ).report();
  BenchmarkBufferWriter(
    'writeString("${stringNr.toString()}")',
    (w) => w.writeString(stringNr.toString()),
  ).report();

  stringNr = 0;
  BenchmarkBufferWriter(
    'writeLinearVarString("")',
    (w) => w.writeLinearVarString(stringNr.toString()),
  ).report();
  BenchmarkBufferWriter(
    'writeLinearVarString',
    (w) => w.writeLinearVarString((stringNr++).toString()),
  ).report();
  BenchmarkBufferWriter(
    'writeLinearVarString("${stringNr.toString()}")',
    (w) => w.writeLinearVarString(stringNr.toString()),
  ).report();

  stringNr = 0;
  BenchmarkBufferWriter(
    'writeSteppedVarString("")',
    (w) => w.writeSteppedVarString(stringNr.toString()),
  ).report();
  BenchmarkBufferWriter(
    'writeSteppedVarString',
    (w) => w.writeSteppedVarString((stringNr++).toString()),
  ).report();
  BenchmarkBufferWriter(
    'writeSteppedVarString("${stringNr.toString()}")',
    (w) => w.writeSteppedVarString(stringNr.toString()),
  ).report();

  doubleVal = 0.0;
  BenchmarkBufferWriter(
    'writeLinearVarDouble(0.0)',
    (w) => w.writeLinearVarDouble(doubleVal),
  ).report();
  BenchmarkBufferWriter(
    'writeLinearVarDouble',
    (w) => w.writeLinearVarDouble(doubleVal++),
  ).report();
  BenchmarkBufferWriter(
    'writeLinearVarDouble($doubleVal)',
    (w) => w.writeLinearVarDouble(doubleVal),
  ).report();

  doubleVal = 0.0;
  BenchmarkBufferWriter(
    'writeSteppedVarDouble(0.0)',
    (w) => w.writeSteppedVarDouble(doubleVal),
  ).report();
  BenchmarkBufferWriter(
    'writeSteppedVarDouble',
    (w) => w.writeSteppedVarDouble(doubleVal++),
  ).report();
  BenchmarkBufferWriter(
    'writeSteppedVarDouble($doubleVal)',
    (w) => w.writeSteppedVarDouble(doubleVal),
  ).report();

  intVal = 0;
  BenchmarkBufferWriter(
    'writeLinearVarInt(0)',
    (w) => w.writeLinearVarInt(intVal),
  ).report();
  BenchmarkBufferWriter(
    'writeLinearVarInt',
    (w) => w.writeLinearVarInt(intVal++),
  ).report();
  BenchmarkBufferWriter(
    'writeLinearVarInt($intVal)',
    (w) => w.writeLinearVarInt(intVal),
  ).report();

  intVal = 0;
  BenchmarkBufferWriter(
    'writeSteppedVarInt(0)',
    (w) => w.writeSteppedVarInt(intVal),
  ).report();
  BenchmarkBufferWriter(
    'writeSteppedVarInt',
    (w) => w.writeSteppedVarInt(intVal++),
  ).report();
  BenchmarkBufferWriter(
    'writeSteppedVarInt($intVal)',
    (w) => w.writeSteppedVarInt(intVal),
  ).report();
}
