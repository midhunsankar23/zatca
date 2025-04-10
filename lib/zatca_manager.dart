import 'dart:convert';
import 'dart:typed_data';

import 'package:zatca/models/qr_data_model.dart';
import 'package:zatca/resources/enums.dart';
import 'package:zatca/resources/public_key_signature_generator.dart';
import 'package:zatca/resources/signature_generator.dart';
import 'package:zatca/resources/xml_generator.dart';
import 'package:zatca/resources/xml_hashing.dart';
import '../models/invoice_data_model.dart';

/// A singleton class that manages the generation of ZATCA-compliant invoices and QR codes.
class ZatcaManager {
  ZatcaManager._();

  /// The single instance of the `ZatcaManager` class.
  static ZatcaManager instance = ZatcaManager._();
  Supplier? _supplier;
  String? _privateKeyBase64;
  String? _certificateBase64;
  String? _sellerName;
  String? _sellerTRN;

  /// Initializes the ZATCA manager with the required supplier and cryptographic details.
  ///
  /// [supplier] - The supplier information.
  /// [privateKeyBase64] - The private key in Base64 format.
  /// [certificateBase64] - The certificate in Base64 format.
  /// [sellerName] - The name of the seller.
  /// [sellerTRN] - The Tax Registration Number (TRN) of the seller.

  initializeZacta({
    required Supplier supplier,
    required String privateKeyBase64,
    required String certificateBase64,
    required String sellerName,
    required String sellerTRN,
  }) {
    _supplier = supplier;
    _privateKeyBase64 = privateKeyBase64;
    _certificateBase64 = certificateBase64;
    _sellerName = sellerName;
    _sellerTRN = sellerTRN;
  }

  /// /// Generates a ZATCA-compliant QR code and invoice data.
  ///   ///
  ///   /// [invoiceLines] - The list of invoice lines.
  ///   /// [invoiceType] - The type of the invoice.
  ///   /// [invoiceRelationType] - The relation type of the invoice (default is `b2c`).
  ///   /// [customer] - The customer information (required for `b2b` invoices).
  ///   /// [issueDate] - The issue date of the invoice.
  ///   /// [invoiceUUid] - The unique identifier for the invoice.
  ///   /// [invoiceNumber] - The invoice number.
  ///   /// [issueTime] - The issue time of the invoice.
  ///   /// [totalWithVat] - The total amount including VAT.
  ///   /// [totalVat] - The total VAT amount.
  ///   /// [previousInvoiceHash] - The hash of the previous invoice.
  ///   ///
  ///   /// Returns a `ZatcaQr` object containing the QR code and invoice data.
  ZatcaQr generateZatcaQrInit({
    required List<InvoiceLine> invoiceLines,
    required InvoiceType invoiceType,
    InvoiceRelationType invoiceRelationType = InvoiceRelationType.b2c,
    Customer? customer,
    required String issueDate,
    required String invoiceUUid,
    required String invoiceNumber,
    required String issueTime,
    required String totalWithVat,
    required String totalVat,
    required String previousInvoiceHash,
  }) {
    if (_supplier == null ||
        _privateKeyBase64 == null ||
        _certificateBase64 == null ||
        _sellerName == null ||
        _sellerTRN == null) {
      throw Exception(
        'Supplier, private key, certificate, seller name, and seller TRN must be initialized before generating the QR code.',
      );
    }
    if (invoiceRelationType == InvoiceRelationType.b2b && customer == null) {
      throw Exception(
        'customer must be initialized before generating the QR code.',
      );
    }
    final invoice = ZatcaInvoice(
      profileID: 'reporting:1.0',
      id: invoiceNumber,
      uuid: invoiceUUid,
      issueDate: issueDate,
      issueTime: issueTime,
      invoiceTypeCode: '388',
      invoiceTypeName: invoiceType.value,
      note: invoiceType.value,
      currencyCode: 'SAR',
      taxCurrencyCode: 'SAR',
      supplier: _supplier!,
      customer:
          customer ??
          Customer(
            companyID: ' ',
            registrationName: ' ',
            address: Address(
              streetName: ' ',
              buildingNumber: ' ',
              citySubdivisionName: ' ',
              cityName: ' ',
              postalZone: ' ',
              countryCode: ' ',
            ),
          ),
      invoiceLines: invoiceLines,
      taxAmount: totalVat,
      totalAmount: totalWithVat,
      previousInvoiceHash: previousInvoiceHash,
    );

    final xmlString = generateZATCAXml(invoice);

    final xmlHash = generateHash(xmlString);
    final privateKey = parsePrivateKey(_privateKeyBase64!);

    // Example XML hash

    // Generate the ECDSA signature
    final signature = generateECDSASignature(xmlHash, privateKey);
    final result = parseCSR(_certificateBase64!);
    final publicKey = result['publicKey'];
    final certificateSignature = base64.encode(result['signature']);

    return ZatcaQr(
      sellerName: _sellerName!,
      sellerTRN: _sellerTRN!,
      issueDate: issueDate,
      invoiceHash: xmlHash,
      digitalSignature: signature,
      publicKey: publicKey,
      certificateSignature: certificateSignature,
      invoiceData: invoice,
      xmlString: xmlString,
    );
  }

  /// Generates a QR code string from the given `ZatcaQr` data model.
  ///
  /// [qrDataModel] - The data model containing the QR code information.
  ///
  /// Returns the QR code string.
  String getQrString(ZatcaQr qrDataModel) {
    Map<int, String> invoiceData = {
      1: qrDataModel.sellerName,
      2: qrDataModel.sellerTRN,
      3: qrDataModel.issueDate,
      4: qrDataModel.invoiceData.totalAmount,
      5: qrDataModel.invoiceData.taxAmount,
      6: qrDataModel.invoiceHash,
      7: qrDataModel.digitalSignature,
      8: qrDataModel.publicKey,
    };

    String tlvString = _generateTlv(invoiceData);
    final qrContent = utf8.encode(_tlvToBase64(tlvString));
    return String.fromCharCodes(qrContent);
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

  /// Generates a TLV (Tag-Length-Value) string from the given data.
  ///
  /// [data] - A map where the key is the tag and the value is the associated data.
  ///
  /// Returns the TLV string.
  String _generateTlv(Map<int, String> data) {
    StringBuffer tlv = StringBuffer();

    data.forEach((tag, value) {
      String tagHex = tag
          .toRadixString(16)
          .padLeft(2, '0'); // Convert tag to hex
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
  String _tlvToBase64(String tlv) {
    List<int> bytes = [];

    for (int i = 0; i < tlv.length; i += 2) {
      String hexStr = tlv.substring(i, i + 2); // Two hex characters at a time
      int byte = int.parse(hexStr, radix: 16); // Parse as a byte
      bytes.add(byte);
    }

    Uint8List byteArray = Uint8List.fromList(bytes);
    return base64Encode(byteArray); // Convert to Base64
  }
}
