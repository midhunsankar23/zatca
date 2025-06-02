import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'dart:convert';
import 'package:zatca/resources/api/api.dart';
import 'package:zatca/resources/cirtificate/templates/csr_template.dart';
import 'package:path_provider/path_provider.dart';

import 'resources/enums.dart';
import 'resources/cirtificate/certficate_util.dart';
import 'models/compliance_certificate.dart';

/// The `CertificateManager` class is a singleton that manages the generation of key pairs, CSRs, and the issuance of compliance and production certificates.
class CertificateManager {
  ZatcaEnvironment env = ZatcaEnvironment.development;
  CertificateManager._();

  /// The single instance of the `CertificateManager` class.
  static CertificateManager instance = CertificateManager._();

  /// Generates a key pair for the EGS unit.
  Map<String, dynamic> generateKeyPair() {
    {
      final keyPair = CryptoUtils.generateEcKeyPair(curve: 'secp256k1');

      final privateKey = keyPair.privateKey as ECPrivateKey;
      // final publicKey = keyPair.publicKey as ECPublicKey;

      final privatePem = CryptoUtils.encodeEcPrivateKeyToPem(privateKey);
      return {'privateKeyPem': privatePem};
    }
  }

  /// Generates a CSR (Certificate Signing Request) using the provided private key and CSR configuration properties.
  Future<String> generateCSR(String privateKeyPem, CSRConfigProps csrProps) {
    /// Check if the platform is desktop (Windows, Linux, or macOS)
    bool isDeskTop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    /// If the platform is desktop, generate the CSR using OpenSSL
    if (isDeskTop) {
      return generateCSRInDeskTop(privateKeyPem, csrProps);
    } else {
      /// If the platform is not desktop, throw an exception
      throw Exception(
        "CSR generation is not supported on this platform. Please use a desktop platform (Windows, Linux, or macOS) to generate the CSR.",
      );
    }
  }

  /// Generates a CSR (Certificate Signing Request) using the provided private key and CSR configuration properties.
  Future<String> generateCSRInDeskTop(
    String privateKeyPem,
    CSRConfigProps csrProps,
  ) async {
    // Directory supDir = await getApplicationSupportDirectory();
    // String dbPath = supDir.path;
    // final privateKeyFile = '$dbPath/${Uuid().v4()}.pem';
    // final csrConfigFile = '$dbPath/${Uuid().v4()}.cnf';

    print("privateKeyPem-$privateKeyPem-");
    print("csrProps-${csrProps.toTemplate()}-");
    final appDocDir = await getApplicationDocumentsDirectory();

    final privateKeyFile = '${appDocDir.path}/private_key.pem';
    final csrConfigFile = '${appDocDir.path}/csr_config.cnf';


    // final privateKeyFile =
    //     '${Platform.environment['TEMP_FOLDER'] ?? "/tmp/"}${Uuid().v4()}.pem';
    // final csrConfigFile =
    //     '${Platform.environment['TEMP_FOLDER'] ?? "/tmp/"}${Uuid().v4()}.cnf';

    print(privateKeyFile);
    try {
      File(privateKeyFile).writeAsStringSync(privateKeyPem);
      File(csrConfigFile).writeAsStringSync(csrProps.toTemplate());

      /// Execute the OpenSSL command
      final process = await Process.start('openssl', [
        'req',
        '-new',
        '-sha256',
        '-key',
        privateKeyFile,
        '-config',
        csrConfigFile,
      ]);

      /// Capture the output
      final output = await process.stdout.transform(utf8.decoder).join();
      final errorOutput = await process.stderr.transform(utf8.decoder).join();

      /// Check for errors
      if (errorOutput.isNotEmpty) {
        if (errorOutput.contains('Operation not permitted')) {
          throw Exception(
            'Permission denied: Unable to execute OpenSSL. Please ensure the application has the necessary permissions to execute external processes.',
          );
        }
        throw Exception('OpenSSL error: $errorOutput');
      }

      /// Check if the CSR is present in the output
      if (!output.contains('-----BEGIN CERTIFICATE REQUEST-----')) {
        throw Exception('Error: no CSR found in OpenSSL output.');
      }

      /// Extract the CSR
      final csr =
          '-----BEGIN CERTIFICATE REQUEST-----${output.split('-----BEGIN CERTIFICATE REQUEST-----')[1]}'
              .trim();

      /// Perform cleanup if necessary
      File(privateKeyFile).deleteSync();
      File(csrConfigFile).deleteSync();

      return csr;
    } catch (e) {
      print("Error during CSR generation: $e");

      // Perform cleanup in case of an error
      if (File(privateKeyFile).existsSync()) {
        File(privateKeyFile).deleteSync();
      }
      if (File(csrConfigFile).existsSync()) {
        File(csrConfigFile).deleteSync();
      }

      // Rethrow the exception for further handling
      rethrow;
    }
  }

  /// Issues a compliance certificate using the provided CSR and OTP.
  Future<ZatcaCertificate> issueComplianceCertificate(
    String csr,
    String otp,
  ) async {
    final api = API(env);
    final Map<String, dynamic> response = await api
        .compliance()
        .issueCertificate(csr, otp);
    return ZatcaCertificate.fromJson(response);
  }

  /// Issues a production certificate using the provided compliance certificate.
  Future<ZatcaCertificate> issueProductionCertificate(
    ZatcaCertificate certificate,
  ) async {
    final api = API(env);
    final String cleanPem = CertificateUtil.cleanCertificatePem(
      certificate.complianceCertificatePem,
    );
    final Map<String, dynamic> response = await api
        .production(cleanPem, certificate.complianceApiSecret)
        .issueCertificate(certificate.complianceRequestId);
    return ZatcaCertificate.fromJson(response);
  }

  checkInvoiceCompliance({
    required ZatcaCertificate complianceCertificate,
    required String ublXml,
    required String invoiceHash,
    required String uuid,
  }) async {
    final api = API(env);
    final String cleanPem = CertificateUtil.cleanCertificatePem(
      complianceCertificate.complianceCertificatePem,
    );
    final Map<String, dynamic> response = await api
        .compliance(
          certificate: cleanPem,
          secret: complianceCertificate.complianceApiSecret,
        )
        .checkInvoiceCompliance(
          signedXmlString: ublXml,
          invoiceHash: invoiceHash,
          egsUuid: uuid,
        );
    print(response);
  }
}
