import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import 'package:zatca/models/invoice_data_model.dart';

///     Generate a ZATCA-compliant XML string for the invoice data.
XmlDocument generateZATCAXml(ZatcaInvoice data) {
  final builder = XmlBuilder();
  final formatter = NumberFormat("#.##");
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
      // builder.element(
      //   'cbc:Note',
      //   nest: () {
      //     builder.attribute('languageID', 'ar');
      //     builder.text(data.note);
      //   },
      // );
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
                      builder.text(data.supplier.companyCRN);
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
                      builder.text('');
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
              builder.text(data.taxAmount.toStringAsFixed(2));
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
                    formatter.format(data.totalAmount - data.taxAmount),
                  );
                },
              );
              builder.element(
                'cbc:TaxAmount',
                nest: () {
                  builder.attribute('currencyID', 'SAR');
                  builder.text(formatter.format(data.taxAmount));
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
              builder.text(data.taxAmount.toStringAsFixed(2));
            },
          );
        },
      );

      builder.element(
        'cac:LegalMonetaryTotal',
        nest: () {
          double taxableAmount = data.totalAmount - data.taxAmount;
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
              builder.text(formatter.format(taxableAmount));
            },
          );
          builder.element(
            'cbc:TaxInclusiveAmount',
            nest: () {
              builder.attribute('currencyID', 'SAR');
              builder.text(data.totalAmount.toStringAsFixed(2));
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
              builder.text(data.totalAmount.toStringAsFixed(2));
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
                builder.text(line.lineExtensionAmount.toStringAsFixed(2));
              },
            );
            builder.element(
              'cac:TaxTotal',
              nest: () {
                double taxAmount =
                    (line.lineExtensionAmount * line.taxPercent / 100);
                builder.element(
                  'cbc:TaxAmount',
                  nest: () {
                    builder.attribute('currencyID', 'SAR');
                    builder.text(taxAmount.toStringAsFixed(2));
                  },
                );
                double roundingAmount = line.lineExtensionAmount + taxAmount;
                builder.element(
                  'cbc:RoundingAmount',
                  nest: () {
                    builder.attribute('currencyID', 'SAR');
                    builder.text(roundingAmount.toStringAsFixed(2));
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
                    builder.element(
                      'cbc:Percent',
                      nest: formatter.format(line.taxPercent),
                    );
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
                    builder.text(line.lineExtensionAmount.toStringAsFixed(14));
                  },
                );
              },
            );
          },
        );
      }
    },
  );

  /// Build the XML document
  final document = builder.buildDocument();

  return document;
}

