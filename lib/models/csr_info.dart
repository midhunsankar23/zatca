class CsrInfo {
  final String publicKey;
  final List<int> publicKeyRaw;
  final List<int> signature;

  CsrInfo({
    required this.publicKey,
    required this.publicKeyRaw,
    required this.signature,
  });
}
