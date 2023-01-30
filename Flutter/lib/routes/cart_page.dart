import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/cart_controller.dart';
import 'package:flutter_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

/// Cart page
class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          // The button to clear the cart
          IconButton(
            onPressed: () {
              context.read<CartController>().clearCart();
            },
            icon: const Icon(Icons.remove_shopping_cart_outlined),
          ),
        ],
      ),
      body: SafeArea(
          child: Consumer<CartController>(
              builder: (context, CartController controller, child) =>

                  /// check if the cart is empty
                  /// If the cart has elements, show them
                  (controller.cart.isNotEmpty)
                      ? Column(children: [
                          Expanded(
                              child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: KeyedSubtree(
                              key: ValueKey(
                                  DateTime.now().millisecondsSinceEpoch),
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: controller.cart.length,
                                itemBuilder: (context, index) {
                                  return controller.getCartEntry(index);
                                },
                              ),
                            ),
                          )),
                          Center(

                              /// slider for confirm prenotation
                              child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SlideAction(
                                innerColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                outerColor:
                                    Theme.of(context).colorScheme.surface,
                                onSubmit: () async {
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar();
                                  await controller.buyCart()
                                      ? ScaffoldMessenger.of(context)
                                          .showSnackBar(AltSnackbar(
                                              type: AltSnackbarType.success,
                                              text: "Acquisto avvenuto!"))
                                      : ScaffoldMessenger.of(context)
                                          .showSnackBar(AltSnackbar(
                                              type: AltSnackbarType.error,
                                              text: "Acquisto non avvenuto!"));
                                },
                                sliderButtonIcon:
                                    const Icon(Icons.shopping_cart_checkout),
                                child: const Text('Conferma prenotazione')),
                          )),
                        ])

                      /// If the cart is empty show a message
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Il carrello è vuoto',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Torna indietro'),
                              ),
                            ],
                          ),
                        ))),
    );
  }
}
