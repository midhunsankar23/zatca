import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:zatca/models/qr_data_model.dart';
import 'package:zatca/resources/enums.dart';
import 'package:zatca/resources/public_key_signature_generator.dart';
import 'package:zatca/resources/signature_generator.dart';
import 'package:zatca/resources/xml_generator.dart';
import 'package:zatca/resources/xml_hashing.dart';
import '../models/invoice_data_model.dart';

class ZatcaManager {
  ZatcaManager._();

  static ZatcaManager instance = ZatcaManager._();
  Supplier? _supplier;
  String? _privateKeyBase64;
  String? _certificateBase64;
  String? _sellerName;
  String? _sellerTRN;

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
    log('xmlHash: $xmlHash');
    log('signature: $signature');
    log('Public Key (Base64): ${result['publicKey']}');
    log('Signature (Base64): ${base64.encode(result['signature'])}');

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

  String stringToHex(String input) {
    return input.codeUnits
        .map((unit) => unit.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  String _generateTlv(Map<int, String> data) {
    StringBuffer tlv = StringBuffer();

    data.forEach((tag, value) {
      String tagHex = tag
          .toRadixString(16)
          .padLeft(2, '0'); // Convert tag to hex
      String valueHex = stringToHex(value); // Convert value to hex
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
