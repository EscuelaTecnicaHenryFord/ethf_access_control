import 'package:intl/intl.dart';

class PersonInfo {
  final String firstName;
  final String lastName;
  final String dni;
  final String? scannedString;

  PersonInfo({
    required this.firstName,
    required this.lastName,
    required this.dni,
    this.scannedString,
  });

  static PersonInfo parse(String scanned) {
    final regex =
        RegExp(r"^(?<id>\d{10,12})@(?<last_name>[^@]+)@(?<first_name>[^@]+)@[A-Z]@[FM]{0,1}(?<dni>\d{7,9})@.+@.+");

    var match = regex.firstMatch(scanned);

    if (match == null) {
      final altRegex =
          RegExp(r"^ *@{0,1}(?<dni>\d{7,9}) *@[^@]+@[^@]+@(?<last_name>[^@]+)@(?<first_name>[^@]+)@[A-Z]+@");
      match = altRegex.firstMatch(scanned);
    }

    if (match == null) {
      throw Exception("Invalid scanned data");
    }

    return PersonInfo(
      firstName: match.namedGroup('first_name')!,
      lastName: match.namedGroup('last_name')!,
      dni: match.namedGroup('dni')!,
      scannedString: scanned,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'dni': dni,
      'scanned_string': scannedString,
    };
  }

  String get displayName => toBeginningOfSentenceCase("$firstName $lastName")!;

  @override
  String toString() {
    return "$firstName $lastName,  $dni";
  }
}
