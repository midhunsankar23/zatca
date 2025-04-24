import 'package:flutter_test/flutter_test.dart';
import 'package:zatca/models/invoice_data_model.dart';
import 'package:zatca/resources/enums.dart';

import 'package:zatca/zatca_manager.dart';

void main() {
  test('adds one to input values', () {
    final zatcaManager = ZatcaManager.instance;
    zatcaManager.initializeZacta(
      sellerName: "Wesam Alzahir",
      sellerTRN: "399999999900003",
      supplier: Supplier(
        companyID: "399999999900003",
        companyCRN: "454634645645654",
        registrationName: "Wesam Alzahir",
        address: Address(
          streetName: "King Fahahd st",
          buildingNumber: "0000",
          citySubdivisionName: "West",
          cityName: "Khobar",
          postalZone: "31952",
        ),
      ),


      ///PrivateKey
      privateKeyBase64:"""-----BEGIN EC PRIVATE KEY-----
-----END EC PRIVATE KEY-----""",
          

      ///"""-----BEGIN CERTIFICATE REQUEST-----\nCSRKEY\n-----END CERTIFICATE REQUEST-----",
      certificateRequestBase64:
          """-----BEGIN CERTIFICATE REQUEST-----
-----END CERTIFICATE REQUEST-----""",
    );

    final qrData = zatcaManager.generateZatcaQrInit(
      invoiceLines: [
        InvoiceLine(
          id: '1',
          quantity: '1',
          unitCode: 'PCE',
          lineExtensionAmount: 10,
          itemName: 'TEST NAME',
          taxPercent: 15,
        ),
      ],
      invoiceType: InvoiceType.standardInvoicesAndSimplifiedInvoices,
      issueDate: "2024-02-29",
      issueTime: "11:40:40",
      invoiceUUid: "6f4d20e0-6bfe-4a80-9389-7dabe6620f14",
      invoiceNumber: "EGS1-886431145-101",
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

    String invoiceHash = qrData.invoiceHash;
    String invoiceXmlString = qrData.xmlString;
    String qrString = zatcaManager.getQrString(qrData);




    String ublXML = zatcaManager.generateUBLXml(
      invoiceHash: invoiceHash,
      signingTime:  DateTime.now().toUtc().toIso8601String(),
      digitalSignature: qrData.digitalSignature,
      invoiceXmlString: invoiceXmlString,
      certificateString: """-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----""",
      qrString: qrString,
    );

    print("XML: $ublXML");
  });
}
