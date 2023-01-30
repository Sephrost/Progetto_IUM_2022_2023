import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/home_page_controller.dart';
import 'package:flutter_app/widgets/home_greet.dart';
import 'package:flutter_app/widgets/home_stats.dart';
import 'package:flutter_app/widgets/home_users_next.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ChangeNotifierProvider<HomePageController>(
          create: (context) => HomePageController(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  HomeGreet(),
                ],
              ),
              const HomeStats(),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Prossime Ripetizioni",
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headline6!.fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const HomeUsersNext()
            ],
          ),
        ),
      ),
    );
  }
}
