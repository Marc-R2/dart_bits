import 'dart:convert';
import 'dart:math';

import 'package:bits/bits.dart';
import 'package:test/test.dart';

void main() {
  BitBuffer().writer().writeCodec(codec_int_best, 19129292922929);

  String json = """
{
    "name": "Mushroom Forest Hills",
    "color": "#EEA8ED",
    "rarity": 1,
    "derivative": "MUSHROOM_FIELDS",
    "vanillaDerivative": "MUSHROOM_FIELDS",
    "customDerivitives": [{
        "category": "mushroom",
        "id": "mushroom_hills",
        "waterColor": "#B4B2FF",
        "foliageColor": "#CAB2DC",
        "waterFogColor": "#BD94DF",
        "grassColor": "#B39EC2",
        "fogColor": "#CACDFF"
    }],
    "generators": [{
        "min": 62,
        "max": 90,
        "generator": "plain"
    }],
    "wall": {
        "style": {"style": "STATIC"},
        "palette": [
            {"block": "minecraft:stone"},
            {"block": "minecraft:andesite"},
            {"block": "minecraft:stone"}
        ]
    },
    "layers": [
        {
            "minHeight": 3,
            "maxHeight": 5,
            "slopeCondition": {"minimumSlope": 6.9},
            "palette": [
                {"block": "minecraft:gravel"},
                {
                    "block": "minecraft:red_mushroom_block",
                    "data": {
                        "down": true,
                        "up": true,
                        "north": true,
                        "south": true,
                        "east": true,
                        "west": true
                    }
                }
            ]
        },
        {
            "minHeight": 3,
            "maxHeight": 5,
            "slopeCondition": {"minimumSlope": 4.6},
            "palette": [
                {"block": "minecraft:gravel"},
                {
                    "block": "minecraft:brown_mushroom_block",
                    "data": {
                        "down": true,
                        "up": true,
                        "north": true,
                        "south": true,
                        "east": true,
                        "west": true
                    }
                }
            ]
        },
        {
            "zoom": 0.5,
            "style": {"style": "NOWHERE"},
            "palette": [
                {
                    "weight": 4,
                    "block": "minecraft:mycelium"
                },
                {"block": "minecraft:gravel"},
                {
                    "weight": 3,
                    "block": "minecraft:mycelium"
                }
            ]
        },
        {
            "minHeight": 2,
            "maxHeight": 4,
            "palette": [
                {"block": "minecraft:dirt"},
                {"block": "minecraft:coarse_dirt"}
            ]
        },
        {
            "minHeight": 6,
            "maxHeight": 18,
            "style": {"style": "STATIC"},
            "palette": [
                {"block": "minecraft:stone"},
                {"block": "minecraft:andesite"},
                {"block": "minecraft:stone"}
            ]
        }
    ],
    "objects": [
        {
            "chance": 0.18,
            "density": 2,
            "rotation": {
                "yAxis": {
                    "min": 0,
                    "max": 0,
                    "interval": 90,
                    "enabled": true
                },
                "enabled": true
            },
            "place": [
                "trees/mushroom/mushclut1",
                "trees/mushroom/mushclut2",
                "trees/mushroom/mushclut3",
                "trees/mushroom/mushclut4",
                "trees/mushroom/mushclut5",
                "trees/mushroom/mushclut6",
                "trees/mushroom/mushclut7",
                "trees/mushroom/mushclut8",
                "trees/mushroom/mushclut9",
                "trees/mushroom/mushclut10"
            ],
            "mode": "PAINT",
            "translate": {
                "x": 0,
                "y": -1,
                "z": 0
            }
        },
        {
            "chance": 0.18,
            "density": 2,
            "edit": [{
                "find": [{"block": "minecraft:red_mushroom_block"}],
                "replace": {"palette": [{"block": "minecraft:brown_mushroom_block"}]}
            }],
            "rotation": {
                "yAxis": {
                    "min": 0,
                    "max": 0,
                    "interval": 90,
                    "enabled": true
                },
                "enabled": true
            },
            "place": [
                "trees/mushroom/mushclut1",
                "trees/mushroom/mushclut2",
                "trees/mushroom/mushclut3",
                "trees/mushroom/mushclut4",
                "trees/mushroom/mushclut5",
                "trees/mushroom/mushclut6",
                "trees/mushroom/mushclut7",
                "trees/mushroom/mushclut8",
                "trees/mushroom/mushclut9",
                "trees/mushroom/mushclut10"
            ],
            "translate": {
                "x": 0,
                "y": -1,
                "z": 0
            }
        },
        {
            "chance": 0.8,
            "density": 2,
            "rotation": {
                "yAxis": {
                    "min": 0,
                    "max": 0,
                    "interval": 90,
                    "enabled": true
                },
                "enabled": true
            },
            "place": [
                "trees/mushroom/browngeneric1",
                "trees/mushroom/browngeneric2",
                "trees/mushroom/redgeneric3",
                "trees/mushroom/redgeneric4",
                "trees/mushroom/redgeneric5",
                "trees/mushroom/redgeneric6",
                "trees/mushroom/redgeneric7",
                "trees/mushroom/redgeneric8",
                "trees/mushroom/redgeneric9",
                "trees/mushroom/redgeneric10",
                "trees/mushroom/redgeneric11"
            ],
            "translate": {
                "x": 0,
                "y": -1,
                "z": 0
            }
        },
        {
            "chance": 0.05,
            "density": 2,
            "edit": [{
                "find": [{"block": "minecraft:red_mushroom_block"}],
                "replace": {"palette": [{"block": "minecraft:brown_mushroom_block"}]}
            }],
            "rotation": {
                "yAxis": {
                    "min": 0,
                    "max": 0,
                    "interval": 90,
                    "enabled": true
                },
                "enabled": true
            },
            "place": [
                "trees/mushroom/redlumotall1",
                "trees/mushroom/redlumotall2",
                "trees/mushroom/redlumotall3",
                "trees/mushroom/redlumotall4",
                "trees/mushroom/redlumotall5",
                "trees/mushroom/redlumotall6",
                "trees/mushroom/redlumotall7",
                "trees/mushroom/redlumotall8",
                "trees/mushroom/redlumotall9",
                "trees/mushroom/redlumotall10",
                "trees/mushroom/redlumotall11"
            ],
            "translate": {
                "x": 0,
                "y": -1,
                "z": 0
            }
        },
        {
            "chance": 0.5,
            "density": 2,
            "edit": [{
                "find": [{"block": "minecraft:red_mushroom_block"}],
                "replace": {"palette": [{"block": "minecraft:brown_mushroom_block"}]}
            }],
            "rotation": {
                "yAxis": {
                    "min": 0,
                    "max": 0,
                    "interval": 90,
                    "enabled": true
                },
                "enabled": true
            },
            "place": [
                "trees/mushroom/browngeneric1",
                "trees/mushroom/browngeneric2",
                "trees/mushroom/redgeneric3",
                "trees/mushroom/redgeneric4",
                "trees/mushroom/redgeneric5",
                "trees/mushroom/redgeneric6",
                "trees/mushroom/redgeneric7",
                "trees/mushroom/redgeneric8",
                "trees/mushroom/redgeneric9",
                "trees/mushroom/redgeneric10",
                "trees/mushroom/redgeneric11"
            ],
            "translate": {
                "x": 0,
                "y": -1,
                "z": 0
            }
        },
        {
            "chance": 0.025,
            "density": 1,
            "edit": [{
                "find": [{"block": "minecraft:red_mushroom_block"}],
                "replace": {"palette": [{"block": "minecraft:brown_mushroom_block"}]}
            }],
            "rotation": {
                "yAxis": {
                    "min": 0,
                    "max": 0,
                    "interval": 90,
                    "enabled": true
                },
                "enabled": true
            },
            "place": [
                "trees/mushroom/smolshroom1",
                "trees/mushroom/smolshroom2",
                "trees/mushroom/smolshroom3",
                "trees/mushroom/smolshroom4",
                "trees/mushroom/smolshroom5"
            ],
            "translate": {
                "x": 0,
                "y": -1,
                "z": 0
            }
        },
        {
            "chance": 0.1,
            "density": 1,
            "rotation": {
                "yAxis": {
                    "min": 0,
                    "max": 0,
                    "interval": 90,
                    "enabled": true
                },
                "enabled": true
            },
            "place": [
                "trees/mushroom/smolshroom1",
                "trees/mushroom/smolshroom2",
                "trees/mushroom/smolshroom3",
                "trees/mushroom/smolshroom4",
                "trees/mushroom/smolshroom5"
            ],
            "translate": {
                "x": 0,
                "y": -1,
                "z": 0
            }
        }
    ],
    "decorators": [
        {
            "chance": 0.009,
            "variance": {"style": "STATIC"},
            "zoom": 0.3,
            "palette": [
                {
                    "data": {
                        "face": "floor",
                        "powered": false,
                        "facing": "east"
                    },
                    "block": "minecraft:stone_button"
                },
                {
                    "data": {
                        "face": "floor",
                        "powered": false,
                        "facing": "south"
                    },
                    "block": "minecraft:stone_button"
                }
            ],
            "style": {"style": "STATIC"}
        },
        {
            "chance": 0.05,
            "variance": {"style": "STATIC"},
            "zoom": 0.3,
            "palette": [
                {"block": "minecraft:red_mushroom"},
                {"block": "minecraft:brown_mushroom"}
            ],
            "style": {"style": "STATIC"}
        }
    ],
    "slab": {
        "style": {"style": "STATIC"},
        "palette": [
            {
                "weight": 8,
                "block": "minecraft:air"
            },
            {
                "data": {
                    "waterlogged": false,
                    "type": "bottom"
                },
                "block": "minecraft:cobblestone_slab"
            },
            {
                "weight": 10,
                "block": "minecraft:air"
            }
        ]
    }
}
  """;
  Map<String, dynamic> map = jsonDecode(json);
  map = compressJson(map);
  print(jsonEncode(map));
  map = decompressJson(map);
  print(jsonEncode(map));

  List<int> testInts = [
    0,
    1,
    -1,
    3,
    2,
    3854,
    -3346,
    1234567890,
    -1234567890,
    2147483647,
    -2147483748,
    4294967295,
    -4294967295,
    9223372036854775807,
    -922337203685477580
  ];
  List<double> testDoubles = [
    0,
    1,
    -1,
    0.1,
    3.5584,
    2.345666,
    2838455.12,
    29345588585.1118,
    -28388383838383.7771
  ];

  test('Palettes', () {
    List<String> data = [
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "noise",
      "noise",
      "ff",
      "sdds",
      "a",
      "c"
    ];
    BitCodec<String> codec = BitCodec<String>(
        writer: (BitBufferWriter writer, String t) => writer.writeString(t),
        reader: (BitBufferReader reader) => reader.readString());
    PaletteData<String> p = PaletteData<String>(codec: codec);
    data.forEach((e) => p.write(e));
    BitBuffer buffer = p.toBitBuffer();
    PaletteData<String> p2 =
        PaletteData<String>.fromBitBuffer(codec: codec, buf: buffer);
    expect(data, equals(p2.getAllData()));
  });

  test('Basic Copying & Loading & Exporting', () {
    int v = -23495995555553;
    BitBuffer buf = BitBuffer();
    buf.writer().writeInt(v);
    buf.writer().writeInt(-v * 33);
    buf.writer().writeInt(16);
    BitBuffer buf2 = BitBuffer.fromBB(buf);
    expect(buf2.getLongs(), equals(buf.getLongs()));
  });

  test('To/from bytes', () {
    int v = -2349599555553;
    BitBuffer buf = BitBuffer();
    buf.writer().writeInt(v);
    buf.writer().writeInt(-v * 33);
    buf.writer().writeInt(16);
    BitBuffer buf2 = BitBuffer.fromUInt8List(buf.toUInt8List());
    expect(buf2.getLongs(), equals(buf.getLongs()));
  });

  test('To/from Strings', () {
    int v = -2349599555553;
    BitBuffer buf = BitBuffer();
    buf.writer().writeInt(v);
    buf.writer().writeInt(-v * 33);
    buf.writer().writeInt(16);
    BitBuffer buf2 = BitBuffer.fromBase64Compressed(buf.toBase64Compressed());
    expect(buf2.getLongs(), equals(buf.getLongs()));
  });
  String x =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+-=[]{};':\",./<>?`~";

  test(
      'Test writeString',
      () => expect(x,
          equals((BitBuffer()..writer().writeString(x)).reader().readString()),
          reason: 'Failed to readString ${x}'));

  for (int i = 0; i < 32; i++) {
    String s = List.generate(
            Random().nextInt(32) + 32, (index) => x[Random().nextInt(x.length)])
        .join();
    test(
        'Test writeString rng$i',
        () => expect(
            s,
            equals(
                (BitBuffer()..writer().writeString(s)).reader().readString()),
            reason: 'Failed to readString ${s}'));

    test(
        'Test writeLinearVarString rng$i',
        () => expect(
            s,
            equals((BitBuffer()..writer().writeLinearVarString(s))
                .reader()
                .readLinearVarString()),
            reason: 'Failed to readLinearVarString ${s}'));

    test(
        'Test writeSteppedVarString rng$i',
        () => expect(
            s,
            equals((BitBuffer()..writer().writeSteppedVarString(s))
                .reader()
                .readSteppedVarString()),
            reason: 'Failed to readSteppedVarString ${s}'));
  }

  test(
      'Test writeLinearVarString',
      () => expect(
          x,
          equals((BitBuffer()..writer().writeLinearVarString(x))
              .reader()
              .readLinearVarString()),
          reason: 'Failed to readLinearVarString ${x}'));

  test(
      'Test writeSteppedVarString',
      () => expect(
          x,
          equals((BitBuffer()..writer().writeSteppedVarString(x))
              .reader()
              .readSteppedVarString()),
          reason: 'Failed to readSteppedVarString ${x}'));

  for (double i in testDoubles) {
    test(
        'Test writeDouble',
        () => expect(
            i,
            equals(
                (BitBuffer()..writer().writeDouble(i)).reader().readDouble()),
            reason: 'Failed to writeDouble ${i}'));
    test(
        'Test writeUDouble',
        () => expect(
            i.abs(),
            equals((BitBuffer()..writer().writeDouble(i.abs(), signed: false))
                .reader()
                .readDouble(signed: false)),
            reason: 'Failed to writeDouble ${i.abs()}'));
    test(
        'Test writeLinearVarDouble',
        () => expect(
            i,
            equals((BitBuffer()..writer().writeLinearVarDouble(i))
                .reader()
                .readLinearVarDouble()),
            reason: 'Failed to writeDouble ${i}'));
    test(
        'Test writeSteppedVarDouble',
        () => expect(
            i,
            equals((BitBuffer()..writer().writeSteppedVarDouble(i))
                .reader()
                .readSteppedVarDouble()),
            reason: 'Failed to writeDouble ${i}'));
  }

  for (int id = 1; id < 63; id++) {
    for (int i = (-pow(2, id).toInt()) + 1;
        i < (pow(2, id).toInt()) - 1;
        i += ((pow(2, id).toInt() ~/ 4) + 1)) {
      test(
          'Test writeLinearVarInt with $id max bits',
          () => expect(
              i,
              equals((BitBuffer()..writer().writeLinearVarInt(i, maxBits: id))
                  .reader()
                  .readLinearVarInt(maxBits: id)),
              reason: 'Failed to writeLinearVarInt[$id max bits] ${i}'));
      test(
          'Test writeInt with $id max bits',
          () => expect(
              i,
              equals((BitBuffer()..writer().writeInt(i, bits: id))
                  .reader()
                  .readInt(bits: id)),
              reason: 'Failed to writeInt[$id bits] ${i}'));
    }
  }

  for (int i in testInts) {
    test(
        'Test writeInt',
        () => expect(
            i, equals((BitBuffer()..writer().writeInt(i)).reader().readInt()),
            reason: 'Failed to writeInt ${i}'));
    test(
        'Test writeUInt',
        () => expect(
            i.abs(),
            equals((BitBuffer()..writer().writeInt(i.abs(), signed: false))
                .reader()
                .readInt(signed: false)),
            reason: 'Failed to writeInt ${i.abs()}'));
    test(
        'Test writeLinearVarInt',
        () => expect(
            i,
            equals((BitBuffer()..writer().writeLinearVarInt(i))
                .reader()
                .readLinearVarInt()),
            reason: 'Failed to writeLinearVarInt ${i}'));
    test(
        'Test writeSteppedVarInt',
        () => expect(
            i,
            equals((BitBuffer()..writer().writeSteppedVarInt(i))
                .reader()
                .readSteppedVarInt()),
            reason: 'Failed to writeSteppedVarInt ${i}'));
  }
}

Iterable<int> randomInts(int count) sync* {
  final random = Random();
  for (var i = 0; i < count; i++) {
    yield random.nextInt(0x100000000) * (random.nextBool() ? -1 : 1);
  }
}

Iterable<double> randomDoubles(int count) sync* {
  final random = Random();
  for (var i = 0; i < count; i++) {
    yield random.nextDouble() *
        212949.113456345634564 *
        (random.nextBool() ? -1 : 1);
  }
}
