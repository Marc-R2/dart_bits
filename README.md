Write data in bits for more control over the data you write. This is useful for writing binary data.

## Features

### Bit Buffers

You can create a BitBuffer from / export to the following formats
* UInt8List
* ByteBuffer
* BytesBuilder
* ByteData
* Base64 Strings
* Compressed Base64 Strings (see threshold package)
* 
### Data Types

* Write VarUInts (8, 16, 32, 64)
  * 2 bits for the length of the VarUInt
  * 8-64 bits for the value
  * __10-70 bits total__
* Write VarInts (8, 16, 32, 64)
  * 1 bit for the sign
  * 2 bits for the length of the VarInt
  * 8-64 bits for the value
  * __11-71 bits total__
* Write VarDoubles (8, 16, 32, 64) with variable precision
  * 1 bit for the sign
  * 2 bits for the length of the VarDouble
  * 1-4 bits for the precision (0-15 digits of max precision)
  * 8-64 bits for the value
  * __12-75 bits total__
* Write VarUIntLists (8, 16, 32, 64)
  * 10-70 bits for the length of the list
  * 2 bits for the length of the biggest VarUInt in the list
  * 8-64 bits per entry
  * __12-72 bits for the header__
* Write VarIntLists (8, 16, 32, 64)
  * 10-70 bits for the length of the list
  * 2 bits for the length of the biggest VarInt in the list
  * 9-65 bits per entry (1 bit for the sign)
  * __12-72 bits for the header__

## Usage

```dart
import 'package:bits/bits.dart';

void main()
{
  // Create a buffer
  BitBuffer buffer = BitBuffer();
  
  // Write Data
  buffer.writeVarUInt(12); // Positive only (unsigned)
  buffer.writeVarInt(-12); // Positive and negative
  buffer.writeVarDouble(12.34); // Default precision is 8
  buffer.writeVarDouble(12.34, precision: 2); // 2 digits of precision
  buffer.writeVarUIntList([1, 2, 3, 4, 5]); // List of VarUInts
  buffer.writeVarIntList([-1, 2, -3, 4, -5]); // List of VarInts
  buffer.writeVarDoubleList([1.23, 4.56, 7.89], maxPrecision: 2); // List of VarDoubles
  
  // You can also write bits directly
  buffer.writeBits(0b10, 2); // Write 2 in 2 bits
  buffer.writeBits(0b101, 3); // Write 5 in 3 bits
  buffer.writeBits(28, buffer.getBitsNeeded(32)); // Write 28 in the minimum bits required to handle a maximum of 32.
  
  // Read Data (in the same order)
  print(buffer.readVarUInt()); // 12
  print(buffer.readVarInt()); // -12
  print(buffer.readVarDouble()); // 12.34
  print(buffer.readVarDouble(precision: 2)); // 12.34
  print(buffer.readVarUIntList()); // [1, 2, 3, 4, 5]
  print(buffer.readVarIntList()); // [-1, 2, -3, 4, -5]
  print(buffer.readVarDoubleList(maxPrecision: 2)); // [1.23, 4.56, 7.89]
  
  // You can also read bits directly
  print(buffer.readBits(2)); // 2
  print(buffer.readBits(3)); // 5
  print(buffer.readBits(buffer.getBitsNeeded(32))); // 28
}
```
