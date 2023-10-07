import 'dart:math';

import 'package:ethf_access_control_app/person_info.dart';
import 'package:flutter/material.dart';

class PersonInfoCard extends StatefulWidget {
  const PersonInfoCard({
    super.key,
    required this.personInfo,
  });

  final PersonInfo personInfo;

  static const height = 110.0;

  @override
  State<PersonInfoCard> createState() => _PersonInfoCardState();
}

class _PersonInfoCardState extends State<PersonInfoCard> {
  bool? isRegistered;

  @override
  void initState() {
    final random = Random();
    super.initState();
    Future.delayed(const Duration(seconds: 2)).then((value) {
      if (!context.mounted) return;
      setState(() {
        isRegistered = random.nextDouble() >= 0.5;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isRegistered == null
          ? null
          : isRegistered!
              ? Colors.green
              : Colors.red,
      child: SizedBox(
        height: PersonInfoCard.height,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 30,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Icon(Icons.badge_outlined, size: 32),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.personInfo.displayName,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          widget.personInfo.cuil,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (isRegistered == true)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: IconButton(
                        icon: const Icon(Icons.done, size: 32),
                        onPressed: () {},
                      ),
                    ),
                  if (isRegistered == false)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 26),
                      child: IconButton(
                        icon: const Icon(Icons.person_add, size: 32),
                        onPressed: () {},
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 50,
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isRegistered == null)
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        ),
                      if (isRegistered == true)
                        Icon(Icons.info_outline, size: 16),
                      if (isRegistered == false) Icon(Icons.error, size: 16),
                      SizedBox(width: 6),
                      if (isRegistered == true)
                        Text(
                          "Invitado de HF1710 (Tomás Cichero)",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      if (isRegistered == false)
                        Text(
                          "La persona no está en la lista de invitados",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
