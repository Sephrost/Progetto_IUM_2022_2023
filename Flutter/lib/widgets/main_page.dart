import 'package:flutter/material.dart';
import 'package:flutter_app/routes/home_page.dart';
import 'package:flutter_app/widgets/cart_fab.dart';
// ignore: library_prefixes
import 'package:flutter_app/widgets/fab_bottom_bar.dart' as FabNavigationBar;
import '../routes/booker_page.dart';
import '../routes/history_page.dart';
import '../routes/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

// ignore: camel_case_types, constant_identifier_names
enum routes { HomePage, BookerPage, HistoryPage, ProfilePage }

class _MainPageState extends State<MainPage> {
  int _currentPageIndex = 0;
  final List<int> _pageStack = [0];

  final List _routeKeys =
      List.generate(routes.values.length, (index) => GlobalKey());

  void _onDestinationTapped(int index) {
    if (index == _pageStack.last) return;
    _pageStack.add(index);
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: WillPopScope(
              onWillPop: () async {
                final navigator =
                    _routeKeys[_pageStack.last].currentState! as NavigatorState;

                if (navigator.canPop()) {
                  // if there are pages on the pages stack of the navigator
                  navigator.pop();
                  return false;
                }

                if (_pageStack.isEmpty) return true;
                // remove the last element from the stack of lvroutes
                _pageStack.removeLast();
                if (_pageStack.isEmpty) return true;
                setState(() {
                  _currentPageIndex = _pageStack.last;
                });
                return false;
              },
              // For future reference: indexStacked is a widget that allows to
              // show a single child at a time from a list of children
              // keeping the state of each child
              child: IndexedStack(
                index: _currentPageIndex,
                children: [
                  Navigator(
                    key: _routeKeys[routes.HomePage.index],
                    onGenerateRoute: (routeSettings) {
                      return MaterialPageRoute(
                        settings: routeSettings,
                        builder: (context) => const HomePage(),
                      );
                    },
                  ),
                  Navigator(
                    key: _routeKeys[routes.BookerPage.index],
                    onGenerateRoute: (routeSettings) {
                      return MaterialPageRoute(
                        settings: routeSettings,
                        builder: (context) => const BookerPage(),
                      );
                    },
                  ),
                  Navigator(
                    key: _routeKeys[routes.HistoryPage.index],
                    onGenerateRoute: (routeSettings) {
                      return MaterialPageRoute(
                        settings: routeSettings,
                        builder: (context) => const HistoryPage(),
                      );
                    },
                  ),
                  Navigator(
                    key: _routeKeys[routes.ProfilePage.index],
                    onGenerateRoute: (routeSettings) {
                      return MaterialPageRoute(
                        settings: routeSettings,
                        builder: (context) => const ProfilePage(),
                      );
                    },
                  ),
                ],
              )),
        ),
        bottomNavigationBar: FabNavigationBar.FabNavigationBar(
          onDestinationSelected: _onDestinationTapped,
          selectedIndex: _currentPageIndex,
          destinations: const <FabNavigationBar.NavigationDestination>[
            FabNavigationBar.NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            FabNavigationBar.NavigationDestination(
              icon: Icon(Icons.event_available),
              label: 'Prenota',
            ),
            FabNavigationBar.NavigationDestination(
              icon: Icon(Icons.history),
              label: 'Storico',
            ),
            FabNavigationBar.NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profilo',
            ),
          ],
        ),
        floatingActionButton: const CartFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
