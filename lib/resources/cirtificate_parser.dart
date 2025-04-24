import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';
import '../models/cirtificate_info.dart';

String cleanCertificatePem(String pem) {
  return pem
      .replaceAll("-----BEGIN CERTIFICATE-----", "")
      .replaceAll("-----END CERTIFICATE-----", "")
      .replaceAll("\n", "")
      .replaceAll("\r", ""); // Handle potential carriage returns
}

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
