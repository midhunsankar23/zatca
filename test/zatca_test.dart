import 'package:flutter/foundation.dart';
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
      privateKeyBase64:
          "MHQCAQEEIDzVBdqqr6WdCemM/+M78r/oVEY5ZT683OzIyCln4T68oAcGBSuBBAAKoUQDQgAER8D8uQYrEOLw52BqwDi+suE6N7HK1yYQs30q2kTbCEia69jyR8YfNNDleO8HRjVHQSxbRTv3tlvxfUMOEmXJwg==",

      ///"""-----BEGIN CERTIFICATE REQUEST-----\nCSRKEY\n-----END CERTIFICATE REQUEST-----",
      certificateRequestBase64:
          "-----BEGIN CERTIFICATE REQUEST-----\nMIICATCCAacCAQAwTTENMAsGA1UEAwwERUdTMjEXMBUGA1UECwwOTXkgQnJhbmNoIE5hbWUxFjAUBgNVBAoMDVdlc2FtIEFsemFoaXIxCzAJBgNVBAYTAlNBMFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAER8D8uQYrEOLw52BqwDi+suE6N7HK1yYQs30q2kTbCEia69jyR8YfNNDleO8HRjVHQSxbRTv3tlvxfUMOEmXJwqCB+jCB9wYJKoZIhvcNAQkOMYHpMIHmMCQGCSsGAQQBgjcUAgQXDBVQUkVaQVRDQS1Db2RlLVNpZ25pbmcwgb0GA1UdEQSBtTCBsqSBrzCBrDFFMEMGA1UEBAw8MS1zb2x1dGlvbl9uYW1lfDItSU9TfDMtNmY0ZDIwZTAtNmJmZS00YTgwLTkzODktN2RhYmU2NjIwZjE0MR8wHQYKCZImiZPyLGQBAQwPMzk5OTk5OTk5OTAwMDAzMQ0wCwYDVQQMDAQxMTAwMSQwIgYDVQQaDBswMDAwIEtpbmcgRmFoYWhkIHN0LCBLaG9iYXIxDTALBgNVBA8MBEZvb2QwCgYIKoZIzj0EAwIDSAAwRQIhAOB7u3iDWL76C4ILxX0UiBj0Z7fdEYxMSfOqtjOQ3elZAiAVxCtpwCOO6hob5VRlP6EMkZD74rSrxSAFmWylcH4d8Q==\n-----END CERTIFICATE REQUEST-----",
     issuedCertificateBase64: """-----BEGIN CERTIFICATE-----"
         "MIID3jCCA4SgAwIBAgITEQAAOAPF90Ajs/xcXwABAAA4AzAKBggqhkjOPQQDAjBiMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEzARBgoJkiaJk/IsZAEZFgNnb3YxFzAVBgoJkiaJk/IsZAEZFgdleHRnYXp0MRswGQYDVQQDExJQUlpFSU5WT0lDRVNDQTQtQ0EwHhcNMjQwMTExMDkxOTMwWhcNMjkwMTA5MDkxOTMwWjB1MQswCQYDVQQGEwJTQTEmMCQGA1UEChMdTWF4aW11bSBTcGVlZCBUZWNoIFN1cHBseSBMVEQxFjAUBgNVBAsTDVJpeWFkaCBCcmFuY2gxJjAkBgNVBAMTHVRTVC04ODY0MzExNDUtMzk5OTk5OTk5OTAwMDAzMFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEoWCKa0Sa9FIErTOv0uAkC1VIKXxU9nPpx2vlf4yhMejy8c02XJblDq7tPydo8mq0ahOMmNo8gwni7Xt1KT9UeKOCAgcwggIDMIGtBgNVHREEgaUwgaKkgZ8wgZwxOzA5BgNVBAQMMjEtVFNUfDItVFNUfDMtZWQyMmYxZDgtZTZhMi0xMTE4LTliNTgtZDlhOGYxMWU0NDVmMR8wHQYKCZImiZPyLGQBAQwPMzk5OTk5OTk5OTAwMDAzMQ0wCwYDVQQMDAQxMTAwMREwDwYDVQQaDAhSUlJEMjkyOTEaMBgGA1UEDwwRU3VwcGx5IGFjdGl2aXRpZXMwHQYDVR0OBBYEFEX+YvmmtnYoDf9BGbKo7ocTKYK1MB8GA1UdIwQYMBaAFJvKqqLtmqwskIFzVvpP2PxT+9NnMHsGCCsGAQUFBwEBBG8wbTBrBggrBgEFBQcwAoZfaHR0cDovL2FpYTQuemF0Y2EuZ292LnNhL0NlcnRFbnJvbGwvUFJaRUludm9pY2VTQ0E0LmV4dGdhenQuZ292LmxvY2FsX1BSWkVJTlZPSUNFU0NBNC1DQSgxKS5jcnQwDgYDVR0PAQH/BAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIGGqB2E0PsShu2dJIfO+xnTwFVmh/qlZYXZhD4CAWQCARIwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMCMCcGCSsGAQQBgjcVCgQaMBgwCgYIKwYBBQUHAwMwCgYIKwYBBQUHAwIwCgYIKoZIzj0EAwIDSAAwRQIhALE/ichmnWXCUKUbca3yci8oqwaLvFdHVjQrveI9uqAbAiA9hC4M8jgMBADPSzmd2uiPJA6gKR3LE03U75eqbC/rXA==
         -----END CERTIFICATE-----"""
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
      signingTime: qrData.issueDateTime,
      digitalSignature: qrData.digitalSignature,
      invoiceXmlString: invoiceXmlString,
      certificateString:"""-----BEGIN CERTIFICATE-----
MIID3jCCA4SgAwIBAgITEQAAOAPF90Ajs/xcXwABAAA4AzAKBggqhkjOPQQDAjBiMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEzARBgoJkiaJk/IsZAEZFgNnb3YxFzAVBgoJkiaJk/IsZAEZFgdleHRnYXp0MRswGQYDVQQDExJQUlpFSU5WT0lDRVNDQTQtQ0EwHhcNMjQwMTExMDkxOTMwWhcNMjkwMTA5MDkxOTMwWjB1MQswCQYDVQQGEwJTQTEmMCQGA1UEChMdTWF4aW11bSBTcGVlZCBUZWNoIFN1cHBseSBMVEQxFjAUBgNVBAsTDVJpeWFkaCBCcmFuY2gxJjAkBgNVBAMTHVRTVC04ODY0MzExNDUtMzk5OTk5OTk5OTAwMDAzMFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEoWCKa0Sa9FIErTOv0uAkC1VIKXxU9nPpx2vlf4yhMejy8c02XJblDq7tPydo8mq0ahOMmNo8gwni7Xt1KT9UeKOCAgcwggIDMIGtBgNVHREEgaUwgaKkgZ8wgZwxOzA5BgNVBAQMMjEtVFNUfDItVFNUfDMtZWQyMmYxZDgtZTZhMi0xMTE4LTliNTgtZDlhOGYxMWU0NDVmMR8wHQYKCZImiZPyLGQBAQwPMzk5OTk5OTk5OTAwMDAzMQ0wCwYDVQQMDAQxMTAwMREwDwYDVQQaDAhSUlJEMjkyOTEaMBgGA1UEDwwRU3VwcGx5IGFjdGl2aXRpZXMwHQYDVR0OBBYEFEX+YvmmtnYoDf9BGbKo7ocTKYK1MB8GA1UdIwQYMBaAFJvKqqLtmqwskIFzVvpP2PxT+9NnMHsGCCsGAQUFBwEBBG8wbTBrBggrBgEFBQcwAoZfaHR0cDovL2FpYTQuemF0Y2EuZ292LnNhL0NlcnRFbnJvbGwvUFJaRUludm9pY2VTQ0E0LmV4dGdhenQuZ292LmxvY2FsX1BSWkVJTlZPSUNFU0NBNC1DQSgxKS5jcnQwDgYDVR0PAQH/BAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIGGqB2E0PsShu2dJIfO+xnTwFVmh/qlZYXZhD4CAWQCARIwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMCMCcGCSsGAQQBgjcVCgQaMBgwCgYIKwYBBQUHAwMwCgYIKwYBBQUHAwIwCgYIKoZIzj0EAwIDSAAwRQIhALE/ichmnWXCUKUbca3yci8oqwaLvFdHVjQrveI9uqAbAiA9hC4M8jgMBADPSzmd2uiPJA6gKR3LE03U75eqbC/rXA==
-----END CERTIFICATE-----""",
      qrString: qrString,
    );

    // print("invoiceXmlString: $ublXML");

  });
}
