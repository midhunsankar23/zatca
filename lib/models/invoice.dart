import 'package:zatca/models/supplier.dart';
import 'package:zatca/resources/enums.dart';

import 'customer.dart';

/// Represents a ZATCA-compliant invoice.
class Invoice {


  /// The unique identifier of the invoice.
  final String invoiceNumber;

  /// The universally unique identifier (UUID) of the invoice.
  final String uuid;

  /// The issue date of the invoice in ISO 8601 format.
  final String issueDate;

  /// The issue time of the invoice in ISO 8601 format.
  final String issueTime;

  /// The type code of the invoice.
  final InvoiceType invoiceType;

  /// The currency code used in the invoice.
  final String currencyCode;

  /// The tax currency code used in the invoice.
  final String taxCurrencyCode;

  /// The customer information.
  final Customer? customer;

  /// The list of invoice line items.
  final List<InvoiceLine> invoiceLines;

  /// The total tax amount for the invoice.
  final double taxAmount;

  /// The total amount for the invoice.
  final double totalAmount;

  /// The hash of the previous invoice, if applicable.
  final String previousInvoiceHash;

  final InvoiceCancellation? cancellation;


  /// The issue date of the invoice in ISO 8601 format.
  final String? actualDeliveryDate;

  /// Creates a new [Invoice] instance.
  Invoice({
    required this.invoiceNumber,
    required this.uuid,
    required this.issueDate,
    required this.issueTime,
    required this.invoiceType,
    this.currencyCode='SAR',
    this.taxCurrencyCode='SAR',
    this.customer,
    required this.invoiceLines,
    required this.taxAmount,
    required this.totalAmount,
    required this.previousInvoiceHash,
    this.cancellation,
    this.actualDeliveryDate,
  });

  /// Creates a [Invoice] instance from a [Map].
  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      invoiceNumber: map['id'] ?? '',
      uuid: map['uuid'] ?? '',
      issueDate: map['issueDate'] ?? '',
      issueTime: map['issueTime'] ?? '',
      invoiceType: InvoiceType.values[map['invoiceType']],
      currencyCode: map['currencyCode'] ?? '',
      taxCurrencyCode: map['taxCurrencyCode'] ?? '',
      customer: Customer.fromMap(map['customer']),
      invoiceLines:
          (map['invoiceLines'] as List<dynamic>)
              .map((line) => InvoiceLine.fromMap(line))
              .toList(),
      taxAmount: map['taxAmount'] ?? '',
      totalAmount: map['totalAmount'] ?? '',
      previousInvoiceHash: map['previousInvoiceHash'] ?? '' ,
    );
  }

  /// Converts the [Invoice] instance to a [Map].
  Map<String, dynamic> toMap() {
    return {
      'id': invoiceNumber,
      'uuid': uuid,
      'issueDate': issueDate,
      'issueTime': issueTime,
      'invoiceType': invoiceType.index,
      'currencyCode': currencyCode,
      'taxCurrencyCode': taxCurrencyCode,
      'customer': customer?.toMap(),
      'invoiceLines': invoiceLines.map((line) => line.toMap()).toList(),
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'previousInvoiceHash': previousInvoiceHash,
    };
  }
}


/// Represents a ZATCA-compliant invoice.
class ZatcaInvoice extends Invoice{

  /// The profile ID of the invoice.
  final String profileID;

  /// The supplier information.
  final Supplier supplier;


  /// Creates a new [ZatcaInvoice] instance.
  ZatcaInvoice({
    this.profileID='reporting:1.0',
    required super.invoiceNumber,
    required super.uuid,
    required super.issueDate,
    required super.issueTime,
    required super.invoiceType,
    super.currencyCode='SAR',
    super.taxCurrencyCode='SAR',
    required this.supplier,
    required Customer customer,
    required super.invoiceLines,
    required super.taxAmount,
    required super.totalAmount,
    required super.previousInvoiceHash,
    cancellation,
    actualDeliveryDate,
  }):super(customer: customer,cancellation: cancellation,actualDeliveryDate: actualDeliveryDate);

  /// Creates a [ZatcaInvoice] instance from a [Map].
  factory ZatcaInvoice.fromMap(Map<String, dynamic> map) {
    return ZatcaInvoice(
      profileID: map['profileID'] ?? '',
      invoiceNumber: map['id'] ?? '',
      uuid: map['uuid'] ?? '',
      issueDate: map['issueDate'] ?? '',
      issueTime: map['issueTime'] ?? '',
      invoiceType: InvoiceType.values[map['invoiceType']],
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
      'id': invoiceNumber,
      'uuid': uuid,
      'issueDate': issueDate,
      'issueTime': issueTime,
      'invoiceType': invoiceType,
      'currencyCode': currencyCode,
      'taxCurrencyCode': taxCurrencyCode,
      'supplier': supplier.toMap(),
      'customer': customer?.toMap(),
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

/// Represents the cancellation details of an invoice.
class InvoiceCancellation {
  /// The reason for the cancellation.
  final String reason;

  /// The canceled serial invoice number.
  final String canceledSerialInvoiceNumber;

  /// The payment method used.
  final ZATCAPaymentMethods paymentMethod;

  /// Creates a new [InvoiceCancellation] instance.
  InvoiceCancellation({
    required this.reason,
    required this.canceledSerialInvoiceNumber,
    required this.paymentMethod,
  });

  /// Creates an [InvoiceCancellation] instance from a [Map].
  factory InvoiceCancellation.fromMap(Map<String, dynamic> map) {
    return InvoiceCancellation(
      reason: map['reason'] ?? '',
      canceledSerialInvoiceNumber: map['canceled_serial_invoice_number'] ?? '',
      paymentMethod: ZATCAPaymentMethods.values[map['payment_method']],
    );
  }

  /// Converts the [InvoiceCancellation] instance to a [Map].
  Map<String, dynamic> toMap() {
    return {
      'reason': reason,
      'canceled_serial_invoice_number': canceledSerialInvoiceNumber,
      'payment_method': paymentMethod.index,
    };
  }
}