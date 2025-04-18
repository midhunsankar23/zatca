class CertificateInfo {
  final String hash;
  final String issuer;
  final String serialNumber;
  final dynamic publicKey; // Adjust type based on actual structure
  final dynamic signature; // Adjust type based on actual structure

  CertificateInfo({
    required this.hash,
    required this.issuer,
    required this.serialNumber,
    required this.publicKey,
    required this.signature,
  });
}
