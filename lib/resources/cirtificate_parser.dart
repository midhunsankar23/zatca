import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/ecc/api.dart';

import 'package:basic_utils/basic_utils.dart' as bUtil;

import '../models/cirtificate_info.dart';
import '../models/csr_info.dart';

/// Helper: Convert HEX string to bytes
Uint8List hexToBytes(String hex) {
  hex = hex.replaceAll(RegExp(r'\s+'), ''); // remove spaces/newlines
  Uint8List bytes = Uint8List(hex.length ~/ 2);
  for (int i = 0; i < hex.length; i += 2) {
    bytes[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
  }
  return bytes;
}

/// Optional helper: Wrap base64 string into 64-character lines (PEM standard)
String wrapBase64(String input, {int chunkSize = 64}) {
  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i += chunkSize) {
    buffer.writeln(
      input.substring(
        i,
        i + chunkSize > input.length ? input.length : i + chunkSize,
      ),
    );
  }
  return buffer.toString().trim();
}

/// Parse the csr .
CsrInfo parseCsr(String csrPem) {
  bUtil.CertificateSigningRequestData a = bUtil.X509Utils.csrFromPem(csrPem);

  print(a.certificationRequestInfo!.publicKeyInfo!.bytes);
  // Convert HEX string to bytes
  Uint8List publicKeyBytes = hexToBytes(
    a.certificationRequestInfo!.publicKeyInfo!.bytes!,
  );
  Uint8List signatureBytes = hexToBytes(a.signature!);

  // Encode bytes to base64
  String publicKey = base64Encode(publicKeyBytes);
  String signature = base64Encode(signatureBytes);

  return CsrInfo(
    publicKey: publicKey,
    publicKeyRaw: publicKeyBytes,
    signature: signatureBytes,
  );
}

CsrInfo parseCSR1(String csrPem) {
  /// Remove the PEM headers and footers
  final pemContent = csrPem
      .replaceAll("-----BEGIN CERTIFICATE REQUEST-----", "")
      .replaceAll("-----END CERTIFICATE REQUEST-----", "")
      .replaceAll("\n", "")
      .replaceAll("\r", "") // Handle potential carriage returns
      .replaceAll(" ", ""); // Handle spaces
  /// Decode the Base64 PEM content
  final bytes = base64.decode(pemContent);

  /// Parse ASN.1 structure
  final asn1Parser = ASN1Parser(bytes);
  final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

  /// Extract the certification request information
  final certificationRequestInfo = topLevelSeq.elements[0] as ASN1Sequence;
  final certificationRequestInfoBytes = certificationRequestInfo.encodedBytes;

  /// Extract the public key
  final publicKeyInfo = certificationRequestInfo.elements[2] as ASN1Sequence;
  final publicKeyBitString = publicKeyInfo.elements[1] as ASN1BitString;

  /// Extract raw public key bytes
  final rawPublicKeyBytes = publicKeyBitString.contentBytes();
  final domainParams = ECDomainParameters('prime256v1');

  /// Handle compressed/uncompressed keys
  if (rawPublicKeyBytes.length == 33) {
    final prefix = rawPublicKeyBytes[0];
    final x = BigInt.parse(
      rawPublicKeyBytes
          .sublist(1)
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join(),
      radix: 16,
    );
    domainParams.curve.decompressPoint(prefix, x);
  } else if (rawPublicKeyBytes.length == 65) {
    final x = BigInt.parse(
      rawPublicKeyBytes
          .sublist(1, 33)
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join(),
      radix: 16,
    );
    final y = BigInt.parse(
      rawPublicKeyBytes
          .sublist(33)
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join(),
      radix: 16,
    );
    domainParams.curve.createPoint(x, y);
  } else {
    throw ArgumentError('Unexpected length for raw public key bytes');
  }

  /// Convert public key to DER format
  final publicKeyDER = [
    ...[0x30, 0x56], // SEQUENCE header
    ...[0x30, 0x10], // OID for EC public key
    ...[0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01],
    ...[0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x0A],
    ...[0x03, 0x42, 0x00],
    ...rawPublicKeyBytes,
  ];

  /// Extract the signature
  final signature = topLevelSeq.elements[2] as ASN1BitString;
  // final signatureBytes = signature.contentBytes();
  final signatureBytes = signature.valueBytes().sublist(1);

  return CsrInfo(
    publicKey: base64.encode(publicKeyDER),
    publicKeyRaw: publicKeyDER,
    signature: signatureBytes,
  );
}