///     Generate a ZATCA-compliant UBLExtensions XML string for the invoice data.
XmlDocument generateUBLSignExtensionsXml({
  required String invoiceHash,
  required String signedPropertiesHash,
  required String digitalSignature,
  required String certificateString,
  required XmlDocument ublSignatureSignedPropertiesXML,
}) {
  final builder = XmlBuilder();
  builder.element(
    'ext:UBLExtensions',
    nest: () {
      builder.element(
        'ext:UBLExtension',
        nest: () {
          builder.element(
            'ext:ExtensionURI',
            nest: 'urn:oasis:names:specification:ubl:dsig:enveloped:xades',
          );
          builder.element(
            'ext:ExtensionContent',
            nest: () {
              builder.element(
                'sig:UBLDocumentSignatures',
                nest: () {
                  builder.attribute(
                    'xmlns:sac',
                    'urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2',
                  );
                  builder.attribute(
                    'xmlns:sbc',
                    'urn:oasis:names:specification:ubl:schema:xsd:SignatureBasicComponents-2',
                  );
                  builder.attribute(
                    'xmlns:sig',
                    'urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2',
                  );
                  builder.element(
                    'sac:SignatureInformation',
                    nest: () {
                      builder.element(
                        'cbc:ID',
                        nest: 'urn:oasis:names:specification:ubl:signature:1',
                      );
                      builder.element(
                        'sbc:ReferencedSignatureID',
                        nest:
                            'urn:oasis:names:specification:ubl:signature:Invoice',
                      );
                      builder.element(
                        'ds:Signature',
                        nest: () {
                          builder.attribute('Id', 'signature');
                          builder.attribute(
                            'xmlns:ds',
                            'http://www.w3.org/2000/09/xmldsig#',
                          );
                          builder.element(
                            'ds:SignedInfo',
                            nest: () {
                              builder.element(
                                'ds:CanonicalizationMethod',
                                nest: () {
                                  builder.attribute(
                                    'Algorithm',
                                    'http://www.w3.org/2006/12/xml-c14n11',
                                  );
                                  builder.text('');
                                },
                              );
                              builder.element(
                                'ds:SignatureMethod',
                                nest: () {
                                  builder.attribute(
                                    'Algorithm',
                                    'http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256',
                                  );
                                  builder.text('');
                                },
                              );
                              builder.element(
                                'ds:Reference',
                                nest: () {
                                  builder.attribute('Id', 'invoiceSignedData');
                                  builder.attribute('URI', '');
                                  builder.element(
                                    'ds:Transforms',
                                    nest: () {
                                      builder.element(
                                        'ds:Transform',
                                        nest: () {
                                          builder.attribute(
                                            'Algorithm',
                                            'http://www.w3.org/TR/1999/REC-xpath-19991116',
                                          );
                                          builder.element(
                                            'ds:XPath',
                                            nest:
                                                'not(//ancestor-or-self::ext:UBLExtensions)',
                                          );
                                        },
                                      );
                                      builder.element(
                                        'ds:Transform',
                                        nest: () {
                                          builder.attribute(
                                            'Algorithm',
                                            'http://www.w3.org/TR/1999/REC-xpath-19991116',
                                          );
                                          builder.element(
                                            'ds:XPath',
                                            nest:
                                                'not(//ancestor-or-self::cac:Signature)',
                                          );
                                        },
                                      );
                                      builder.element(
                                        'ds:Transform',
                                        nest: () {
                                          builder.attribute(
                                            'Algorithm',
                                            'http://www.w3.org/TR/1999/REC-xpath-19991116',
                                          );
                                          builder.element(
                                            'ds:XPath',
                                            nest:
                                                'not(//ancestor-or-self::cac:AdditionalDocumentReference[cbc:ID=\'QR\'])',
                                          );
                                        },
                                      );
                                      builder.element(
                                        'ds:Transform',
                                        nest: () {
                                          builder.attribute(
                                            'Algorithm',
                                            'http://www.w3.org/2006/12/xml-c14n11',
                                          );
                                          builder.text('');
                                        },
                                      );
                                    },
                                  );
                                  builder.element(
                                    'ds:DigestMethod',
                                    nest: () {
                                      builder.attribute(
                                        'Algorithm',
                                        'http://www.w3.org/2001/04/xmlenc#sha256',
                                      );
                                      builder.text('');
                                    },
                                  );
                                  builder.element(
                                    'ds:DigestValue',
                                    nest: invoiceHash,
                                  );
                                },
                              );
                              builder.element(
                                'ds:Reference',
                                nest: () {
                                  builder.attribute(
                                    'Type',
                                    'http://www.w3.org/2000/09/xmldsig#SignatureProperties',
                                  );
                                  builder.attribute(
                                    'URI',
                                    '#xadesSignedProperties',
                                  );
                                  builder.element(
                                    'ds:DigestMethod',
                                    nest: () {
                                      builder.attribute(
                                        'Algorithm',
                                        'http://www.w3.org/2001/04/xmlenc#sha256',
                                      );
                                      builder.text('');
                                    },
                                  );
                                  builder.element(
                                    'ds:DigestValue',
                                    nest: signedPropertiesHash,
                                  );
                                },
                              );
                            },
                          );
                          builder.element(
                            'ds:SignatureValue',
                            nest: digitalSignature,
                          );
                          builder.element(
                            'ds:KeyInfo',
                            nest: () {
                              builder.element(
                                'ds:X509Data',
                                nest: () {
                                  builder.element(
                                    'ds:X509Certificate',
                                    nest: certificateString,
                                  );
                                },
                              );
                            },
                          );
                          builder.element(
                            'ds:Object-1',
                          );
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
    },
  );

  return builder.buildDocument();
}

/// Generates the default  xades:SignedProperties XML template.
XmlDocument defaultUBLExtensionsSignedPropertiesForSigning({
  required String signingTime,
  required String certificateHash,
  required String certificateIssuer,
  required String certificateSerialNumber,
}) {
  final builder = XmlBuilder();
  builder.element(
    'xades:SignedProperties',
    nest: () {
      builder.attribute('xmlns:xades', 'http://uri.etsi.org/01903/v1.3.2#');
      builder.attribute('Id', 'xadesSignedProperties');

      builder.element(
        'xades:SignedSignatureProperties',
        nest: () {
          builder.element('xades:SigningTime', nest: signingTime);

          builder.element(
            'xades:SigningCertificate',
            nest: () {
              builder.element(
                'xades:Cert',
                nest: () {
                  builder.element(
                    'xades:CertDigest',
                    nest: () {
                      builder.element(
                        'ds:DigestMethod',
                        nest: () {
                          builder.attribute(
                            'xmlns:ds',
                            'http://www.w3.org/2000/09/xmldsig#',
                          );
                          builder.attribute(
                            'Algorithm',
                            'http://www.w3.org/2001/04/xmlenc#sha256',
                          );
                        },
                      );
                      builder.element(
                        'ds:DigestValue',
                        nest: () {
                          builder.attribute(
                            'xmlns:ds',
                            'http://www.w3.org/2000/09/xmldsig#',
                          );
                          builder.text(certificateHash);
                        },
                      );
                    },
                  );

                  builder.element(
                    'xades:IssuerSerial',
                    nest: () {
                      builder.element(
                        'ds:X509IssuerName',
                        nest: () {
                          builder.attribute(
                            'xmlns:ds',
                            'http://www.w3.org/2000/09/xmldsig#',
                          );
                          builder.text(certificateIssuer);
                        },
                      );
                      builder.element(
                        'ds:X509SerialNumber',
                        nest: () {
                          builder.attribute(
                            'xmlns:ds',
                            'http://www.w3.org/2000/09/xmldsig#',
                          );
                          builder.text(certificateSerialNumber);
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
    },
  );
  return builder.buildDocument();
}

/// Generates the `<xades:SignedProperties>` XML structure after signed.
XmlDocument defaultUBLExtensionsSignedProperties({
  required String signingTime,
  required String certificateHash,
  required String certificateIssuer,
  required String certificateSerialNumber,
}) {
  final builder = XmlBuilder();
  builder.element(
    'xades:QualifyingProperties',
    attributes: {
      'Target': 'signature',
      'xmlns:xades': 'http://uri.etsi.org/01903/v1.3.2#',
    },
    nest: () {
      builder.element(
        'xades:SignedProperties',
        nest: () {
          builder.attribute('xmlns:xades', 'http://uri.etsi.org/01903/v1.3.2#');
          builder.attribute('Id', 'xadesSignedProperties');

          builder.element(
            'xades:SignedSignatureProperties',
            nest: () {
              builder.element('xades:SigningTime', nest: signingTime);

              builder.element(
                'xades:SigningCertificate',
                nest: () {
                  builder.element(
                    'xades:Cert',
                    nest: () {
                      builder.element(
                        'xades:CertDigest',
                        nest: () {
                          builder.element(
                            'ds:DigestMethod',
                            nest: () {
                              builder.attribute(
                                'Algorithm',
                                'http://www.w3.org/2001/04/xmlenc#sha256',
                              );
                              builder.text('');
                            },
                          );
                          builder.element(
                            'ds:DigestValue',
                            nest: certificateHash,
                          );
                        },
                      );

                      builder.element(
                        'xades:IssuerSerial',
                        nest: () {
                          builder.element(
                            'ds:X509IssuerName',
                            nest: certificateIssuer,
                          );
                          builder.element(
                            'ds:X509SerialNumber',
                            nest: certificateSerialNumber,
                          );
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
    },
  );

  return builder.buildDocument();
}

XmlDocument generateQrAndSignatureXMl({required String qrString}) {
  final builder = XmlBuilder();
  builder.element(
    'cac:AdditionalDocumentReference',
    nest: () {
      builder.element('cbc:ID', nest: 'QR');
      builder.element(
        'cac:Attachment',
        nest: () {
          builder.element(
            'cbc:EmbeddedDocumentBinaryObject',
            nest: qrString,
            attributes: {'mimeCode': 'text/plain'},
          );
        },
      );
    },
  );
  builder.element(
    'cac:Signature',
    nest: () {
      builder.element(
        'cbc:ID',
        nest: 'urn:oasis:names:specification:ubl:signature:Invoice',
      );
      builder.element(
        'cbc:SignatureMethod',
        nest: "urn:oasis:names:specification:ubl:dsig:enveloped:xades",
      );
    },
  );

  return builder.buildDocument();
}

String canonicalizeXml(String xmlString) {
  final document = XmlDocument.parse(xmlString);

  // Recursively sort attributes and format the nodes
  String normalizeNode(XmlNode node) {
    if (node is XmlElement) {
      final sortedAttributes =
          node.attributes.toList()
            ..sort((a, b) => a.name.toString().compareTo(b.name.toString()));

      final buffer = StringBuffer();
      buffer.write('<${node.name}');

      for (var attr in sortedAttributes) {
        buffer.write(' ${attr.name}="${attr.value}"');
      }

      buffer.write('>');

      for (var child in node.children) {
        buffer.write(normalizeNode(child));
      }

      buffer.write('</${node.name}>');
      return buffer.toString();
    } else if (node is XmlText) {
      return node.text;
    } else if (node is XmlProcessing) {
      // Skip XML declaration
      return '';
    } else {
      return node.toXmlString();
    }
  }

  final normalizedXml = normalizeNode(document.rootElement);
  return normalizedXml;
}
