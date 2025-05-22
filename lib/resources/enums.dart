/// This file contains all the enums used in the app
enum InvoiceType {
  /// Standard Invoices and Simplified Invoices
  standardInvoicesAndSimplifiedInvoices(
    "Standard Invoices and Simplified Invoices",
    "0200000",
  ),

  ///Simplified Credit Note
  simplifiedCreditNote("SimplifiedCreditNote", "0200000");

  /// enum string value.
  final String name;
  final String value;

  /// Constructor for [InvoiceType] enum.
  const InvoiceType(this.name, this.value);
}

/// This enum represents the type of invoice relation.
enum InvoiceRelationType { b2b, b2c }


enum ZatcaEnvironment {
  production("production"),
  development("development");

  final String value;
  const ZatcaEnvironment(this.value);
}