# BitBuffer

`BitBuffer` is an efficient utility library for bit-level data manipulation, supporting various data types such as integers, floating-point numbers, strings, and more. It provides flexible construction methods and data encoding strategies.

## Features

- Support for little-endian and big-endian byte orders.
- Construction from integer lists, byte lists (`UInt8List`), and Base64 strings.
- Encoding and decoding of linear and stepped variable-length integers and floating-point numbers.
- Support for single-bit operations and multi-bit batch operations.
- Flexible encoding for strings.

## Getting Started

### Creating a `BitBuffer`
- Default constructor with support for little-endian and big-endian byte orders.
- Construct from existing data, including integer lists, byte lists, and Base64 strings.
- Clone an existing `BitBuffer`.

### Writing Data
- Fixed-width integer writing.
- Linear and stepped variable-length integer encoding.
- Support for writing floating-point numbers, strings, and boolean values.

### Reading Data
- Read fixed-width, linear variable-length, and stepped variable-length integers.
- Read floating-point numbers, strings, and boolean values.

## Usage

```dart
  /// Creates a new `BitBuffer` object.
  ///
  /// The `BitBuffer` is initialized with a specified byte order (`endian`).
  ///
  /// ### Parameters:
  /// - `endian` (optional): Defines the byte order of the buffer.
  ///   - `Endian.little`: Little-endian order (default).
  ///   - `Endian.big`: Big-endian order.
  BitBuffer buffer1 = BitBuffer(Endian.little); // or Endian.big

  /// Creates a `BitBuffer` from a list of integers, interpreting each integer as a specified number of bits.
  ///
  /// ### Parameters:
  /// - `data`: A list of integers to be converted into the `BitBuffer`.
  /// - `bitsPerIndex` (optional): The number of bits used to represent each integer in the list.
  ///   - Default: `bitsPerInt` (platform-specific, typically 32 or 64 bits).
  /// - `trueSize` (optional): Specifies the exact number of bits to consider from the input.
  ///   - If `null`, the size is calculated based on the entire input data.
  /// ### Notes:
  /// - The `bitsPerIndex` parameter determines how each integer in `data` is encoded.
  /// - The `trueSize` parameter allows fine-grained control over the actual bit length of the buffer.
  ///
  /// Example: 11110100111101001111010010000000 (32 bits) 8*4
  ///          11110100 (LSB first) 0x2F
  ///          11110100 (LSB first) 0x2F
  ///          11110100 (LSB first) 0x2F
  ///          10000000 (LSB first) 0x01
  BitBuffer buffer2 = BitBuffer.fromBits([0x2F, 0x2F, 0x2F, 0x01], bitsPerIndex: 8);

  /// Example: 1111010000000000000000000000000000000000000000000000000000000000111101000000000000000000000000000000000000000000000000000000000011110100000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000 (256 bits) 64*4
  ///          1111010000000000000000000000000000000000000000000000000000000000 (LSB first) 0x2F
  ///          1111010000000000000000000000000000000000000000000000000000000000 (LSB first) 0x2F
  ///          1111010000000000000000000000000000000000000000000000000000000000 (LSB first) 0x2F
  ///          1000000000000000000000000000000000000000000000000000000000000000 (LSB first) 0x01
  BitBuffer buffer3 = BitBuffer.fromBits([0x2F, 0x2F, 0x2F, 0x01], bitsPerIndex: 64);

  /// Creates a `BitBuffer` from a list of unsigned 8-bit integers (bytes).
  ///
  /// ### Parameters:
  /// - `bytes`: A list of integers (0–255) representing the byte values to be converted into the `BitBuffer`.
  ///
  /// ### Notes:
  /// - Each integer in the `bytes` list is treated as a single 8-bit value.
  /// - The resulting `BitBuffer` will have a size equal to `bytes.length * 8` bits.
  ///
  /// Example: 11110100111101001111010010000000 (32 bits) 8*4
  ///          11110100 (LSB first) 0x2F
  ///          11110100 (LSB first) 0x2F
  ///          11110100 (LSB first) 0x2F
  ///          10000000 (LSB first) 0x01
  BitBuffer buffer4 = BitBuffer.fromUInt8List([0x2F, 0x2F, 0x2F, 0x01]);

  /// Creates a new `BitBuffer` by cloning an existing `BitBuffer`.
  ///
  /// The new `BitBuffer` is initialized using the bit data, `bitsPerIndex`, and size from the source `BitBuffer`.
  ///
  /// ### Parameters:
  /// - `obb`: The source `BitBuffer` to be cloned.
  ///
  /// ### Notes:
  /// - The `bitsPerIndex` of the new `BitBuffer` is inherited from the source buffer.
  /// - The `_size` of the new `BitBuffer` is set to match the source buffer's true size.
  /// - This is a convenient way to duplicate an existing `BitBuffer` without manually reinitializing it.
  ///
  /// Example: 1111010000000000000000000000000000000000000000000000000000000000111101000000000000000000000000000000000000000000000000000000000011110100000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000 (256 bits) 64*4
  ///          1111010000000000000000000000000000000000000000000000000000000000 (LSB first) 0x2F
  ///          1111010000000000000000000000000000000000000000000000000000000000 (LSB first) 0x2F
  ///          1111010000000000000000000000000000000000000000000000000000000000 (LSB first) 0x2F
  ///          1000000000000000000000000000000000000000000000000000000000000000 (LSB first) 0x01
  BitBuffer buffer5 = BitBuffer.fromBB(buffer3);

  /// Example: 1111010011110100111101001000000000000000000000000000000000000000 (64 bits) 8*8
  ///          11110100 (LSB first) 0x2F
  ///          11110100 (LSB first) 0x2F
  ///          11110100 (LSB first) 0x2F
  ///          10000000 (LSB first) 0x01
  ///          00000000 (LSB first) 0x00
  ///          00000000 (LSB first) 0x00
  ///          00000000 (LSB first) 0x00
  ///          00000000 (LSB first) 0x00
  BitBuffer buffer6 = BitBuffer.fromBB(buffer4);

  /// Creates a `BitBuffer` from a Base64-encoded string.
  ///
  /// The Base64 string is first decoded into a list of bytes, which is then converted into a `BitBuffer`.
  ///
  /// ### Parameters:
  /// - `compressed`: The Base64-encoded string to be decoded and converted into a `BitBuffer`.
  ///
  /// ### Notes:
  /// - The Base64 string is decoded using the standard Base64 decoding.
  /// - The resulting `BitBuffer` represents the decoded bytes as binary data.
  ///
  /// Example: 10000110010001101100011000100110 (32 bits)
  ///          "YWJjZA==" -> "abcd" -> 0x61 0x62 0x63 0x64 -> 10000110 (LSB first) ...
  BitBuffer buffer7 = BitBuffer.fromBase64("YWJjZA==");

  BitBuffer buffer8 = BitBuffer.fromBase64Compressed("YWJjZA==");

  BitBuffer buffer = BitBuffer();
  BitBufferWriter writer = buffer.writer();

  /// Writes an integer value to the `BitBuffer` with the specified bit width and sign.
  ///
  /// ### Parameters:
  /// - `value`: The integer value to be written into the `BitBuffer`.
  /// - `signed` (optional): Determines whether the value is treated as signed or unsigned.
  ///   - `true` (default): Treats the value as signed (e.g., supports negative values).
  ///   - `false`: Treats the value as unsigned.
  /// - `bits` (optional): The number of bits to use for representing the value.
  ///   - Default: `64` bits.
  ///
  /// ### Notes:
  /// - The `bits` parameter must be large enough to hold the `value` (e.g., an 8-bit integer cannot hold values outside the range -128 to 127 for signed integers).
  /// - If `signed` is `false`, the `value` must be non-negative and within the range allowed by `bits`.
  /// Example: 1111010000000000000000000000000000000000000000000000000000000000 (64 bits)   64(parameters:bits)
  ///          1111010000000000000000000000000000000000000000000000000000000000 (LSB first) 0x2F
  writer.writeInt(0x2F, signed: false, bits: 64);

  /// Example:111110100000000000000000000000000 (33 bits)   1(sign)+32
  ///         1                                 (LSB first) sign
  ///          11111010000000000000000000000000 (LSB first) 0x2F
  // writer.writeInt(0x2F, signed: true, bits: 32);

  /// Example: 11111010000000000000000000000000000000000000000000000000000000000 (65 bits) 1(sign)+64(parameters:bits)
  ///          1                                                                 (LSB first) sign
  ///           1111010000000000000000000000000000000000000000000000000000000000 (LSB first) 0x2F
  writer.writeInt(0x2F, signed: true, bits: 64);

  /// Writes a linear variable-length integer to the `BitBuffer`.
  ///
  /// This method encodes an integer value using a specified maximum bit width and sign.
  /// It adapts the bit length based on the value, ensuring efficient storage.
  ///
  /// ### Parameters:
  /// - `value`: The integer value to be written into the `BitBuffer`.
  /// - `signed` (optional): Specifies whether the value is treated as signed or unsigned.
  ///   - `true` (default): Treats the value as signed (e.g., supports negative values).
  ///   - `false`: Treats the value as unsigned.
  /// - `maxBits` (optional): The maximum number of bits available for encoding the value.
  ///   - Default: `64` bits.
  ///
  /// ### Notes:
  /// - The method optimizes the bit representation based on the value's magnitude.
  /// - If `signed` is `false`, the `value` must be non-negative and fit within the specified `maxBits`.
  /// - If the value exceeds the available bit space, it may result in data loss or an exception.
  ///
  /// ### Common Use Cases:
  /// - Encoding integers for protocols or formats where variable-length representation is desired.
  /// - Minimizing the size of encoded data by dynamically adjusting bit usage.
  ///
  /// Example:0110000111101 (13 bits)   7(constant)+6(var)
  ///         0110000       (LSB first) 0x06
  ///                111101 (LSB first) 0x2F
  writer.writeLinearVarInt(0x2F, signed: false, maxBits: 64);

  /// Example:0110001111101 (13 bits)   6(constant)+1(sign)+6(var)
  ///         011000        (LSB first) 0x06
  ///               1       (LSB first) sign
  ///                111101 (LSB first) 0x2F
  writer.writeLinearVarInt(0x2F, signed: true, maxBits: 32);

  /// Example:01100001111101 (14 bits)   7(constant)+1(sign)+6(var)
  ///         0110000        (LSB first) 0x06
  ///                1       (LSB first) sign
  ///                 111101 (LSB first) 0x2F
  writer.writeLinearVarInt(0x2F, signed: true, maxBits: 64);

  /// Writes a stepped variable-length integer to the `BitBuffer`.
  ///
  /// This method encodes an integer using a stepped bit-length approach.
  /// The bit length is dynamically chosen from the provided `bitLimits` list based on the value's size.
  ///
  /// ### Parameters:
  /// - `value`: The integer value to be written into the `BitBuffer`.
  /// - `signed` (optional): Determines whether the value is treated as signed or unsigned.
  ///   - `true` (default): Treats the value as signed (supports negative values).
  ///   - `false`: Treats the value as unsigned.
  /// - `bitLimits` (optional): A list of bit-length limits to determine encoding steps.
  ///   - Default: `stepList2b`, a predefined list of stepped limits.
  ///
  /// ### Notes:
  /// - The method selects the smallest bit-length from `bitLimits` that can accommodate the value.
  /// - If `signed` is `false`, the `value` must be non-negative and fit within the largest bit limit.
  /// - Ensure that `bitLimits` contains valid and ascending values to avoid unexpected behavior.
  ///
  /// ### Common Use Cases:
  /// - Encoding integers with fine-grained control over size optimization.
  /// - Storing variable-length integers in data streams or protocols with stepped encoding strategies.
  /// Example:0011110100 (10 bits)   2+8
  ///         00         (LSB first) 0x00
  ///           11110100 (LSB first) 0x2F
  writer.writeSteppedVarInt(0x2F, signed: false, bitLimits: stepList2b);

  /// Example:10011110100 (11 bits)   2+1+8
  ///         00          (LSB first) 0x00
  ///           1         (LSB first) sign
  ///           11110100  (LSB first) 0x2F
  writer.writeSteppedVarInt(0x2F, signed: true, bitLimits: stepList2b);
  writer.writeSteppedVarInt(0x2F, signed: true, bitLimits: [8, 16, 32, 64]);

  /// Writes the specified number of bits from an integer value into the `BitBuffer`.
  ///
  /// The method extracts the least significant `bits` from the `value` and writes them to the buffer.
  ///
  /// ### Parameters:
  /// - `value`: The integer value from which bits will be written.
  /// - `bits`: The number of bits to write from the `value`.
  ///
  /// ### Notes:
  /// - The `bits` parameter determines how many bits to extract from the `value`.
  /// - If the `value` contains more bits than specified, only the least significant `bits` are written.
  /// - Ensure the `bits` parameter is within a valid range (e.g., 1–32 or 1–64, depending on platform limits).
  ///
  /// ### Common Use Cases:
  /// - Writing specific parts of an integer to a bit stream.
  /// - Packing multiple values into a single binary buffer.
  /// Example:1111010 (7 bits)
  writer.writeBits(0x2F, 7);

  /// Example:1111010000000 (13 bits)
  writer.writeBits(0x2F, 13);

  writer.writeBit(true); //or false
  writer.writeDouble(0.01, signed: true, bits: 64, maxDecimal: 8);
  writer.writeLinearVarDouble(0.01, signed: true, maxBits: 64, maxDecimal: 8);
  writer.writeSteppedVarDouble(0.01, signed: true, bitLimits: stepList2b, decimalBitLimits: stepDecList2b);
  writer.writeString("abcd");
  writer.writeLinearVarString("abcd");
  writer.writeSteppedVarString("abcd", steps: stepCharList1b);

  BitBufferReader reader = buffer.reader();
  reader.readInt();
  reader.readLinearVarInt();
  reader.readSteppedVarInt();
  reader.readDouble();
  reader.readLinearVarDouble();
  reader.readSteppedVarDouble();
  reader.readString();
  reader.readLinearVarString();
  reader.readSteppedVarString();
  reader.readBits(bits);
  reader.readBit();
  reader.readBit();
```