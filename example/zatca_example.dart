import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:zatca/models/invoice_data_model.dart';
import 'package:zatca/resources/enums.dart';
import 'package:zatca/zatca_manager.dart';

void main() {
  /// Initialize the ZatcaManager singleton instance with seller and supplier details.
  final zatcaManager = ZatcaManager.instance;
  zatcaManager.initializeZacta(
    sellerName: "My Branch",
    sellerTRN: "310175397400003",
    supplier: Supplier(
      companyID: "310175397400003",
      companyCRN: "454634645645654",
      registrationName: "My Branch",
      address: Address(
        streetName: "King Fahahd st",
        buildingNumber: "0000",
        citySubdivisionName: "West",
        cityName: "Khobar",
        postalZone: "31952",
      ),
    ),
    privateKeyPem:
        """-----BEGIN EC PRIVATE KEY-----\nprivate_key_pem_content\n-----END EC PRIVATE KEY-----""",
    certificatePem:
        """-----BEGIN CERTIFICATE-----\ncertificate_pem_content\n-----END CERTIFICATE-----""",
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
        streetName: '__',
        buildingNumber: '00',
        citySubdivisionName: 'ssss',
        cityName: 'jeddah',
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
  String qrString = zatcaManager.getQrString(qrData);

  /// Generate UBL XML using the extracted details.
  String ublXML = zatcaManager.generateUBLXml(
    invoiceHash: invoiceHash,
    signingTime:
        "${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now().toUtc())}Z",
    digitalSignature: qrData.digitalSignature,
    invoiceXmlString: invoiceXmlString,
    qrString: qrString,
  );

  /// Debug output to print the generated XML, QR, and UBL XML.
  if (kDebugMode) {
    print("XML: $xml");
    print("qr: $qr");
    print("UBL XML: $ublXML");
  }
}
