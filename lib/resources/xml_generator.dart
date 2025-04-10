import 'package:xml/xml.dart';
import 'package:zatca/models/invoice_data_model.dart';

String generateZATCAXml(ZatcaInvoice data) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element(
    'Invoice',
    nest: () {
      builder.attribute(
        'xmlns',
        'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
      );
      builder.attribute(
        'xmlns:cac',
        'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2',
      );
      builder.attribute(
        'xmlns:cbc',
        'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2',
      );
      builder.attribute(
        'xmlns:ext',
        'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2',
      );

      builder.element('cbc:ProfileID', nest: data.profileID);
      builder.element('cbc:ID', nest: data.id);
      builder.element('cbc:UUID', nest: data.uuid);
      builder.element('cbc:IssueDate', nest: data.issueDate);
      builder.element('cbc:IssueTime', nest: data.issueTime);
      builder.element(
        'cbc:InvoiceTypeCode',
        nest: () {
          builder.attribute('name', data.invoiceTypeName);
          builder.text(data.invoiceTypeCode);
        },
      );
      builder.element(
        'cbc:Note',
        nest: () {
          builder.attribute('languageID', 'ar');
          builder.text(data.note);
        },
      );
      builder.element('cbc:DocumentCurrencyCode', nest: data.currencyCode);
      builder.element('cbc:TaxCurrencyCode', nest: data.taxCurrencyCode);

      builder.element(
        'cac:AdditionalDocumentReference',
        nest: () {
          builder.element('cbc:ID', nest: 'ICV');
          builder.element('cbc:UUID', nest: '1');
        },
      );
      builder.element(
        'cac:AdditionalDocumentReference',
        nest: () {
          builder.element('cbc:ID', nest: 'PIH');
          builder.element(
            'cac:Attachment',
            nest: () {
              builder.element(
                'cbc:EmbeddedDocumentBinaryObject',
                nest: data.previousInvoiceHash,
                attributes: {'mimeCode': 'text/plain'},
              );
            },
          );
        },
      );

      // Supplier
      builder.element(
        'cac:AccountingSupplierParty',
        nest: () {
          builder.element(
            'cac:Party',
            nest: () {
              builder.element(
                'cac:PartyIdentification',
                nest: () {
                  builder.element(
                    'cbc:ID',
                    nest: () {
                      builder.attribute('schemeID', 'CRN');
                      builder.text(data.supplier.companyID);
                    },
                  );
                },
              );
              builder.element(
                'cac:PostalAddress',
                nest: () {
                  builder.element(
                    'cbc:StreetName',
                    nest: data.supplier.address.streetName,
                  );
                  builder.element(
                    'cbc:BuildingNumber',
                    nest: data.supplier.address.buildingNumber,
                  );
                  builder.element(
                    'cbc:PlotIdentification',
                    nest: data.supplier.address.buildingNumber,
                  );
                  builder.element(
                    'cbc:CitySubdivisionName',
                    nest: data.supplier.address.citySubdivisionName,
                  );
                  builder.element(
                    'cbc:CityName',
                    nest: data.supplier.address.cityName,
                  );
                  builder.element(
                    'cbc:PostalZone',
                    nest: data.supplier.address.postalZone,
                  );
                  builder.element(
                    'cac:Country',
                    nest: () {
                      builder.element(
                        'cbc:IdentificationCode',
                        nest: data.supplier.address.countryCode,
                      );
                    },
                  );
                },
              );
              builder.element(
                'cac:PartyTaxScheme',
                nest: () {
                  builder.element(
                    'cbc:CompanyID',
                    nest: data.supplier.companyID,
                  );
                  builder.element(
                    'cac:TaxScheme',
                    nest: () {
                      builder.element('cbc:ID', nest: 'VAT');
                    },
                  );
                },
              );
              builder.element(
                'cac:PartyLegalEntity',
                nest: () {
                  builder.element(
                    'cbc:RegistrationName',
                    nest: data.supplier.registrationName,
                  );
                },
              );
            },
          );
        },
      );

      // Customer
      builder.element(
        'cac:AccountingCustomerParty',
        nest: () {
          builder.element(
            'cac:Party',
            nest: () {
              builder.element(
                'cac:PartyIdentification',
                nest: () {
                  builder.element(
                    'cbc:ID',
                    nest: () {
                      builder.attribute('schemeID', 'CRN');
                    },
                  );
                },
              );
              builder.element(
                'cac:PostalAddress',
                nest: () {
                  builder.element(
                    'cbc:StreetName',
                    nest: data.customer.address.streetName,
                  );
                  builder.element(
                    'cbc:BuildingNumber',
                    nest: data.customer.address.buildingNumber,
                  );
                  builder.element(
                    'cbc:CitySubdivisionName',
                    nest: data.customer.address.citySubdivisionName,
                  );
                  builder.element(
                    'cbc:CityName',
                    nest: data.customer.address.cityName,
                  );
                  builder.element(
                    'cbc:PostalZone',
                    nest: data.customer.address.postalZone,
                  );
                  builder.element(
                    'cac:Country',
                    nest: () {
                      builder.element(
                        'cbc:IdentificationCode',
                        nest: data.customer.address.countryCode,
                      );
                    },
                  );
                },
              );
              builder.element(
                'cac:PartyTaxScheme',
                nest: () {
                  builder.element(
                    'cbc:CompanyID',
                    nest: data.customer.companyID,
                  );
                  builder.element(
                    'cac:TaxScheme',
                    nest: () {
                      builder.element('cbc:ID', nest: 'VAT');
                    },
                  );
                },
              );
              builder.element(
                'cac:PartyLegalEntity',
                nest: () {
                  builder.element(
                    'cbc:RegistrationName',
                    nest: data.customer.registrationName,
                  );
                },
              );
            },
          );
        },
      );
      builder.element(
        'cac:Delivery',
        nest: () {
          builder.element('cbc:ActualDeliveryDate', nest: data.issueDate);
        },
      );

      // Totals
      builder.element(
        'cac:TaxTotal',
        nest: () {
          builder.element(
            'cbc:TaxAmount',
            nest: () {
              builder.attribute('currencyID', 'SAR');
              builder.text(data.taxAmount);
            },
          );
          builder.element(
            'cac:TaxSubtotal',
            nest: () {
              builder.element(
                'cbc:TaxableAmount',
                nest: () {
                  builder.attribute('currencyID', 'SAR');
                  builder.text(
                    double.parse(data.totalAmount) -
                        double.parse(data.taxAmount),
                  );
                },
              );
              builder.element(
                'cbc:TaxAmount',
                nest: () {
                  builder.attribute('currencyID', 'SAR');
                  builder.text(data.taxAmount);
                },
              );
              builder.element(
                'cac:TaxCategory',
                nest: () {
                  builder.element(
                    'cbc:ID',
                    nest: () {
                      builder.attribute('schemeAgencyID', '6');
                      builder.attribute('schemeID', 'UN/ECE 5305');
                      builder.text('S');
                    },
                  );
                  builder.element('cbc:Percent', nest: '15');
                  builder.element(
                    'cac:TaxScheme',
                    nest: () {
                      builder.element(
                        'cbc:ID',
                        nest: () {
                          builder.attribute('schemeAgencyID', '6');
                          builder.attribute('schemeID', 'UN/ECE 5153');
                          builder.text('VAT');
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
      builder.element(
        'cac:TaxTotal',
        nest: () {
          builder.element(
            'cbc:TaxAmount',
            nest: () {
              builder.attribute('currencyID', 'SAR');
              builder.text(data.taxAmount);
            },
          );
        },
      );

      builder.element(
        'cac:LegalMonetaryTotal',
        nest: () {
          double taxableAmount =
              double.parse(data.totalAmount) - double.parse(data.taxAmount);
          builder.element(
            'cbc:LineExtensionAmount',
            nest: () {
              builder.attribute('currencyID', 'SAR');
              builder.text(taxableAmount.toStringAsFixed(2));
            },
          );
          builder.element(
            'cbc:TaxExclusiveAmount',
            nest: () {
              builder.attribute('currencyID', 'SAR');
              builder.text(taxableAmount.toStringAsFixed(2));
            },
          );
          builder.element(
            'cbc:TaxInclusiveAmount',
            nest: () {
              builder.attribute('currencyID', 'SAR');
              builder.text(data.totalAmount);
            },
          );
          builder.element(
            'cbc:PrepaidAmount',
            nest: () {
              builder.attribute('currencyID', 'SAR');
              builder.text('0');
            },
          );
          builder.element(
            'cbc:PayableAmount',
            nest: () {
              builder.attribute('currencyID', 'SAR');
              builder.text(data.totalAmount);
            },
          );
        },
      );

      // Invoice Lines
      for (var line in data.invoiceLines) {
        builder.element(
          'cac:InvoiceLine',
          nest: () {
            builder.element('cbc:ID', nest: line.id);
            builder.element(
              'cbc:InvoicedQuantity',
              nest: () {
                builder.attribute('unitCode', line.unitCode);
                builder.text(line.quantity);
              },
            );
            builder.element(
              'cbc:LineExtensionAmount',
              nest: () {
                builder.attribute('currencyID', 'SAR');
                builder.text(line.lineExtensionAmount);
              },
            );
            builder.element(
              'cac:TaxTotal',
              nest: () {
                double taxAmount =
                    (double.parse(line.lineExtensionAmount) *
                        double.parse(line.taxPercent) /
                        100);
                builder.element(
                  'cbc:TaxAmount',
                  nest: () {
                    builder.attribute('currencyID', 'SAR');
                    builder.text(taxAmount.toStringAsFixed(2));
                  },
                );
                double roundingAmopunt =
                    double.parse(line.lineExtensionAmount) + taxAmount;
                builder.element(
                  'cbc:RoundingAmount',
                  nest: () {
                    builder.attribute('currencyID', 'SAR');
                    builder.text(roundingAmopunt.toStringAsFixed(2));
                  },
                );
              },
            );
            builder.element(
              'cac:Item',
              nest: () {
                builder.element('cbc:Name', nest: line.itemName);
                builder.element(
                  'cac:ClassifiedTaxCategory',
                  nest: () {
                    builder.element('cbc:ID', nest: 'S');
                    builder.element('cbc:Percent', nest: line.taxPercent);
                    builder.element(
                      'cac:TaxScheme',
                      nest: () {
                        builder.element('cbc:ID', nest: 'VAT');
                      },
                    );
                  },
                );
              },
            );
            builder.element(
              'cac:Price',
              nest: () {
                builder.element(
                  'cbc:PriceAmount',
                  nest: () {
                    builder.attribute('currencyID', 'SAR');
                    builder.text(line.lineExtensionAmount);
                  },
                );
              },
            );
          },
        );
      }
    },
  );

  final document = builder.buildDocument();
  return document.toXmlString(pretty: true);
}
