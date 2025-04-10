/// This file contains all the enums used in the app
enum InvoiceType {
  /// Standard Invoices and Simplified Invoices
  standardInvoicesAndSimplifiedInvoices(
    "Standard Invoices and Simplified Invoices",
  ),

  ///Simplified Credit Note
  simplifiedCreditNote("SimplifiedCreditNote");

  /// enum string value.
  final String value;

  /// Constructor for [InvoiceType] enum.
  const InvoiceType(this.value);
}

/// This enum represents the type of invoice relation.
enum InvoiceRelationType { b2b, b2c }
