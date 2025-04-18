import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';
import 'package:zatca/models/qr_data_model.dart';
import 'package:zatca/resources/cirtificate_parser.dart';
import 'package:zatca/resources/enums.dart';
import 'package:zatca/resources/qr_generator.dart';
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
  String? _certificateRequestBase64;
  String? _sellerName;
  String? _sellerTRN;
  String _issuedCertificateBase64 = '';

  /// Initializes the ZATCA manager with the required supplier and cryptographic details.

  /// [supplier] - The supplier information.
  /// [privateKeyBase64] - The private key in Base64 format.
  /// [certificateRequestBase64] - (CSR) The certificate request in Base64 format.
  /// [sellerName] - The name of the seller.
  /// [sellerTRN] - The Tax Registration Number (TRN) of the seller.
  /// [issuedCertificateBase64] - The issued certificate from zatca compliance.  only required for generating UBL standard XML

  initializeZacta({
    required Supplier supplier,
    required String privateKeyBase64,
    required String certificateRequestBase64,
    required String sellerName,
    required String sellerTRN,
    String issuedCertificateBase64 = "",
  }) {
    _supplier = supplier;
    _privateKeyBase64 = privateKeyBase64;
    _certificateRequestBase64 = certificateRequestBase64;
    _sellerName = sellerName;
    _sellerTRN = sellerTRN;
    _sellerTRN = sellerTRN;
    _issuedCertificateBase64 = issuedCertificateBase64;
  }

  /// /// Generates a ZATCA-compliant QR code and invoice data.
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
        _certificateRequestBase64 == null ||
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
      note: invoiceType.name,
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

    // final canonicalizeXmlString=canonicalizeXml(xmlString);

    final xmlHash = generateHash(xmlString);

    final privateKey = parsePrivateKey(_privateKeyBase64!);

    // Example XML hash

    // Generate the ECDSA signature
    final signature = generateECDSASignature(xmlHash, privateKey);
    final csrInfo = parseCSR(_certificateRequestBase64!);
    final publicKey = csrInfo.publicKey;
    final certificateSignature = base64.encode(csrInfo.signature);

    final issueDateTime=DateTime.parse('$issueDate $issueTime');

    return ZatcaQr(
      sellerName: _sellerName!,
      sellerTRN: _sellerTRN!,
      issueDateTime: issueDateTime.toIso8601String(),
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
      3: qrDataModel.issueDateTime,
      4: qrDataModel.invoiceData.totalAmount,
      5: qrDataModel.invoiceData.taxAmount,
      6: qrDataModel.invoiceHash,
      7: qrDataModel.digitalSignature,
      8: qrDataModel.publicKey,
    };

    String tlvString = generateTlv(invoiceData);
    final qrContent = utf8.encode(tlvToBase64(tlvString));
    return String.fromCharCodes(qrContent);
  }

  String generateUBLXml({
    required String invoiceHash,
    required String signingTime,
    required String digitalSignature,
    required String certificateString,
    required String invoiceXmlString,
    required String qrString,
  }) {
    final cleanedCertificate=cleanCertificatePem(certificateString);
    final certificateInfo = getCertificateInfo(cleanedCertificate);

    final defaultUBLExtensionsSignedPropertiesForSigningXML =
        defaultUBLExtensionsSignedPropertiesForSigning(
          signingTime: signingTime,
          certificateHash: certificateInfo.hash,
          certificateIssuer: certificateInfo.issuer,
          certificateSerialNumber: certificateInfo.serialNumber,
        );

    // 5: Get SignedProperties hash
    final signedPropertiesBytes = utf8.encode(
      defaultUBLExtensionsSignedPropertiesForSigningXML.toXmlString(pretty: true),
    );
    final signedPropertiesHash = sha256.convert(signedPropertiesBytes).bytes;
    final signedPropertiesHashBase64 = base64.encode(signedPropertiesHash);

    final defaultUBLExtensionsSignedPropertiesXML =
        defaultUBLExtensionsSignedProperties(
          signingTime: signingTime,
          certificateHash: certificateInfo.hash,
          certificateIssuer: certificateInfo.issuer,
          certificateSerialNumber: certificateInfo.serialNumber,
        );
    print("invoiceHash $invoiceHash");
    print("signedPropertiesHashBase64 $signedPropertiesHashBase64");
    final ublStandardXML= generateUBLSignExtensionsXml(
      invoiceHash: invoiceHash,
      signedPropertiesHash: signedPropertiesHashBase64,
      digitalSignature: digitalSignature,
      certificateString: cleanedCertificate,
      ublSignatureSignedPropertiesXML:
          defaultUBLExtensionsSignedPropertiesXML,
    );

    final xmlDocument = XmlDocument.parse(invoiceXmlString);
    xmlDocument.rootElement.children.insert(0, ublStandardXML.rootElement.copy());

    final qrXml=generateQrAndSignatureXMl(qrString: qrString);
    xmlDocument.rootElement.children.insertAll(21, qrXml.children.map((node) => node.copy()).toList());




    return xmlDocument.toXmlString(pretty: true, indent: '    ');
  }
}
