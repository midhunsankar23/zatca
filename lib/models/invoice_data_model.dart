class ZatcaInvoice {
  final String profileID;
  final String id;
  final String uuid;
  final String issueDate;
  final String issueTime;
  final String invoiceTypeCode;
  final String invoiceTypeName;
  final String note;
  final String currencyCode;
  final String taxCurrencyCode;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceLine> invoiceLines;
  final String taxAmount;
  final String totalAmount;
  final String previousInvoiceHash;

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

class Supplier {
  final String companyID;
  final String registrationName;
  final Address address;

  Supplier({
    required this.companyID,
    required this.registrationName,
    required this.address,
  });
  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      companyID: map['companyID'] ?? '',
      registrationName: map['registrationName'] ?? '',
      address: Address.fromMap(map['address']),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'companyID': companyID,
      'registrationName': registrationName,
      'address': address.toMap(),
    };
  }
}

class Customer {
  final String companyID;
  final String registrationName;
  final Address address;

  Customer({
    required this.companyID,
    required this.registrationName,
    required this.address,
  });
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      companyID: map['companyID'] ?? '',
      registrationName: map['registrationName'] ?? '',
      address: Address.fromMap(map['address']),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'companyID': companyID,
      'registrationName': registrationName,
      'address': address.toMap(),
    };
  }
}

class Address {
  final String streetName;
  final String buildingNumber;
  final String citySubdivisionName;
  final String cityName;
  final String postalZone;
  final String countryCode;

  Address({
    required this.streetName,
    required this.buildingNumber,
    required this.citySubdivisionName,
    required this.cityName,
    required this.postalZone,
    this.countryCode = "SA",
  });
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      streetName: map['streetName'] ?? '',
      buildingNumber: map['buildingNumber'] ?? '',
      citySubdivisionName: map['citySubdivisionName'] ?? '',
      cityName: map['cityName'] ?? '',
      postalZone: map['postalZone'] ?? '',
      countryCode: map['countryCode'] ?? 'SA',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'streetName': streetName,
      'buildingNumber': buildingNumber,
      'citySubdivisionName': citySubdivisionName,
      'cityName': cityName,
      'postalZone': postalZone,
      'countryCode': countryCode,
    };
  }
}

class InvoiceLine {
  final String id;
  final String quantity;
  final String unitCode;
  final String lineExtensionAmount;
  final String itemName;
  final String taxPercent;

  InvoiceLine({
    required this.id,
    required this.quantity,
    required this.unitCode,
    required this.lineExtensionAmount,
    required this.itemName,
    required this.taxPercent,
  });
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
