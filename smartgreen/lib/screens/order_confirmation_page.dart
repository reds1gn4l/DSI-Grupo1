// lib/screens/order_confirmation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';

class OrderConfirmationPage
    extends
        StatelessWidget {
  final String orderId;

  const OrderConfirmationPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final cs =
        Theme.of(
          context,
        ).colorScheme;
    final tt =
        Theme.of(
          context,
        ).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pedido Confirmado',
        ),
        centerTitle:
            true,
        backgroundColor:
            cs.primary,
        foregroundColor:
            cs.onPrimary, // seta e título brancos via tema
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color:
                  cs.primary, // usa cor do tema
              size:
                  100,
            ),
            const SizedBox(
              height:
                  24,
            ),
            Text(
              'Seu pedido foi realizado com sucesso!',
              textAlign:
                  TextAlign.center,
              style: tt.titleLarge?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height:
                  24,
            ),

            // Card com o código + botão de copiar
            Card(
              elevation:
                  2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Código do Pedido:',
                      style:
                          tt.bodyMedium,
                    ),
                    const SizedBox(
                      height:
                          8,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            orderId,
                            textAlign:
                                TextAlign.left,
                            style: tt.titleMedium?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  cs.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip:
                              'Copiar código',
                          icon: const Icon(
                            Icons.copy,
                          ),
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text:
                                    orderId,
                              ),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  behavior:
                                      SnackBarBehavior.floating,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal:
                                        24,
                                    vertical:
                                        12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  duration: const Duration(
                                    seconds:
                                        2,
                                  ),
                                  content: const Text(
                                    'Código copiado!',
                                    textAlign:
                                        TextAlign.center, // centralizado ✅
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height:
                  32,
            ),

            // Botão padrão (usa o tema)
            SizedBox(
              width:
                  double.infinity,
              child: CustomButton(
                label:
                    'Voltar à Página Inicial',
                icon:
                    Icons.home,
                backgroundColor:
                    cs.primary,
                textColor:
                    cs.onPrimary,
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(
                    '/homepage',
                    (
                      route,
                    ) =>
                        false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
