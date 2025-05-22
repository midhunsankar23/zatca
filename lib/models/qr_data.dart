import 'invoice.dart';

/// A class representing a ZATCA-compliant QR code and invoice data.
class ZatcaQr {
  /// Seller's name
  final String sellerName;

  /// Seller's VAT registration number
  final String sellerTRN;

  /// ISO 8601 format date and time
  final String issueDateTime;

  /// SHA-256 hash of the invoice
  final String invoiceHash;

  /// ECDSA digital signature
  final String digitalSignature;

  /// Base64-encoded public key
  final String publicKey;

  /// Base64-encoded certificate signature
  final String certificateSignature;

  /// The invoice data
  final ZatcaInvoice invoiceData;

  /// The XML string representation of the invoice
  final String xmlString;

  ZatcaQr({
    required this.sellerName,
    required this.sellerTRN,
    required this.issueDateTime,
    required this.invoiceHash,
    required this.digitalSignature,
    required this.publicKey,
    required this.certificateSignature,
    required this.invoiceData,
    required this.xmlString,
  });

  /// Creates a new [ZatcaQr] instance from a map.
  factory ZatcaQr.fromMap(Map<String, dynamic> json) {
    return ZatcaQr(
      sellerName: json['sellerName'] ?? '',
      sellerTRN: json['sellerTRN'] ?? '',
      issueDateTime: json['issueDateTime'] ?? '',
      invoiceHash: json['invoiceHash'] ?? '',
      digitalSignature: json['digitalSignature'] ?? '',
      publicKey: json['publicKey'] ?? '',
      certificateSignature: json['certificateSignature'] ?? '',
      invoiceData: ZatcaInvoice.fromMap(json['invoiceData']),
      xmlString: json['xmlString'] ?? '',
    );
  }

  /// Converts the [ZatcaQr] instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'sellerName': sellerName,
      'sellerTRN': sellerTRN,
      'issueDate': issueDateTime,
      'invoiceHash': invoiceHash,
      'digitalSignature': digitalSignature,
      'publicKey': publicKey,
      'certificateSignature': certificateSignature,
      'invoiceData': invoiceData.toMap(),
      'xmlString': xmlString,
    };
  }
}
