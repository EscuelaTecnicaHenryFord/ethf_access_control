enum PersonType {
  staff,
  student,
  parent,
  guest,
  formerStudent,
}

class RemotePerson {
  final String id;
  final String name;
  final String? username;
  final int? dni;
  final String? invitedBy;
  final int? cuilPrefix;
  final int? cuilSufix;
  final PersonType type;

  RemotePerson({
    required this.id,
    required this.name,
    required this.username,
    required this.dni,
    required this.invitedBy,
    required this.cuilPrefix,
    required this.cuilSufix,
    required this.type,
  });

  bool get hasCuil => cuilPrefix != null && cuilSufix != null && cuilPrefix != 0 && cuilSufix != 0;
  bool get hasDni => dni != null && dni != 0;

  String get displayId {
    if (username != null) return username!;

    if (dni != null && ((cuilPrefix == null || cuilPrefix == 0) || ((cuilSufix == null || cuilSufix == 0)))) {
      return dni.toString().padLeft(8, '0');
    }

    if (dni != null) {
      return '$cuilPrefix-$dni-$cuilSufix';
    }

    throw Exception('Invalid person id missing username or dni');
  }

  String get displayCuil =>
      "${cuilPrefix.toString().padLeft(2, '0')}-${dni.toString().padLeft(8, '0')}-${cuilSufix.toString().padLeft(1, '0')}";

  String get typeName {
    if (type == PersonType.staff) {
      return 'Personal';
    } else if (type == PersonType.student) {
      return 'Estudiante';
    } else if (type == PersonType.parent) {
      return 'Padre o madre';
    } else if (type == PersonType.guest) {
      return 'Visitante';
    } else if (type == PersonType.formerStudent) {
      return 'Exalumno';
    } else {
      return 'Desconocido';
    }
  }

  // from json
  factory RemotePerson.fromJson(Map<String, dynamic> json) {
    PersonType type = PersonType.guest;

    if (json['type'] == 'student') {
      type = PersonType.student;
    } else if (json['type'] == 'staff') {
      type = PersonType.staff;
    } else if (json['type'] == 'parent') {
      type = PersonType.parent;
    } else if (json['type'] == 'former_student') {
      type = PersonType.formerStudent;
    }

    return RemotePerson(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      dni: json['dni'],
      invitedBy: json['invited_by'],
      cuilPrefix: json['cuil_prefix'],
      cuilSufix: json['cuil_sufix'],
      type: type,
    );
  }
}
