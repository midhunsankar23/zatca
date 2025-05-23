import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:zatca/models/address.dart';
import 'package:zatca/models/customer.dart';
import 'package:zatca/models/egs_unit.dart';
import 'package:zatca/models/invoice.dart';
import 'package:zatca/models/supplier.dart';
import 'package:zatca/certificate_manager.dart';
import 'package:zatca/resources/enums.dart';
import 'package:zatca/zatca_manager.dart';

void main() async {
  /// Initialize the EGSUnitInfo object with the required details.
  /// This object contains information about the EGS unit, such as its UUID, model, CRN number, taxpayer name, VAT number, branch name, industry, and location.
  final egsUnitInfo = EGSUnitInfo(
    uuid: "6f4d20e0-6bfe-4a80-9389-7dabe6620f14",
    taxpayerProvidedId: 'EGS2',
    model: 'IOS',
    crnNumber: '454634645645654',
    taxpayerName: "My Branch",
    vatNumber: '310175397400003',
    branchName: 'My Branch',
    branchIndustry: 'Food',
    location: Location(
      city: "Khobar",
      citySubdivision: "West",
      street: "King Fahahd st",
      plotIdentification: "0000",
      building: "0000",
      postalZone: "31952",
    ),
  );

  /// Declare variables for private key and compliance certificate PEM strings.
  /// These will be used to store the generated private key and compliance certificate in PEM format.
  /// In a real-world scenario, these should be securely stored and managed.
  /// The private key is used for signing the compliance certificate, and the compliance certificate is used for generating the production certificate.
  late String privateKeyPem;
  late String complianceCertificatePem;
  // late String productionCertificate;

  bool isDeskTop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  if (isDeskTop) {
    /// Initialize the CertificateManager singleton instance.
    final certificateManager = CertificateManager.instance;
    certificateManager.env = ZatcaEnvironment.development;

    /// Generate a key pair for the EGS unit.
    final keyPair = certificateManager.generateKeyPair();
    privateKeyPem = keyPair['privateKeyPem'];

    /// Generate a CSR (Certificate Signing Request) using the EGS unit info and private key.
    final csrPop = egsUnitInfo.toCsrProps("solution_name");
    final csr = await certificateManager.generateCSR(privateKeyPem, csrPop);

    /// Issue a compliance certificate using the CSR.
    final complianceCertificate = await certificateManager
        .issueComplianceCertificate(csr, '123345');
    complianceCertificatePem = complianceCertificate.complianceCertificatePem;

    /// Issue a production certificate using the compliance certificate.
    // final productionCertificate = await certificateManager
    //     .issueProductionCertificate(complianceCertificate);
  } else {
    /// For non-desktop platforms, use hardcoded PEM strings for private key and compliance certificate.
    /// These should be replaced with actual PEM content.
    /// In a real-world scenario, you would fetch these securely from a server or a key management system.
    privateKeyPem =
        """-----BEGIN EC PRIVATE KEY-----\nprivate_key_pem_content\n-----END EC PRIVATE KEY-----""";
    complianceCertificatePem =
        """-----BEGIN CERTIFICATE-----\ncertificate_pem_content\n-----END CERTIFICATE-----""";
  }

  /// Initialize the ZATCA manager and generate the QR code using the EGS unit info, private key, and compliance certificate.
  initZATCAAndGenerateQr(
    egsUnitInfo: egsUnitInfo,
    privateKeyPem: privateKeyPem,
    certificatePem: complianceCertificatePem,
  );
}

initZATCAAndGenerateQr({
  required EGSUnitInfo egsUnitInfo,
  required String privateKeyPem,
  required String certificatePem,
}) {
  /// Initialize the ZatcaManager singleton instance with seller and supplier details.
  final zatcaManager = ZatcaManager.instance;
  zatcaManager.initializeZacta(
    sellerName: egsUnitInfo.taxpayerName,
    sellerTRN: egsUnitInfo.vatNumber,
    supplier: Supplier(
      companyID: egsUnitInfo.vatNumber,
      companyCRN: egsUnitInfo.crnNumber,
      registrationName: egsUnitInfo.taxpayerName,
      location: egsUnitInfo.location,
    ),
    privateKeyPem: privateKeyPem,
    certificatePem: certificatePem,
  );

  /// Generate QR data for the invoice using the ZatcaManager.
  final qrData = zatcaManager.generateZatcaQrInit(
    invoiceLines: [
      InvoiceLine(
        id: '1',
        quantity: '1',
        unitCode: 'PCE',
        lineExtensionAmount: 10.00,
        itemName: 'Item 1',
        taxPercent: 15,
      ),
    ],
    invoiceType: InvoiceType.standardInvoicesAndSimplifiedInvoices,
    issueDate: "2025-04-08",
    issueTime: "03:41:08",
    invoiceUUid: "8e6000cf-1a98-4174-b3e7-b5d5954bc10d",
    invoiceNumber: "INV0001",
    totalVat: 1.50,
    totalWithVat: 11.50,
    customer: Customer(
      companyID: '300000000000003',
      registrationName: 'S7S',
      address: Address(
        street: '__',
        building: '00',
        citySubdivision: 'ssss',
        city: 'jeddah',
        postalZone: '00000',
      ),
    ),
    previousInvoiceHash: "zDnQnE05P6rFMqF1ai21V5hIRlUq/EXvrpsaoPkWRVI=",
    invoiceRelationType: InvoiceRelationType.b2c,
  );

  /// Extract XML and QR string from the generated QR data.
  String xml = qrData.xmlString;
  String qr = zatcaManager.getQrString(qrData);

  /// Extract additional details like invoice hash and digital signature.
  String invoiceHash = qrData.invoiceHash;
  String invoiceXmlString = qrData.xmlString;

  /// Generate UBL XML using the extracted details.
  String ublXML = zatcaManager.generateUBLXml(
    invoiceHash: invoiceHash,
    signingTime:
        "${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now())}Z",
    digitalSignature: qrData.digitalSignature,
    invoiceXmlString: invoiceXmlString,
    qrString: qr,
  );

  /// Debug output to print the generated XML, QR, and UBL XML.
  if (kDebugMode) {
    print("XML: $xml");
    print("qr: $qr");
    print("UBL XML: $ublXML");
  }
}
