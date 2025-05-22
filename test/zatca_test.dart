import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:zatca/models/address.dart';
import 'package:zatca/models/compliance_certificate.dart';
import 'package:zatca/models/customer.dart';
import 'package:zatca/models/egs_unit.dart';
import 'package:zatca/models/invoice.dart';
import 'package:zatca/models/supplier.dart';
import 'package:zatca/resources/cirtificate/certificate_manager.dart';
import 'package:zatca/resources/enums.dart';

import 'package:zatca/zatca_manager.dart';

void main() {

  late EGSUnitInfo egsUnitInfo;
  late String privateKeyPem;
  late ZatcaCertificate complianceCertificate;
  test('adds one to input values', () async {


   egsUnitInfo=EGSUnitInfo(
      uuid: "6f4d20e0-6bfe-4a80-9389-7dabe6620f14",
      taxpayerProvidedId: 'EGS2',
      model: 'IOS',
      crnNumber: '454634645645654',
      taxpayerName: "Wesam Alzahir",
      vatNumber: '399999999900003',
      branchName: 'My Branch Name',
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

  final certificateManager = CertificateManager.instance;
  certificateManager.env=ZatcaEnvironment.development;

  final keyPair=certificateManager.generateKeyPair();
  privateKeyPem= keyPair['privateKeyPem'];
  final csrPop= egsUnitInfo.toCsrProps("solution_name");
  final csr= await certificateManager.generateCSR(privateKeyPem,csrPop);

  complianceCertificate= await certificateManager.issueComplianceCertificate(csr,'123345');
  final productionCertificate= await certificateManager.issueProductionCertificate(complianceCertificate);

  });
  test('adds one to input values', () async{

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
            certificatePem: complianceCertificate.complianceCertificatePem,
          );

      final qrData = zatcaManager.generateZatcaQrInit(

      invoiceType: InvoiceType.standardInvoicesAndSimplifiedInvoices,
      issueDate: "2024-02-29",
      issueTime: "11:40:40",
      invoiceUUid: egsUnitInfo.uuid,
      invoiceNumber: "EGS1-886431145-101",
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
    );

    String invoiceHash = qrData.invoiceHash;
    String invoiceXmlString = qrData.xmlString;
    String qr = zatcaManager.getQrString(qrData);

    print("qr: $qr");
    String ublXML = zatcaManager.generateUBLXml(
      invoiceHash: invoiceHash,
      signingTime:
          "${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now())}Z",
      digitalSignature: qrData.digitalSignature,
      invoiceXmlString: invoiceXmlString,
      qrString: qr,
    );

    // print("XML: $ublXML");


  });
}
