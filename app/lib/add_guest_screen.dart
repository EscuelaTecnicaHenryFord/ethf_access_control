import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/api/remote_person.dart';
import 'package:ethf_access_control_app/person_info.dart';
import 'package:ethf_access_control_app/scan_dni_dialog.dart';
import 'package:ethf_access_control_app/search.dart';
import 'package:flutter/material.dart';

class AddGuestScreen extends StatefulWidget {
  const AddGuestScreen({super.key, this.personInfo, this.registerNow = false});

  final PersonInfo? personInfo;
  final bool registerNow;

  @override
  State<AddGuestScreen> createState() => _AddGuestScreenState();
}

class _AddGuestScreenState extends State<AddGuestScreen> {
  Widget padding(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: child,
    );
  }

  InputDecoration decoration(String label, {void Function(PersonInfo)? onScanned}) {
    return InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white12,
        suffixIcon: onScanned != null
            ? IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () {
                  showScanDniDialog(context).then((value) {
                    if (value != null) {
                      onScanned(value);
                    }
                  });
                },
              )
            : null);
  }

  final firstNameControler = TextEditingController();
  final lastNameControler = TextEditingController();
  final dniController = TextEditingController();
  final invitedBy = TextEditingController();

  bool registerNow = true;

  @override
  void initState() {
    firstNameControler.text = widget.personInfo?.firstName ?? "";
    lastNameControler.text = widget.personInfo?.lastName ?? "";
    dniController.text = widget.personInfo?.dni.toString() ?? "";
    invitedBy.text = "";
    setState(() {
      registerNow = widget.registerNow;
    });
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  void send() {
    final firstName = firstNameControler.text;
    final lastName = lastNameControler.text;
    final dni = dniController.text;
    final invitedBy = this.invitedBy.text;

    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregando invitado')),
      );

      setState(() {
        loading = true;
      });

      final data = {
        'first_name': firstName,
        'last_name': lastName,
        'dni': dni,
        'invited_by': invitedBy,
      };

      AppApi.instance.postAddGuest(data).then((value) {
        if (registerNow) {
          AppApi.instance.postHistory(dni, data);
        }

        Navigator.of(context).pop(true);
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );

        setState(() {
          loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar invitado'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            const Spacer(),
            ElevatedButton.icon(onPressed: send, icon: Icon(Icons.save), label: Text("Guardar"))
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            padding(TextFormField(
              decoration: decoration("Nombre"),
              controller: firstNameControler,
              validator: (value) => (value == null || value.isEmpty) ? "El nombre es requerido" : null,
            )),
            padding(TextFormField(
              decoration: decoration("Apellido"),
              controller: lastNameControler,
              validator: (value) => (value == null || value.isEmpty) ? "El apellido es requerido" : null,
            )),
            padding(TextFormField(
              keyboardType: TextInputType.number,
              decoration: decoration(
                "DNI",
                onScanned: (person) {
                  firstNameControler.text = person.firstName;
                  lastNameControler.text = person.lastName;
                  dniController.text = person.dni.toString();
                },
              ),
              controller: dniController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "El DNI es requerido";
                }

                final asInt = int.tryParse(value);

                if (asInt == null) {
                  return "El DNI debe ser un número";
                }

                if (asInt > 99999999 || asInt < 1000000) {
                  return "El DNI es inválido";
                }
                return null;
              },
            )),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Checkbox(
                      value: registerNow,
                      onChanged: (value) {
                        setState(() {
                          registerNow = value ?? false;
                        });
                      }),
                  const Text("Registrar ingreso ahora"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 12),
              child: Text(
                "Invitado por",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            padding(TextFormField(
              decoration: decoration("DNI / usuario / matrícula"),
              controller: invitedBy,
              validator: (value) => (value == null || value.isEmpty) ? "Invitado por requesrido" : null,
            )),
            padding(
              ElevatedButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: GlobalSearch(onResultTap: (person) {
                      if ((person.type == PersonType.staff ||
                          person.type == PersonType.student && person.username == null)) {
                        invitedBy.text = person.username!;
                      } else {
                        invitedBy.text = person.id;
                      }
                    }),
                  );
                },
                child: const Text("Buscar persona"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
