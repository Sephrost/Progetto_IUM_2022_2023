// greets the user

import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/login_controller.dart';

class HomeGreet extends StatelessWidget {
  const HomeGreet({Key? key}) : super(key: key);

  Widget greet(String username, BuildContext context) {
    return Text(
      "Bentornato $username",
      style: TextStyle(
        fontSize: Theme.of(context).textTheme.headline5!.fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(15),
        child: greet(
            LoginController.user.nickName ?? LoginController.user.fullName,
            context));
  }
}
