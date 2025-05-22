

class ZatcaCertificate {
  final String complianceCertificatePem;
  final String complianceApiSecret;
  final String complianceRequestId;

  ZatcaCertificate({
    required this.complianceCertificatePem,
    required this.complianceApiSecret,
    required this.complianceRequestId,
  });

  factory ZatcaCertificate.fromJson(Map<String, dynamic> json) {
    return ZatcaCertificate(
      complianceCertificatePem: json['issued_certificate'],
      complianceApiSecret: json['api_secret'],
      complianceRequestId: json['request_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issued_certificate': complianceCertificatePem,
      'api_secret': complianceApiSecret,
      'request_id': complianceRequestId,
    };
  }
}