String cleanCertificatePem(String pem) {
  return pem
      .replaceAll("-----BEGIN CERTIFICATE-----", "")
      .replaceAll("-----END CERTIFICATE-----", "")
      .replaceAll("\n", "")
      .replaceAll("\r", ""); // Handle potential carriage returns
}

/// Parses the certificate and extracts information such as hash, issuer, serial number, public key, and signature.
CertificateInfo getCertificateInfo(String pem) {
  // Generate hash
  final pemContent = cleanCertificatePem(pem);
  final hash = sha256.convert(utf8.encode(pemContent)).toString();
  final hashBase64Encoded = base64.encode(utf8.encode(hash));

  final bytes = _decodePem(pem);
  final asn1Parser = ASN1Parser(bytes);
  final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

  // tbsCertificate is the first element in the certificate sequence
  final tbsCertificate = topLevelSeq.elements[0] as ASN1Sequence;

  // Serial number is usually the second element in tbsCertificate
  final serialNumberASN1 = tbsCertificate.elements[1] as ASN1Integer;
  final serialNumber = serialNumberASN1.valueAsBigInteger;

  // Issuer is usually the fourth element in tbsCertificate
  final issuerSeq = tbsCertificate.elements[3] as ASN1Sequence;
  final issuer = _parseName(issuerSeq);
  final signature = topLevelSeq.elements[2] as ASN1BitString;
  final signatureBytes = signature.valueBytes().sublist(1);

  final publicKeyDER = [
    ...[0x30, 0x56], // SEQUENCE header
    ...[0x30, 0x10], // OID for EC public key
    ...[0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01],
    ...[0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x0A],
    ...[0x03, 0x42, 0x00],
    ..._extractPublicKey(tbsCertificate),
  ];
  print("_extractPublicKey:${publicKeyDER}");

  return CertificateInfo(
    hash: hashBase64Encoded,
    issuer: issuer,
    serialNumber: serialNumber.toString(),
    publicKey: base64.encode(publicKeyDER),
    signature: base64.encode(signatureBytes),
  );
}

Uint8List _extractPublicKey(ASN1Sequence tbsCertificate) {
  final subjectPublicKeyInfo = tbsCertificate.elements[6] as ASN1Sequence;
  final publicKeyBitString = subjectPublicKeyInfo.elements[1] as ASN1BitString;
  return publicKeyBitString.contentBytes();
}

// CertificateInfo getCertificateInfo1(String pemContent) {
//   // Generate hash
//   final hash = sha256.convert(utf8.encode(pemContent)).toString();
//   final hashBase64Encoded = base64.encode(utf8.encode(hash));
//
//
//
//   final bytes = _decodePem(pemContent);
//   final asn1Parser = ASN1Parser(bytes);
//   final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
//
//   // tbsCertificate is the first element in the certificate sequence
//   final tbsCertificate = topLevelSeq.elements[0] as ASN1Sequence;
//
//   // Serial number is usually the second element in tbsCertificate
//   final serialNumberASN1 = tbsCertificate.elements[1] as ASN1Integer;
//   final serialNumber=serialNumberASN1.valueAsBigInteger;
//
//   // Issuer is usually the fourth element in tbsCertificate
//   final issuerSeq = tbsCertificate.elements[3] as ASN1Sequence;
//   final issuer = _parseName(issuerSeq);
//
//   return CertificateInfo(
//     hash: hashBase64Encoded,
//     issuer: issuer,
//     serialNumber: serialNumber.toString(),
//   );
// }

Uint8List _decodePem(String pem) {
  final lines =
      pem.split('\n').where((line) => !line.startsWith('-----')).toList();
  final base64Str = lines.join('');
  return base64Decode(base64Str);
}

String _parseName(ASN1Sequence seq) {
  final parts = <String>[];
  for (final rdnSet in seq.elements) {
    final rdnSeq = (rdnSet as ASN1Set).elements.first as ASN1Sequence;
    final oid = rdnSeq.elements[0] as ASN1ObjectIdentifier;
    final value = rdnSeq.elements[1];
    final decodedValue = _decodeASN1String(value);
    parts.add('${_oidToName(oid.identifier!)}=$decodedValue');
  }
  return parts.reversed.join(', ');
}

String _oidToName(String oid) {
  switch (oid) {
    case '2.5.4.6':
      return 'C'; // Country
    case '2.5.4.10':
      return 'O'; // Organization
    case '2.5.4.11':
      return 'OU'; // Organizational Unit
    case '2.5.4.3':
      return 'CN'; // Common Name
    case '0.9.2342.19200300.100.1.25':
      return 'DC'; // Domain Component
    default:
      return oid;
  }
}

String _decodeASN1String(ASN1Object obj) {
  return utf8.decode(obj.valueBytes());
}
