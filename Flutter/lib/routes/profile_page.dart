import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/login_controller.dart';
import 'package:flutter_app/routes/edit_profile_page.dart';
import 'package:flutter_app/routes/setting_page.dart';
import 'package:flutter_app/widgets/profile_row.dart';
import 'package:flutter_app/widgets/profile_img.dart';
import 'package:flutter_app/widgets/profile_data.dart';

/// The page that shows the user's profile information.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 40,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        primary: false,
        children: [
          const SizedBox(
            height: 10,
          ),
          ProfileWidget(
            imagePath: LoginController.user.imagePath,
            onClicked: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const EditProfilePage()),
              );
              setState(() {});
            },
            // if the user is a guest, show "Guest" as the status
            status: "Static",
          ),
          const SizedBox(height: 24),
          buildName(),
          const SizedBox(height: 24),
          const NumbersWidget(),
          buildAbout(),
          const SizedBox(height: 12),
          //space
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget buildName() => Column(
        children: [
          Text(
            LoginController.user.nickName ?? LoginController.user.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            LoginController.user.email,
            style: TextStyle(color: Theme.of(context).hintColor),
          )
        ],
      );

  Widget buildAbout() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 24,
            ),
            ProfileData(
                dataName: "Nome Completo", data: LoginController.user.fullName),
            const SizedBox(
              height: 24,
              child: Divider(),
            ),
            ProfileData(
                dataName: "Indirizzo", data: LoginController.user.address),
            const SizedBox(
              height: 24,
              child: Divider(),
            ),
            ProfileData(dataName: "Telefono", data: LoginController.user.phone),
          ],
        ),
      );
}
