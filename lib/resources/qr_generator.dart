import 'dart:convert';
import 'dart:typed_data';

/// Generates a TLV (Tag-Length-Value) string from the given data.
///
/// [data] - A map where the key is the tag and the value is the associated data.
///
/// Returns the TLV string.
// String generateTlv(Map<int, dynamic> data) {
//   StringBuffer tlv = StringBuffer();
//
//   data.forEach((tag, value) {
//     tlv.write(tag.toRadixString(16).padLeft(2, '0')); // Tag in hex
//
//     List<int> valueBytes;
//     if (value is String) {
//       valueBytes = utf8.encode(value); // String → UTF-8 bytes
//     } else if (value is Uint8List) {
//       valueBytes = value; // Already bytes
//     } else {
//       throw ArgumentError('Unsupported value type for tag $tag');
//     }
//
//     tlv.write(valueBytes.length.toRadixString(16).padLeft(2, '0')); // Length
//     tlv.write(valueBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()); // Value as hex
//   });
//
//   return tlv.toString();
// }

String generateTlv(Map<int, dynamic> data) {
  StringBuffer tlv = StringBuffer();

  data.forEach((tag, value) {
    tlv.write(tag.toRadixString(16).padLeft(2, '0')); // Tag in hex

    List<int> valueBytes;

    if (value is String) {
      valueBytes = utf8.encode(value); // String → UTF-8 bytes
    } else if (value is Uint8List || value is List<int>) {
      valueBytes = List<int>.from(value); // Treat as raw bytes
    } else {
      throw ArgumentError('Unsupported value type for tag $tag');
    }

    // Write length in hex (two digits)
    tlv.write(valueBytes.length.toRadixString(16).padLeft(2, '0'));

    // Write value bytes as hex
    for (int byte in valueBytes) {
      tlv.write(byte.toRadixString(16).padLeft(2, '0'));
    }
  });

  return tlv.toString();
}

String tlvToBase64(String tlv) {
  List<int> bytes = [];

  for (int i = 0; i < tlv.length; i += 2) {
    String hexStr = tlv.substring(i, i + 2);
    int byte = int.parse(hexStr, radix: 16);
    bytes.add(byte);
  }

  return base64Encode(Uint8List.fromList(bytes));
}

// String generateTlv1(Map<int, String> data) {
//   StringBuffer tlv = StringBuffer();
//   data.forEach((tag, value) {
//     String tagHex = tag.toRadixString(16).padLeft(2, '0'); // Convert tag to hex
//     String valueHex = _stringToHex(value); // Convert value to hex
//     String lengthHex = value.length
//         .toRadixString(16)
//         .padLeft(2, '0'); // Length in hex
//
//     // Concatenate tag, length, and value into the TLV structure
//     tlv.write(tagHex);
//     tlv.write(lengthHex);
//     tlv.write(valueHex);
//   });
//
//   return tlv.toString();
// }

/// Converts a TLV string to its Base64 representation.
///
/// [tlv] - The TLV string to convert.
///
/// Returns the Base64 representation of the TLV string.
// String tlvToBase64(String tlv) {
//   List<int> bytes = [];
//
//   for (int i = 0; i < tlv.length; i += 2) {
//     String hexStr = tlv.substring(i, i + 2); // Two hex characters at a time
//     int byte = int.parse(hexStr, radix: 16); // Parse as a byte
//     bytes.add(byte);
//   }
//
//   Uint8List byteArray = Uint8List.fromList(bytes);
//   return base64Encode(byteArray); // Convert to Base64
// }

/// Converts a string to its hexadecimal representation.
///
/// [input] - The input string to convert.
///
/// Returns the hexadecimal representation of the string.
String _stringToHex(String input) {
  return input.codeUnits
      .map((unit) => unit.toRadixString(16).padLeft(2, '0'))
      .join();
}

String _hexToString(String hex) {
  List<int> codeUnits = [];
  for (int i = 0; i < hex.length; i += 2) {
    String hexPair = hex.substring(i, i + 2);
    codeUnits.add(int.parse(hexPair, radix: 16));
  }
  return String.fromCharCodes(codeUnits);
}
