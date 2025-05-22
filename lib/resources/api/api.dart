import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zatca/resources/cirtificate/certificate_manager.dart';

import '../enums.dart';

class API {
  final ZatcaEnvironment env;

  API(this.env);

  static const settings = {
    "API_VERSION": "V2",
    "SANDBOX_BASEURL": "https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal",
    "SIMULATION_BASEURL": "https://gw-fatoora.zatca.gov.sa/e-invoicing/simulation",
    "PRODUCTION_BASEURL": "https://gw-fatoora.zatca.gov.sa/e-invoicing/core",
  };

  String getBaseUrl() {
    if (env.value == "production") {
      return settings["PRODUCTION_BASEURL"]!;
    } else if (env.value == "simulation") {
      return settings["SIMULATION_BASEURL"]!;
    } else {
      return settings["SANDBOX_BASEURL"]!;
    }
  }

  Map<String, String> getAuthHeaders(String? certificate, String? secret) {
    if (certificate != null && secret != null) {
      final basic = base64Encode(utf8.encode(
          '${base64Encode(utf8.encode(certificate))}:$secret'));
      return {"Authorization": "Basic $basic"};
    }
    return {};
  }

  ComplianceAPI compliance({String? certificate, String? secret}) {
    final authHeaders = getAuthHeaders(certificate, secret);
    final baseUrl = getBaseUrl();
    return ComplianceAPI(authHeaders, baseUrl);
  }

  ProductionAPI production(String? certificate, String? secret) {
    final authHeaders = getAuthHeaders(certificate, secret);
    final baseUrl = getBaseUrl();
    return ProductionAPI(authHeaders, baseUrl);
  }
}

class ComplianceAPI {
  final Map<String, String> authHeaders;
  final String baseUrl;

  ComplianceAPI(this.authHeaders, this.baseUrl);

  Future<Map<String, dynamic>> issueCertificate(String csr, String otp) async {
    final headers = {
      "Accept-Version": API.settings["API_VERSION"]!,
      "OTP": otp,
      'Content-Type': 'application/json',
      ...authHeaders,
    };


    try {
      final response = await http.post(
        Uri.parse('$baseUrl/compliance'),
        headers: headers,
        body: jsonEncode({"csr": base64Encode(utf8.encode(csr))}),
      );

      if (response.statusCode != 200) {
        print("Error: ${response.statusCode}, Body: ${response.body}");
        throw Exception("Error issuing a compliance certificate.");
      }

      final data = jsonDecode(response.body);
      final issuedCertificate = '''
-----BEGIN CERTIFICATE-----
${utf8.decode(base64Decode(data["binarySecurityToken"]))}
-----END CERTIFICATE-----
''';
      return {
        "issued_certificate": issuedCertificate,
        "api_secret": data["secret"],
        "request_id": data["requestID"],
      };
    }
    catch (e) {
      print("An error occurred: $e");
      rethrow;
    }
  }

  Future<dynamic> checkInvoiceCompliance(
      String signedXmlString, String invoiceHash, String egsUuid) async {
    final headers = {
      "Accept-Version": API.settings["API_VERSION"]!,
      "Accept-Language": "en",
      ...authHeaders,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/compliance/invoices'),
      headers: headers,
      body: jsonEncode({
        "invoiceHash": invoiceHash,
        "uuid": egsUuid,
        "invoice": base64Encode(utf8.encode(signedXmlString)),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 202) {
      throw Exception("Error in compliance check.");
    }

    return jsonDecode(response.body);
  }
}

class ProductionAPI {
  final Map<String, String> authHeaders;
  final String baseUrl;

  ProductionAPI(this.authHeaders, this.baseUrl);

  Future<Map<String, dynamic>> issueCertificate(String complianceRequestId) async {
    final headers = {
      "Accept-Version": API.settings["API_VERSION"]!,
      'Content-Type': 'application/json',
      ...authHeaders,
    };


    final response = await http.post(
      Uri.parse('$baseUrl/production/csids'),
      headers: headers,
      body: jsonEncode({"compliance_request_id": complianceRequestId}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error issuing a production certificate.");
    }

    final data = jsonDecode(response.body);
    final issuedCertificate = '''
-----BEGIN CERTIFICATE-----
${utf8.decode(base64Decode(data["binarySecurityToken"]))}
-----END CERTIFICATE-----
''';
    return {
      "issued_certificate": issuedCertificate,
      "api_secret": data["secret"],
      "request_id": data["requestID"],
    };
  }

  Future<dynamic> reportInvoice(
      String signedXmlString, String invoiceHash, String egsUuid) async {
    final headers = {
      "Accept-Version": API.settings["API_VERSION"]!,
      "Accept-Language": "en",
      "Clearance-Status": "0",
      ...authHeaders,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/invoices/reporting/single'),
      headers: headers,
      body: jsonEncode({
        "invoiceHash": invoiceHash,
        "uuid": egsUuid,
        "invoice": base64Encode(utf8.encode(signedXmlString)),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 202) {
      throw Exception("Error in reporting invoice.");
    }

    return jsonDecode(response.body);
  }

  Future<dynamic> clearanceInvoice(
      String signedXmlString, String invoiceHash, String egsUuid) async {
    final headers = {
      "Accept-Version": API.settings["API_VERSION"]!,
      "Accept-Language": "en",
      "Clearance-Status": "1",
      ...authHeaders,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/invoices/clearance/single'),
      headers: headers,
      body: jsonEncode({
        "invoiceHash": invoiceHash,
        "uuid": egsUuid,
        "invoice": base64Encode(utf8.encode(signedXmlString)),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 202) {
      throw Exception("Error in clearance invoice.");
    }

    return jsonDecode(response.body);
  }
}
