//setting page
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/controllers/login_controller.dart';
import 'package:flutter_app/widgets/change_passwd_dialog.dart';
import 'package:flutter_app/themes/themes.dart';

import 'package:settings_ui/settings_ui.dart';

// This page allows the user to change various settings for the app.
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  get onPressed => null;

  @override
  Widget build(BuildContext context) {
    // The body is a list, divided into sections (groups of settings)
    // The SettingsTile represents the various entries in the settings
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: SettingsList(physics: const BouncingScrollPhysics(), sections: [
        SettingsSection(title: const Text('Generali'), tiles: <SettingsTile>[
          SettingsTile.switchTile(
            title: const Text("Tema"),
            //chage icon based on current theme
            leading: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
            initialValue: Theme.of(context).brightness == Brightness.dark,
            // wrap the provider method to change the theme
            onToggle: (bool value) {
              context.read<ThemeChangerProvider>().toggleTheme();
            },
          ),
        ]),
        SettingsSection(title: const Text('Profilo'), tiles: <SettingsTile>[
          SettingsTile(
              title: const Text('Cambia password'),
              leading: const Icon(Icons.lock),
              onPressed: (BuildContext context) {
                LoginController().status == AutehticationStatus.authenticated
                    ? showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            const ChangePasswordDialog())
                    : ScaffoldMessenger.of(context).showSnackBar(AltSnackbar(
                        type: AltSnackbarType.warning,
                        text: "Guest non può cambiare password"));
              }),
        ]),
        //credis
        SettingsSection(title: const Text("Crediti"), tiles: <SettingsTile>[
          SettingsTile(
            title: const Text('Sviluppatori'),
            leading: const Icon(Icons.developer_mode),
            //show a dialog with the developers' names
            onPressed: (BuildContext context) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      title: Text('Sviluppatori'),
                      content: Text('''
                          Alessandro Milani 
                          Fabio Lorenzato'''),
                    );
                  });
            },
          ),
          SettingsTile(
              title: const Text('Librerie utilizzate'),
              leading: const Icon(Icons.library_books),
              //On pressed show dialog with libraries names
              onPressed: (BuildContext context) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                        title: Text('Librarie'),
                        content: Text(''' 
                          Material
                          Provider
                          Settings UI
                          Shared Preferences
                          Sqflite
                          Intl
                          Circular Progress Bar
                          Flutter Launcher Icons
                          Webview Flutter
                          '''),
                      );
                    });
              }),
        ]),
        SettingsSection(title: const Text('Logout'), tiles: <SettingsTile>[
          SettingsTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onPressed: (BuildContext context) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Sei sicuro di voler uscire?'),
                        actions: [
                          TextButton(
                            child: const Text('Conferma'),
                            onPressed: () {
                              context.read<LoginController>().logout();
                              Navigator.of(context, rootNavigator: true)
                                  .pushNamedAndRemoveUntil('/login',
                                      (Route<dynamic> route) => false);
                            },
                          ),
                          TextButton(
                            child: const Text('Annulla'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ]);
                  });
            },
          ),
        ]),
      ]),
    );
  }
}
