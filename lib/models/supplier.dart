import 'address.dart';

/// Represents a supplier in the invoice.
class Supplier {
  /// The company ID of the supplier.
  final String companyID;

  final String companyCRN;

  /// The registration name of the supplier.
  final String registrationName;

  /// The address of the supplier.
  final Location location;

  /// Creates a new [Supplier] instance.
  Supplier({
    required this.companyID,
    required this.companyCRN,
    required this.registrationName,
    required this.location,
  });

  /// Creates a [Supplier] instance from a [Map].
  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      companyID: map['companyID'] ?? '',
      companyCRN: map['companyCRN'] ?? '',
      registrationName: map['registrationName'] ?? '',
      location: Location.fromMap(map['location']),
    );
  }

  /// Converts the [Supplier] instance to a [Map].
  Map<String, dynamic> toMap() {
    return {
      'companyID': companyID,
      'registrationName': registrationName,
      'address': location.toMap(),
    };
  }
}
