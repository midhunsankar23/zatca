import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
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
  String? _privateKeyPem;
  String? _certificatePem;
  String? _sellerName;
  String? _sellerTRN;

  /// Initializes the ZATCA manager with the required supplier and cryptographic details.

  /// [supplier] - The supplier information.
  /// [privateKeyPem] - The private key in Base64 format.
  /// [certificatePem] - (CSR) The certificate request in Base64 format.
  /// [sellerName] - The name of the seller.
  /// [sellerTRN] - The Tax Registration Number (TRN) of the seller.
  /// [issuedCertificateBase64] - The issued certificate from zatca compliance.  only required for generating UBL standard XML

  initializeZacta({
    required Supplier supplier,
    required String privateKeyPem,
    required String certificatePem,
    required String sellerName,
    required String sellerTRN,
  }) {
    _supplier = supplier;
    _privateKeyPem = privateKeyPem;
    _certificatePem = certificatePem;
    _sellerName = sellerName;
    _sellerTRN = sellerTRN;
    _sellerTRN = sellerTRN;
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
    required double totalWithVat,
    required double totalVat,
    required String previousInvoiceHash,
  }) {
    if (_supplier == null ||
        _privateKeyPem == null ||
        _certificatePem == null ||
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

    final invoiceXml = generateZATCAXml(invoice);
    final xmlString = invoiceXml.toXmlString(pretty: true, indent: '    ');
    String hashableXml = invoiceXml.rootElement.toXmlString(
      pretty: true,
      indent: '    ',
    );

    hashableXml = normalizeXml(hashableXml);
    hashableXml = hashableXml.replaceFirst(
      '<cbc:ProfileID>reporting:1.0</cbc:ProfileID>',
      '\n    <cbc:ProfileID>reporting:1.0</cbc:ProfileID>',
    );
    hashableXml = hashableXml.replaceFirst(
      '<cac:AccountingSupplierParty>',
      '\n    \n    <cac:AccountingSupplierParty>',
    );

    final xmlHash = generateHash(hashableXml);
    final privateKey = parsePrivateKey(_privateKeyPem!);

    // Generate the ECDSA signature
    final signature = createInvoiceDigitalSignature(xmlHash, _privateKeyPem!);
    final certificateInfo = getCertificateInfo(_certificatePem!);
    final issueDateTime = DateTime.parse('$issueDate $issueTime');

    return ZatcaQr(
      sellerName: _sellerName!,
      sellerTRN: _sellerTRN!,
      issueDateTime: DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(issueDateTime),
      invoiceHash: xmlHash,
      digitalSignature: signature,
      publicKey: certificateInfo.publicKey,
      certificateSignature: certificateInfo.signature,
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
    Map<int, dynamic> invoiceData = {
      1: qrDataModel.sellerName,
      2: qrDataModel.sellerTRN,
      3: qrDataModel.issueDateTime,
      4: qrDataModel.invoiceData.totalAmount.toStringAsFixed(2),
      5: qrDataModel.invoiceData.taxAmount.toStringAsFixed(2),
      6: qrDataModel.invoiceHash,
      7: utf8.encode(qrDataModel.digitalSignature),
      8: base64.decode(qrDataModel.publicKey),
      9: base64.decode(qrDataModel.certificateSignature),
    };
    String tlvString = generateTlv(invoiceData);
    final qrContent = utf8.encode(tlvToBase64(tlvString));
    return String.fromCharCodes(qrContent);
  }

  String toHex(Uint8List data) =>
      data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

  String generateUBLXml({
    required String invoiceHash,
    required String signingTime,
    required String digitalSignature,
    required String invoiceXmlString,
    required String qrString,
  }) {
    final cleanedCertificate = cleanCertificatePem(_certificatePem!);
    final certificateInfo = getCertificateInfo(_certificatePem!);
    final defaultUBLExtensionsSignedPropertiesForSigningXML =
        defaultUBLExtensionsSignedPropertiesForSigning(
          signingTime: signingTime,
          certificateHash: certificateInfo.hash,
          certificateIssuer: certificateInfo.issuer,
          certificateSerialNumber: certificateInfo.serialNumber,
        );

    // 5: Get SignedProperties hash
    String defaultUBLExtensionsSignedPropertiesForSigningXMLString =
        defaultUBLExtensionsSignedPropertiesForSigningXML.toXmlString(
          pretty: true,
          indent: '    ',
        );
    defaultUBLExtensionsSignedPropertiesForSigningXMLString =
        defaultUBLExtensionsSignedPropertiesForSigningXMLString
            .split('\n')
            .map((e) {
              return e.padLeft(e.length + 32);
            })
            .join('\n');
    defaultUBLExtensionsSignedPropertiesForSigningXMLString =
        defaultUBLExtensionsSignedPropertiesForSigningXMLString.replaceFirst(
          '                                <xades:SignedProperties xmlns:xades="http://uri.etsi.org/01903/v1.3.2#" Id="xadesSignedProperties">',
          '<xades:SignedProperties xmlns:xades="http://uri.etsi.org/01903/v1.3.2#" Id="xadesSignedProperties">',
        );

    final signedPropertiesBytes = utf8.encode(
      defaultUBLExtensionsSignedPropertiesForSigningXMLString,
    );
    final signedPropertiesHash =
        sha256.convert(signedPropertiesBytes).toString();
    final signedPropertiesHashBase64 = base64.encode(
      utf8.encode(signedPropertiesHash),
    );

    final defaultUBLExtensionsSignedPropertiesXML =
        defaultUBLExtensionsSignedProperties(
          signingTime: signingTime,
          certificateHash: certificateInfo.hash,
          certificateIssuer: certificateInfo.issuer,
          certificateSerialNumber: certificateInfo.serialNumber,
        );
    final ublStandardXML = generateUBLSignExtensionsXml(
      invoiceHash: invoiceHash,
      signedPropertiesHash: signedPropertiesHashBase64,
      digitalSignature: digitalSignature,
      certificateString: cleanedCertificate,
      ublSignatureSignedPropertiesXML: defaultUBLExtensionsSignedPropertiesXML,
    );

    final xmlDocument = XmlDocument.parse(invoiceXmlString);
    xmlDocument.rootElement.children.insert(
      0,
      ublStandardXML.rootElement.copy(),
    );

    final qrXml = generateQrAndSignatureXMl(qrString: qrString);
    xmlDocument.rootElement.children.insertAll(
      21,
      qrXml.children.map((node) => node.copy()).toList(),
    );

    String xml= xmlDocument.toXmlString(pretty: true, indent: '    ');
    String defaultUBLExtensionsSignedPropertiesXMLString=defaultUBLExtensionsSignedPropertiesXML.rootElement.toXmlString(pretty: true, indent: '    ');
    defaultUBLExtensionsSignedPropertiesXMLString=defaultUBLExtensionsSignedPropertiesXMLString
        .split('\n')
        .map((e) {
      return e.padLeft(e.length + 28);
    }).join('\n');
    defaultUBLExtensionsSignedPropertiesXMLString =
        defaultUBLExtensionsSignedPropertiesXMLString.replaceFirst(
          '                            <xades:QualifyingProperties Target="signature" xmlns:xades="http://uri.etsi.org/01903/v1.3.2#">',
          '<xades:QualifyingProperties Target="signature" xmlns:xades="http://uri.etsi.org/01903/v1.3.2#">',
        );
     String replacable="""<ds:Object>
                            ${defaultUBLExtensionsSignedPropertiesXMLString}
                            </ds:Object>""";
    xml=xml.replaceFirst('<ds:Object-1/>',replacable);

    return xml;

  }
}

String normalizeXml(String hashableXml) {
  return hashableXml
      .replaceAll('\r\n', '\n') // Normalize all line endings to \n
      .replaceAll(
        RegExp(r'\s+$', multiLine: true),
        '',
      ) // Remove trailing spaces per line
      .trim(); // Trim leading/trailing whitespace
}
