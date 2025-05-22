
import '../resources/cirtificate/templates/csr_template.dart';
import 'address.dart';

class EGSUnitInfo {
  final String uuid;
  final String taxpayerProvidedId;
  final String model;
  final String crnNumber;
  final String taxpayerName;
  final String vatNumber;
  final String branchName;
  final String branchIndustry;
  final Location location;



  EGSUnitInfo({
    required this.uuid,
    required this.taxpayerProvidedId,
    required this.model,
    required this.crnNumber,
    required this.taxpayerName,
    required this.vatNumber,
    required this.branchName,
    required this.branchIndustry,
    required this.location

  });

  toCsrProps(String solutionName) {
    return CSRConfigProps(
        egsModel: model,
        egsSerialNumber: uuid,
        solutionName: solutionName,
        vatNumber: vatNumber,
        branchLocation: location.branchLocation??'',
        branchIndustry: branchIndustry,
        branchName: branchName,
        taxpayerName: taxpayerName,
        taxpayerProvidedId: taxpayerProvidedId
    );
  }
}



