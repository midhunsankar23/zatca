import '../resources/enums.dart';

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
