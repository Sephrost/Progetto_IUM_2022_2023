import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';

import '../controllers/login_controller.dart';
import '../widgets/main_page.dart';
import 'material_page_route_alt.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(child: _FormContent()),
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  static final _usernameController = TextEditingController();
  static final _passwordController = TextEditingController();
  static final _formKey = GlobalKey<FormState>();

  const _FormContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    return (MediaQuery.of(context).orientation == Orientation.portrait)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.11,
                child: const SizedBox(),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Private Lesson Booker',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Inserire Email';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Inserire Password';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await context.read<LoginController>().login(
                                      _usernameController.text,
                                      _passwordController.text);
                                  if (!mounted) return;
                                  if (context.read<LoginController>().status ==
                                      AutehticationStatus.authenticated) {
                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(AltSnackbar(
                                      type: AltSnackbarType.success,
                                      text: "Login Effettuato",
                                    ));
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRouteAlt(
                                        builder: (context) => const MainPage(),
                                        fromDirection: AxisDirection.right,
                                        transitionDuration:
                                            const Duration(milliseconds: 350),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(AltSnackbar(
                                      type: AltSnackbarType.error,
                                      text: "Login Fallito, riprova",
                                    ));
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize:
                                    Size(MediaQuery.of(context).size.width, 50),
                              ),
                              child: const Text('Login'),
                            ),
                          ),
                        ],
                      ))),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Non sei un\'utente? Registrati'),
                      ),
                      Center(
                        child: Text(
                          'oppure',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await context.read<LoginController>().loginAsGuest();
                          if (!mounted) return;
                          if (context.read<LoginController>().status ==
                              AutehticationStatus.guest) {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(AltSnackbar(
                              type: AltSnackbarType.success,
                              text: "Accesso effettuato come ospite",
                            ));
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRouteAlt(
                                builder: (context) => const MainPage(),
                                fromDirection: AxisDirection.right,
                                transitionDuration:
                                    const Duration(milliseconds: 350),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(AltSnackbar(
                              type: AltSnackbarType.error,
                              text: "Ops, qualcosa è andato storto, riprova",
                            ));
                          }
                        },
                        child: const Text('Accedi come ospite'),
                      ),
                    ],
                  ))
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Private Lesson Booker',
                        style: TextStyle(fontSize: 30),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserire Username';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserire Password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await context.read<LoginController>().login(
                                  _usernameController.text,
                                  _passwordController.text);
                              if (!mounted) return;
                              if (context.read<LoginController>().status ==
                                  AutehticationStatus.authenticated) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(AltSnackbar(
                                  type: AltSnackbarType.success,
                                  text: "Login Effettuato",
                                ));
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRouteAlt(
                                    builder: (context) => const MainPage(),
                                    fromDirection: AxisDirection.right,
                                    transitionDuration:
                                        const Duration(milliseconds: 350),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(AltSnackbar(
                                  type: AltSnackbarType.error,
                                  text: "Login Fallito, riprova",
                                ));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.5, 50),
                          ),
                          child: const Text('Login'),
                        ),
                      ),
                    ],
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Non Sei un'utente?",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Registrati'),
                  ),
                  Center(
                    child: Text(
                      'oppure',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await context.read<LoginController>().loginAsGuest();
                      if (!mounted) return;
                      if (context.read<LoginController>().status ==
                          AutehticationStatus.guest) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(AltSnackbar(
                          type: AltSnackbarType.success,
                          text: "Accesso effettuato come ospite",
                        ));
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRouteAlt(
                            builder: (context) => const MainPage(),
                            fromDirection: AxisDirection.right,
                            transitionDuration:
                                const Duration(milliseconds: 350),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(AltSnackbar(
                          type: AltSnackbarType.error,
                          text: "Ops, qualcosa è andato storto, riprova",
                        ));
                      }
                    },
                    child: const Text('Accedi come ospite'),
                  ),
                ],
              )
            ],
          );
  }
}
