import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/cart_controller.dart';
import 'package:provider/provider.dart';
import '../routes/cart_page.dart';
import '../routes/material_page_route_alt.dart';

class CartFab extends StatelessWidget {
  const CartFab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, CartController controller, child) => Badge(
          badgeContent: controller.cart.isNotEmpty
              ? Text(
                  controller.cart.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 12,
                  ),
                )
              : null,
          badgeColor: Theme.of(context).colorScheme.secondary,
          position: BadgePosition.topEnd(top: 4, end: 4),
          showBadge: controller.cart.isNotEmpty,
          child: FloatingActionButton(
            shape: const StadiumBorder(),
            elevation: 1.8,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRouteAlt(
                  transitionDuration: const Duration(milliseconds: 300),
                  fromDirection: AxisDirection.up,
                  builder: (context) => const CartPage(),
                ),
              );
            },
            child: const Icon(Icons.shopping_cart_outlined),
          )),
    );
  }
}
