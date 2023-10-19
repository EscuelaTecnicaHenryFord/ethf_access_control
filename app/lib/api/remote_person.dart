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
  final List<String> events;
  final PersonType type;

  RemotePerson({
    required this.id,
    required this.name,
    required this.username,
    required this.dni,
    required this.invitedBy,
    required this.cuilPrefix,
    required this.cuilSufix,
    this.events = const [],
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
      return 'staff';
    } else if (type == PersonType.student) {
      return 'estudiante';
    } else if (type == PersonType.parent) {
      return 'padre o madre';
    } else if (type == PersonType.guest) {
      return 'visitante';
    } else if (type == PersonType.formerStudent) {
      return 'exalumno';
    } else {
      return 'desconocido';
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
      events: json['events'] != null ? List<String>.from(json['events']) : [],
      type: type,
    );
  }

  dynamic toJSON() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'dni': dni,
      'invited_by': invitedBy,
      'cuil_prefix': cuilPrefix,
      'cuil_sufix': cuilSufix,
      'events': events,
      'type': type.toString(),
    };
  }
}
