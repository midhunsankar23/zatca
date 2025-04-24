import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';

/// Converts a BigInt to a byte array.
Uint8List bigIntToByteArray(BigInt number) {
  if (number == BigInt.zero) {
    return Uint8List(1);
  }

  final bytes = <int>[];
  var value = number;

  while (value != BigInt.zero) {
    bytes.add((value & BigInt.from(0xFF)).toInt());
    value = value >> 8;
  }

  return Uint8List.fromList(bytes.reversed.toList());
}

/// Initialize a SecureRandom instance using FortunaRandom
SecureRandom createSecureRandom() {
  final secureRandom = FortunaRandom();
  final random = Random.secure();

  /// Generate a random seed
  final seed = Uint8List(32); // 32 bytes = 256 bits
  for (int i = 0; i < seed.length; i++) {
    seed[i] = random.nextInt(256);
  }

  secureRandom.seed(KeyParameter(seed));
  return secureRandom;
}

/// Parses a Base64-encoded private key in PKCS#8 or SEC1 format.
ECPrivateKey parsePrivateKey(String base64Key) {
  String cleanedBase64Key = base64Key
      .replaceAll('-----BEGIN EC PRIVATE KEY-----', '')
      .replaceAll('-----END EC PRIVATE KEY-----', '')
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(' ', '');

  /// Decode the Base64 key
  final keyBytes = base64.decode(cleanedBase64Key);

  /// Parse the ASN.1 structure
  final asn1Parser = ASN1Parser(keyBytes);
  final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

  if (topLevelSeq.elements.length == 3) {
    /// PKCS#8 format
    final privateKeyOctets =
        (topLevelSeq.elements[2] as ASN1OctetString).octets;
    final privateKeyParser = ASN1Parser(privateKeyOctets);
    final pkSeq = privateKeyParser.nextObject() as ASN1Sequence;

    final privateKeyInt = (pkSeq.elements[1] as ASN1Integer).valueAsBigInteger;
    final curve = ECCurve_secp256r1();
    return ECPrivateKey(privateKeyInt, curve);
  } else if (topLevelSeq.elements.length == 4) {
    /// SEC1 format
    final privateKeyBytes = (topLevelSeq.elements[1] as ASN1OctetString).octets;
    final privateKeyInt = BigInt.parse(
      privateKeyBytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );
    final curve = ECCurve_secp256r1();
    return ECPrivateKey(privateKeyInt, curve);
  } else {
    throw ArgumentError('Invalid private key format');
  }
}

/// Generate ECDSA Signature
// String generateECDSASignature(String data, ECPrivateKey privateKey) {
//   final signer = Signer('SHA-256/ECDSA');
//   final params = PrivateKeyParameter<ECPrivateKey>(privateKey);
//
//   /// Initialize the signer with SecureRandom
//   signer.init(true, ParametersWithRandom(params, createSecureRandom()));
//
//   /// Hash the data
//   final hash = Uint8List.fromList(utf8.encode(data));
//
//   /// Generate the signature
//   final ECSignature signature = signer.generateSignature(hash) as ECSignature;
//
//   // Encode the signature as a single DER-encoded structure
//   final asn1Sequence = ASN1Sequence();
//   asn1Sequence.add(ASN1Integer(signature.r));
//   asn1Sequence.add(ASN1Integer(signature.s));
//   final derEncodedSignature = asn1Sequence.encodedBytes;
//
//   /// Encode R and S as Base64
//   final r = base64.encode(bigIntToByteArray(signature.r));
//   final s = base64.encode(bigIntToByteArray(signature.s));
//
//   print("xmlHash, $r");
//   print("xmlHash, $s");
//
//   return '$r:$s'; // Combine R and S
// }

String generateECDSASignature1(
  String invoiceHashBase64,
  ECPrivateKey privateKey,
) {
  // Decode the Base64-encoded invoice hash
  final invoiceHashBytes = base64.decode(invoiceHashBase64);

  // Initialize the signer
  final signer = Signer('SHA-256/ECDSA');
  final params = PrivateKeyParameter<ECPrivateKey>(privateKey);
  signer.init(true, ParametersWithRandom(params, createSecureRandom()));

  // Generate the signature
  final ECSignature signature =
      signer.generateSignature(invoiceHashBytes) as ECSignature;

  // Encode the signature as a single DER-encoded structure
  final asn1Sequence = ASN1Sequence();
  asn1Sequence.add(ASN1Integer(signature.r));
  asn1Sequence.add(ASN1Integer(signature.s));
  final derEncodedSignature = asn1Sequence.encodedBytes;

  // Encode the DER-encoded signature as Base64
  final digitalSignature = base64.encode(derEncodedSignature);
  return digitalSignature;
}

String createInvoiceDigitalSignature(
  String invoiceHashBase64,
  String privateKeyPem,
) {
  final invoiceHashBytes = base64.decode(invoiceHashBase64);

  // Parse the EC private key from PEM format
  final privateKey = _parseECPrivateKeyFromPem(privateKeyPem);

  // Sign using SHA-256 with ECDSA
  final signer = Signer('SHA-256/ECDSA');
  signer.init(
    true, // true = signing
    ParametersWithRandom(
      PrivateKeyParameter<ECPrivateKey>(privateKey),
      _getSecureRandom(),
    ),
  );

  ECSignature sig =
      signer.generateSignature(Uint8List.fromList(invoiceHashBytes))
          as ECSignature;

  // ASN.1 encode (DER format)
  final asn1Seq =
      ASN1Sequence()
        ..add(ASN1Integer(sig.r))
        ..add(ASN1Integer(sig.s));
  final derEncoded = asn1Seq.encodedBytes;

  return base64.encode(derEncoded);
}

// Helper to parse EC private key from PEM
ECPrivateKey _parseECPrivateKeyFromPem(String pem) {
  final lines = pem
      .replaceAll('-----BEGIN EC PRIVATE KEY-----', '')
      .replaceAll('-----END EC PRIVATE KEY-----', '')
      .replaceAll('\n', '')
      .replaceAll('\r', '');
  final keyBytes = base64.decode(lines);

  final asn1Parser = ASN1Parser(Uint8List.fromList(keyBytes));
  final sequence = asn1Parser.nextObject() as ASN1Sequence;

  final privateKeyInt = (sequence.elements![1] as ASN1OctetString).valueBytes();
  final privateKeyNum = BigInt.parse(hex.encode(privateKeyInt!), radix: 16);

  final curve =
      ECCurve_secp256r1(); // Matches the curve used in your key (NIST P-256)
  final domainParams = ECDomainParameters('secp256r1');
  final Q = domainParams.G * privateKeyNum;

  return ECPrivateKey(privateKeyNum, domainParams);
}

SecureRandom _getSecureRandom() {
  final secureRandom = FortunaRandom();
  final seedSource = Random.secure();
  final seed = Uint8List(32);
  for (int i = 0; i < seed.length; i++) {
    seed[i] = seedSource.nextInt(256);
  }
  secureRandom.seed(KeyParameter(seed));
  return secureRandom;
}
