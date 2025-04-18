import 'package:flutter/foundation.dart';
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

      ///PrivateKey
      privateKeyBase64:
          "MHQCAQEEIDzVBdqqr6WdCemM/+M78r/oVEY5ZT683OzIyCln4T68oAcGBSuBBAAKoUQDQgAER8D8uQYrEOLw52BqwDi+suE6N7HK1yYQs30q2kTbCEia69jyR8YfNNDleO8HRjVHQSxbRTv3tlvxfUMOEmXJwg==",

      ///"""-----BEGIN CERTIFICATE REQUEST-----\nCSRKEY\n-----END CERTIFICATE REQUEST-----",
      certificateRequestBase64:
          "-----BEGIN CERTIFICATE REQUEST-----\nMIICATCCAacCAQAwTTENMAsGA1UEAwwERUdTMjEXMBUGA1UECwwOTXkgQnJhbmNoIE5hbWUxFjAUBgNVBAoMDVdlc2FtIEFsemFoaXIxCzAJBgNVBAYTAlNBMFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAER8D8uQYrEOLw52BqwDi+suE6N7HK1yYQs30q2kTbCEia69jyR8YfNNDleO8HRjVHQSxbRTv3tlvxfUMOEmXJwqCB+jCB9wYJKoZIhvcNAQkOMYHpMIHmMCQGCSsGAQQBgjcUAgQXDBVQUkVaQVRDQS1Db2RlLVNpZ25pbmcwgb0GA1UdEQSBtTCBsqSBrzCBrDFFMEMGA1UEBAw8MS1zb2x1dGlvbl9uYW1lfDItSU9TfDMtNmY0ZDIwZTAtNmJmZS00YTgwLTkzODktN2RhYmU2NjIwZjE0MR8wHQYKCZImiZPyLGQBAQwPMzk5OTk5OTk5OTAwMDAzMQ0wCwYDVQQMDAQxMTAwMSQwIgYDVQQaDBswMDAwIEtpbmcgRmFoYWhkIHN0LCBLaG9iYXIxDTALBgNVBA8MBEZvb2QwCgYIKoZIzj0EAwIDSAAwRQIhAOB7u3iDWL76C4ILxX0UiBj0Z7fdEYxMSfOqtjOQ3elZAiAVxCtpwCOO6hob5VRlP6EMkZD74rSrxSAFmWylcH4d8Q==\n-----END CERTIFICATE REQUEST-----",
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
      invoiceType: InvoiceType.standardInvoicesAndSimplifiedInvoices,
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

    String invoiceHash = qrData.invoiceHash;
    String invoiceXmlString = qrData.xmlString;
    String qrString = zatcaManager.getQrString(qrData);





    String ublXML = zatcaManager.generateUBLXml(
      invoiceHash: invoiceHash,
      signingTime: qrData.issueDateTime,
      digitalSignature: qrData.digitalSignature,
      invoiceXmlString: invoiceXmlString,
      certificateString:"-----BEGIN CERTIFICATE-----\nMIICJjCCAcugAwIBAgIGAZY+aKMzMAoGCCqGSM49BAMCMBUxEzARBgNVBAMMCmVJbnZvaWNpbmcwHhcNMjUwNDE2MTE0MjQyWhcNMzAwNDE1MjEwMDAwWjBNMQ0wCwYDVQQDDARFR1MyMRcwFQYDVQQLDA5NeSBCcmFuY2ggTmFtZTEWMBQGA1UECgwNV2VzYW0gQWx6YWhpcjELMAkGA1UEBhMCU0EwVjAQBgcqhkjOPQIBBgUrgQQACgNCAARHwPy5BisQ4vDnYGrAOL6y4To3scrXJhCzfSraRNsISJrr2PJHxh800OV47wdGNUdBLFtFO/e2W/F9Qw4SZcnCo4HRMIHOMAwGA1UdEwEB/wQCMAAwgb0GA1UdEQSBtTCBsqSBrzCBrDFFMEMGA1UEBAw8MS1zb2x1dGlvbl9uYW1lfDItSU9TfDMtNmY0ZDIwZTAtNmJmZS00YTgwLTkzODktN2RhYmU2NjIwZjE0MR8wHQYKCZImiZPyLGQBAQwPMzk5OTk5OTk5OTAwMDAzMQ0wCwYDVQQMDAQxMTAwMSQwIgYDVQQaDBswMDAwIEtpbmcgRmFoYWhkIHN0LCBLaG9iYXIxDTALBgNVBA8MBEZvb2QwCgYIKoZIzj0EAwIDSQAwRgIhAKqAfNuHQghUGtz543jAHWddoAAWVra9IaD+LO/P6TT3AiEA6P9hv9F4+XGweROZXJk8b6d1wvIscHt5Vdqpo/EICcY=\n-----END CERTIFICATE-----",
      qrString: qrString,
    );

    print("invoiceXmlString: $ublXML");

  });
}
