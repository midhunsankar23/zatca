import 'dart:convert';
import 'dart:typed_data';

/// Generates a TLV (Tag-Length-Value) string from the given data.
///
/// [data] - A map where the key is the tag and the value is the associated data.
///
/// Returns the TLV string.
String generateTlv(Map<int, String> data) {
  StringBuffer tlv = StringBuffer();

  data.forEach((tag, value) {
    String tagHex = tag.toRadixString(16).padLeft(2, '0'); // Convert tag to hex
    String valueHex = _stringToHex(value); // Convert value to hex
    String lengthHex = value.length
        .toRadixString(16)
        .padLeft(2, '0'); // Length in hex

    // Concatenate tag, length, and value into the TLV structure
    tlv.write(tagHex);
    tlv.write(lengthHex);
    tlv.write(valueHex);
  });

  return tlv.toString();
}

/// Converts a TLV string to its Base64 representation.
///
/// [tlv] - The TLV string to convert.
///
/// Returns the Base64 representation of the TLV string.
String tlvToBase64(String tlv) {
  List<int> bytes = [];

  for (int i = 0; i < tlv.length; i += 2) {
    String hexStr = tlv.substring(i, i + 2); // Two hex characters at a time
    int byte = int.parse(hexStr, radix: 16); // Parse as a byte
    bytes.add(byte);
  }

  Uint8List byteArray = Uint8List.fromList(bytes);
  return base64Encode(byteArray); // Convert to Base64
}

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
