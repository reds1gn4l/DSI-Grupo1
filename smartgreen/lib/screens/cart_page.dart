import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'address_selection_page.dart';
import 'payment_page.dart';
import '../widgets/custom_button.dart';

class CartPage
    extends
        StatelessWidget {
  const CartPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final cart = Provider.of<
      CartService
    >(
      context,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carrinho',
        ),
      ),
      body:
          cart.items.isEmpty
              ? const Center(
                child: Text(
                  'Seu carrinho está vazio',
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          cart.items.length,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        CartItem item =
                            cart.items[index];
                        final price =
                            item.product.PrecoUnt;
                        final quantity =
                            item.quantity;
                        final subtotal =
                            price *
                            quantity;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal:
                                16,
                            vertical:
                                8,
                          ),
                          elevation:
                              4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              12,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                  child: Image.network(
                                    item.product.imageURL,
                                    width:
                                        70,
                                    height:
                                        70,
                                    fit:
                                        BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width:
                                      12,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.CientificName,
                                        style: const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize:
                                              16,
                                        ),
                                      ),
                                      const SizedBox(
                                        height:
                                            4,
                                      ),
                                      Text(
                                        'R\$ ${price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color:
                                              Colors.green[700],
                                          fontSize:
                                              14,
                                        ),
                                      ),
                                      const SizedBox(
                                        height:
                                            4,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Subtotal:',
                                            style: TextStyle(
                                              fontSize:
                                                  13,
                                            ),
                                          ),
                                          Text(
                                            'R\$ ${price.toStringAsFixed(2)} x $quantity = R\$ ${subtotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize:
                                                  13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove,
                                      ),
                                      onPressed: () {
                                        int newQty =
                                            quantity -
                                            1;
                                        if (newQty <=
                                            0) {
                                          cart.removeFromCart(
                                            item.product,
                                          );
                                        } else {
                                          cart.updateQuantity(
                                            item.product,
                                            newQty,
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                      '$quantity',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                      ),
                                      onPressed: () {
                                        cart.updateQuantity(
                                          item.product,
                                          quantity +
                                              1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total: R\$ ${cart.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize:
                                18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height:
                              10,
                        ),
                        CustomButton(
                          label:
                              'Finalizar Compra',
                          icon:
                              Icons.shopping_cart_checkout,
                          backgroundColor:
                              Colors.green,
                          onPressed: () async {
                            final selectedAddress = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      _,
                                    ) =>
                                        const AddressSelectionPage(),
                              ),
                            );
                            if (context.mounted &&
                                selectedAddress !=
                                    null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (
                                        _,
                                      ) => PaymentPage(
                                        selectedAddress:
                                            selectedAddress,
                                      ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(
                          height:
                              10,
                        ),
                        CustomButton(
                          label:
                              'Esvaziar Carrinho',
                          icon:
                              Icons.delete,
                          backgroundColor:
                              Colors.red,
                          onPressed: () async {
                            final confirm = await showDialog<
                              bool
                            >(
                              context:
                                  context,
                              builder:
                                  (
                                    _,
                                  ) => AlertDialog(
                                    title: const Text(
                                      'Confirmar ação',
                                    ),
                                    content: const Text(
                                      'Deseja realmente esvaziar o carrinho?',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text(
                                          'Cancelar',
                                        ),
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(
                                              false,
                                            ),
                                      ),
                                      TextButton(
                                        child: const Text(
                                          'Esvaziar',
                                        ),
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(
                                              true,
                                            ),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirm ==
                                true) {
                              cart.clearCart();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
