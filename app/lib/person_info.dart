import 'package:intl/intl.dart';

class PersonInfo {
  final String firstName;
  final String lastName;
  final String gender;
  final String dni;
  final DateTime dateOfBirth;
  final String cuilPrefixSufix;

  PersonInfo({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dni,
    required this.dateOfBirth,
    required this.cuilPrefixSufix,
  });

  static PersonInfo parse(String scanned) {
    final sections = scanned.split('@');

    final dateStrArr = sections[6].split('/');

    final day = dateStrArr[0];
    final month = dateStrArr[1];
    final year = dateStrArr[2];

    final date = DateTime.parse('$year-$month-$day');

    return PersonInfo(
      firstName: sections[2],
      lastName: sections[1],
      gender: sections[3],
      dni: sections[4],
      dateOfBirth: date,
      cuilPrefixSufix: sections[8],
    );
  }

  String get displayName => toBeginningOfSentenceCase("$firstName $lastName")!;

  String get cuil {
    final prefix = cuilPrefixSufix.substring(0, 2);
    final sufix = cuilPrefixSufix.substring(2);

    return "$prefix-$dni-$sufix";
  }

  @override
  String toString() {
    return "$firstName $lastName, $gender, $dni, $dateOfBirth";
  }
}
