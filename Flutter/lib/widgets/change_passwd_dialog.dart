// dialog for change user password

import 'package:flutter/material.dart';
import 'package:flutter_app/database/db_controller.dart';
import 'package:flutter_app/controllers/login_controller.dart';
import 'package:flutter_app/widgets/snackbar.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          const Text(
            'Cambia Password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password attuale',
              ),
              controller: oldPassController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 18, 10, 3),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nuova Password',
              ),
              controller: newPassController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 18, 10, 3),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Conferma Nuova Password',
              ),
              controller: confirmPassController,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () async {
                  //sanity check for sql injection
                  if (oldPassController.text.contains("'") ||
                      newPassController.text.contains("'") ||
                      confirmPassController.text.contains("'")) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      AltSnackbar(
                        text: 'Password non valida',
                        type: AltSnackbarType.error,
                      ),
                    );
                    return;
                  }
                  if (newPassController.text == confirmPassController.text) {
                    if (await DbController.db.checkPassword(
                        LoginController.user.email, oldPassController.text)) {
                      if (await DbController.db.changePassword(
                          LoginController.user.email, newPassController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          AltSnackbar(
                            text: 'Password cambiata con successo!',
                            type: AltSnackbarType.success,
                          ),
                          // close the dialog
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(AltSnackbar(
                            type: AltSnackbarType.warning,
                            text:
                                "Password Invalide, evitare l'uso dell'apostrofo!"));
                      }
                    } else {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(AltSnackbar(
                          type: AltSnackbarType.error,
                          text: "Password Errata!"));
                    }
                  } else {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(AltSnackbar(
                        type: AltSnackbarType.warning,
                        text: "Le nuove password non coincidono!"));
                  }
                },
                child: const Text('Conferma'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
