import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The onboarding page, it is the first page that the user sees when he opens
/// the app, and it is shown only once.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final int _pageCount = 3;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: PageView(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: const [
                OnboardingPage(
                  index: 0,
                  color: Color(0xFF006D3C),
                  title: 'BENVENUTO',
                  imagePath: 'assets/images/onboarding_1.png',
                  subtitle: 'Benvenuto su Private Lesson Booker',
                ),
                OnboardingPage(
                  index: 1,
                  color: Color(0xff1b91fb),
                  imagePath: 'assets/images/onboarding_2.png',
                  title: 'CON CHI VUOI',
                  subtitle: 'Trova il docente piú adatto alle tue esigenze',
                ),
                OnboardingPage(
                  index: 2,
                  color: Color(0xff17183e),
                  imagePath: 'assets/images/onboarding_3.png',
                  title: 'DA DOVE VUOI',
                  subtitle: 'Effettua la ripetizione con te ovunque tu vada',
                ),
              ]),
        ),
        bottomSheet: SizedBox(
          height: 80,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: (_currentPage != _pageCount - 1)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        TextButton(
                          onPressed: () {
                            _pageController.animateToPage(
                              _pageCount - 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                          child: const Text('Salta'),
                        ),
                        Center(
                          // make a pege indicator
                          child: Row(
                            children: List.generate(
                              _pageCount,
                              (index) => GestureDetector(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentPage == index
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.5),
                                    ),
                                  ),
                                  onTap: () {
                                    _pageController.animateToPage(
                                      index,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeIn,
                                    );
                                  }),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_currentPage < _pageCount - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            } else {
                              // go to the next screen
                            }
                          },
                          child: Text('Prossimo',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .fontSize)),
                        )
                      ])
                : TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color.lerp(
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).bottomAppBarColor,
                          0.3)!,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                      minimumSize: const Size(double.infinity, 80),
                    ),
                    child: Center(
                      child: Text('Inizia',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize:
                                Theme.of(context).textTheme.headline2!.fontSize,
                          )),
                    ),
                    onPressed: () async {
                      var prefs = await SharedPreferences.getInstance();
                      prefs.setBool('firstBoot', false);
                      if (!mounted) return;
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
          ),
        ));
  }
}

class OnboardingPage extends StatelessWidget {
  final int index;
  final Color color;
  final String title;
  final String subtitle;
  final String imagePath;

  const OnboardingPage(
      {Key? key,
      required this.index,
      required this.color,
      required this.title,
      required this.imagePath,
      required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.lerp(color, Theme.of(context).bottomAppBarColor,
          Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.25)!,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            height: 44,
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.headline3!.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyText1!.fontSize,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}
