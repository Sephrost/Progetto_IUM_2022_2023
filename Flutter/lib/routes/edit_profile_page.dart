import 'package:flutter/material.dart';

import 'package:flutter_app/controllers/login_controller.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/widgets/profile_img.dart';
import 'package:flutter_app/widgets/textfield_widget.dart';
import 'package:flutter_app/database/db_controller.dart';
import 'package:flutter_app/widgets/snackbar.dart';

/// This page allows the user to edit their profile information.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        const SizedBox(
          height: 10,
        ),
        ProfileWidget(
          imagePath: LoginController.user.imagePath,
          onClicked: () {},
          status: "Edit",
        ),
        const SizedBox(
          height: 24,
        ),
        TextFieldWidget(
          label: 'Nick Name',
          text: LoginController.user.nickName ?? " ",
          onChanged: (nickName) => LoginController.user.nickName = nickName,
        ),
        const SizedBox(
          height: 24,
          child: Divider(),
        ),
        TextFieldWidget(
          label: 'Nome completo',
          text: LoginController.user.fullName,
          onChanged: (fullName) => LoginController.user.fullName = fullName,
        ),
        const SizedBox(
          height: 24,
          child: Divider(),
        ),
        TextFieldWidget(
          label: 'Indirizzo',
          text: LoginController.user.address,
          onChanged: (address) => LoginController.user.address = address,
        ),
        const SizedBox(
          height: 24,
          child: Divider(),
        ),
        TextFieldWidget(
          label: 'Telefono',
          text: LoginController.user.phone,
          onChanged: (phone) => LoginController.user.phone = phone,
        ),
        const SizedBox(
          height: 24,
        ),
        //raw with save and cancel button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(AltSnackbar(
                    type: AltSnackbarType.info, text: "Modifiche Annullate"));
              },
              label: const Text('Annulla'),
              icon: const Icon(Icons.cancel),
            ),
            const SizedBox(
              width: 24,
            ),
            ElevatedButton.icon(
              // update the user object in the database and show a snackbar
              onPressed: () {
                Navigator.of(context).pop();
                DbController.db.updateUser(toJson(LoginController.user));
                //show snackbar
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(AltSnackbar(
                    type: AltSnackbarType.success, text: "Modifiche Salvate!"));
              },
              label: const Text('Salva'),
              icon: const Icon(Icons.save),
            ),
          ],
        ),
      ],
    );
  }
}
