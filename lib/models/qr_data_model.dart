import 'invoice_data_model.dart';

class ZatcaQr {
  final String sellerName; // Seller's name
  final String sellerTRN; // Seller's VAT registration number
  final String issueDate; // ISO 8601 format date and time
  final String invoiceHash; // SHA-256 hash of the invoice
  final String digitalSignature; // ECDSA digital signature
  final String publicKey; // Base64-encoded public key
  final String certificateSignature;
  final ZatcaInvoice invoiceData;
  final String xmlString;

  ZatcaQr({
    required this.sellerName,
    required this.sellerTRN,
    required this.issueDate,
    required this.invoiceHash,
    required this.digitalSignature,
    required this.publicKey,
    required this.certificateSignature,
    required this.invoiceData,
    required this.xmlString,
  });

  factory ZatcaQr.fromMap(Map<String, dynamic> json) {
    return ZatcaQr(
      sellerName: json['sellerName'] ?? '',
      sellerTRN: json['sellerTRN'] ?? '',
      issueDate: json['issueDate'] ?? '',
      invoiceHash: json['invoiceHash'] ?? '',
      digitalSignature: json['digitalSignature'] ?? '',
      publicKey: json['publicKey'] ?? '',
      certificateSignature: json['certificateSignature'] ?? '',
      invoiceData: ZatcaInvoice.fromMap(json['invoiceData']),
      xmlString: json['xmlString'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'sellerName': sellerName,
      'sellerTRN': sellerTRN,
      'issueDate': issueDate,
      'invoiceHash': invoiceHash,
      'digitalSignature': digitalSignature,
      'publicKey': publicKey,
      'certificateSignature': certificateSignature,
      'invoiceData': invoiceData.toMap(),
      'xmlString': xmlString,
    };
  }
}
