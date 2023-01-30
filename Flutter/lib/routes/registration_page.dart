import 'package:flutter/material.dart';
import 'package:flutter_app/database/db_controller.dart';
import 'package:flutter_app/models/registration_user.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_app/widgets/snackbar.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final WebViewController controller = WebViewController()
    ..addJavaScriptChannel('Registration', onMessageReceived: (message) {
      _validateRegistration(message);
    })
    ..loadFlutterAsset('assets/html/index.html')
    ..setJavaScriptMode(JavaScriptMode.unrestricted);

  int loadingPercentage = 0;
  static late BuildContext buildContext;

  void _onProgressChanged(int progress) {
    setState(() {
      loadingPercentage = progress;
    });
  }

  static Future<bool> _validateRegistration(JavaScriptMessage message) async {
    String separator = String.fromCharCode(960);

    String mail = message.message.split(separator)[0];
    String password = message.message.split(separator)[1];
    String confirmPassword = message.message.split(separator)[2];
    String nickname = message.message.split(separator)[3];
    String name = message.message.split(separator)[4];
    String surname = message.message.split(separator)[5];
    String phone = message.message.split(separator)[6];
    String imagePath = message.message.split(separator)[10];
    String address =
        "${message.message.split(separator)[7]}, ${message.message.split(separator)[9]} ${message.message.split(separator)[8]}";

    // check all fields are filled
    for (String field in message.message.split(separator)) {
      if (field.isEmpty) {
        ScaffoldMessenger.of(buildContext).removeCurrentSnackBar();
        ScaffoldMessenger.of(buildContext).showSnackBar(AltSnackbar(
            type: AltSnackbarType.info,
            text: "Compilare tutti i campi per continuare"));
        return false;
      }
    }

    // email check
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(mail)) {
      ScaffoldMessenger.of(buildContext).removeCurrentSnackBar();
      ScaffoldMessenger.of(buildContext).showSnackBar(
          AltSnackbar(type: AltSnackbarType.error, text: "Email non Valida!"));
    }
    // password check
    else if (password.length < 8 || password.length > 16) {
      ScaffoldMessenger.of(buildContext).removeCurrentSnackBar();
      ScaffoldMessenger.of(buildContext).showSnackBar(AltSnackbar(
          type: AltSnackbarType.error, text: "Password non Valida!"));
    }
    // confirm password check
    else if (password != confirmPassword) {
      ScaffoldMessenger.of(buildContext).removeCurrentSnackBar();
      ScaffoldMessenger.of(buildContext).showSnackBar(AltSnackbar(
          type: AltSnackbarType.error, text: "Le Password non conincidono!"));
    } else {
      RegistrationUser user = RegistrationUser(
          email: mail,
          password: password,
          imagePath: imagePath,
          nickname: nickname,
          name: name,
          surname: surname,
          address: address,
          phone: phone);
      if (await DbController.db.register(user)) {
        ScaffoldMessenger.of(buildContext).removeCurrentSnackBar();
        Navigator.of(buildContext).pop();
        ScaffoldMessenger.of(buildContext).showSnackBar(AltSnackbar(
            type: AltSnackbarType.success, text: "Registrazione avvenuta!"));
        return true;
      } else {
        ScaffoldMessenger.of(buildContext).removeCurrentSnackBar();
        ScaffoldMessenger.of(buildContext).showSnackBar(AltSnackbar(
            type: AltSnackbarType.error, text: "Errore, email già in uso!"));
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return Scaffold(
        appBar: AppBar(title: const Text('Registrati'), actions: [
          IconButton(
              onPressed: () async {
                await controller.reload();
              },
              icon: const Icon(Icons.refresh))
        ]),
        body: Stack(children: [
          WebViewWidget(
              controller: controller
                ..setNavigationDelegate(
                    NavigationDelegate(onProgress: _onProgressChanged))),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100,
            )
        ]));
  }
}
