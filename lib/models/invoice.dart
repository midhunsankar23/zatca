import 'package:zatca/models/supplier.dart';

import 'customer.dart';

/// Represents a ZATCA-compliant invoice.
class ZatcaInvoice {
  /// The profile ID of the invoice.
  final String profileID;

  /// The unique identifier of the invoice.
  final String id;

  /// The universally unique identifier (UUID) of the invoice.
  final String uuid;

  /// The issue date of the invoice in ISO 8601 format.
  final String issueDate;

  /// The issue time of the invoice in ISO 8601 format.
  final String issueTime;

  /// The type code of the invoice.
  final String invoiceTypeCode;

  /// The name of the invoice type.
  final String invoiceTypeName;

  /// Additional notes or comments about the invoice.
  final String note;

  /// The currency code used in the invoice.
  final String currencyCode;

  /// The tax currency code used in the invoice.
  final String taxCurrencyCode;

  /// The supplier information.
  final Supplier supplier;

  /// The customer information.
  final Customer customer;

  /// The list of invoice line items.
  final List<InvoiceLine> invoiceLines;

  /// The total tax amount for the invoice.
  final double taxAmount;

  /// The total amount for the invoice.
  final double totalAmount;

  /// The hash of the previous invoice, if applicable.
  final String previousInvoiceHash;

  /// Creates a new [ZatcaInvoice] instance.
  ZatcaInvoice({
    required this.profileID,
    required this.id,
    required this.uuid,
    required this.issueDate,
    required this.issueTime,
    required this.invoiceTypeCode,
    required this.invoiceTypeName,
    required this.note,
    required this.currencyCode,
    required this.taxCurrencyCode,
    required this.supplier,
    required this.customer,
    required this.invoiceLines,
    required this.taxAmount,
    required this.totalAmount,
    required this.previousInvoiceHash,
  });

  /// Creates a [ZatcaInvoice] instance from a [Map].
  factory ZatcaInvoice.fromMap(Map<String, dynamic> map) {
    return ZatcaInvoice(
      profileID: map['profileID'] ?? '',
      id: map['id'] ?? '',
      uuid: map['uuid'] ?? '',
      issueDate: map['issueDate'] ?? '',
      issueTime: map['issueTime'] ?? '',
      invoiceTypeCode: map['invoiceTypeCode'] ?? '',
      invoiceTypeName: map['invoiceTypeName'] ?? '',
      note: map['note'] ?? '',
      currencyCode: map['currencyCode'] ?? '',
      taxCurrencyCode: map['taxCurrencyCode'] ?? '',
      supplier: Supplier.fromMap(map['supplier']),
      customer: Customer.fromMap(map['customer']),
      invoiceLines:
          (map['invoiceLines'] as List<dynamic>)
              .map((line) => InvoiceLine.fromMap(line))
              .toList(),
      taxAmount: map['taxAmount'] ?? '',
      totalAmount: map['totalAmount'] ?? '',
      previousInvoiceHash: map['previousInvoiceHash'] ?? '',
    );
  }

  /// Converts the [ZatcaInvoice] instance to a [Map].
  Map<String, dynamic> toMap() {
    return {
      'profileID': profileID,
      'id': id,
      'uuid': uuid,
      'issueDate': issueDate,
      'issueTime': issueTime,
      'invoiceTypeCode': invoiceTypeCode,
      'invoiceTypeName': invoiceTypeName,
      'note': note,
      'currencyCode': currencyCode,
      'taxCurrencyCode': taxCurrencyCode,
      'supplier': supplier.toMap(),
      'customer': customer.toMap(),
      'invoiceLines': invoiceLines.map((line) => line.toMap()).toList(),
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'previousInvoiceHash': previousInvoiceHash,
    };
  }
}

/// Represents an invoice line item in the invoice.
class InvoiceLine {
  final String id;
  final String quantity;
  final String unitCode;
  final double lineExtensionAmount;
  final String itemName;
  final double taxPercent;

  /// Creates a new [InvoiceLine] instance.
  InvoiceLine({
    required this.id,
    required this.quantity,
    required this.unitCode,
    required this.lineExtensionAmount,
    required this.itemName,
    required this.taxPercent,
  });

  /// Creates an [InvoiceLine] instance from a [Map].
  factory InvoiceLine.fromMap(Map<String, dynamic> map) {
    return InvoiceLine(
      id: map['id'] ?? '',
      quantity: map['quantity'] ?? '',
      unitCode: map['unitCode'] ?? '',
      lineExtensionAmount: map['lineExtensionAmount'] ?? '',
      itemName: map['itemName'] ?? '',
      taxPercent: map['taxPercent'] ?? '',
    );
  }

  /// Converts the [InvoiceLine] instance to a [Map].
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantity': quantity,
      'unitCode': unitCode,
      'lineExtensionAmount': lineExtensionAmount,
      'itemName': itemName,
      'taxPercent': taxPercent,
    };
  }
}
