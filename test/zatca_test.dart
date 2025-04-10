import 'package:flutter_test/flutter_test.dart';
import 'package:zatca/models/invoice_data_model.dart';
import 'package:zatca/resources/enums.dart';

import 'package:zatca/zatca_manager.dart';

void main() {
  test('adds one to input values', () {
    final zatcaManager = ZatcaManager.instance;
    zatcaManager.initializeZacta(
      sellerName: "My Branch",
      sellerTRN: "310175397400003",
      supplier: Supplier(
        companyID: "310175397400003",
        registrationName: "My Branch",
        address: Address(
          streetName: "King Fahahd st",
          buildingNumber: "0000",
          citySubdivisionName: "West",
          cityName: "Khobar",
          postalZone: "31952",
        ),
      ),
      privateKeyBase64: "",

      ///PrivateKey
      certificateBase64: "",

      ///"""-----BEGIN CERTIFICATE REQUEST-----\nCSRKEY\n-----END CERTIFICATE REQUEST-----",
    );

    final qrData = zatcaManager.generateZatcaQrInit(
      invoiceLines: [
        InvoiceLine(
          id: '1',
          quantity: '1',
          unitCode: 'PCE',
          lineExtensionAmount: '10.00',
          itemName: 'Item 1',
          taxPercent: '15',
        ),
      ],
      invoiceType: InvoiceType.StandardInvoicesAndSimplifiedInvoices,
      issueDate: "2025-04-08",
      issueTime: "03:41:08",
      invoiceUUid: "8e6000cf-1a98-4174-b3e7-b5d5954bc10d",
      invoiceNumber: "INV0001",
      totalVat: "1.50",
      totalWithVat: "11.50",
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
    String xml = qrData.xmlString;
    String qr = zatcaManager.getQrString(qrData);
  });
}
