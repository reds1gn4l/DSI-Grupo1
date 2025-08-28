// lib/homepage.dart
import 'package:flutter/material.dart';

import 'globals.dart';
import 'screens/login_screen.dart';
import 'screens/catalog_page.dart';
import 'screens/supply_list_page.dart';
import 'screens/plant_list_page.dart';
import 'screens/cart_page.dart';
import 'screens/store_product_list_page.dart'; // Admin: cadastrar/gerenciar produtos

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _currentIndex = 0;

  // Guarda a busca por aba (0: Plantas, 1: Loja, 2: Estoque, 3: Carrinho)
  final List<String> _tabQueries = ['', '', '', ''];

  // Keys só das páginas que recebem busca
  final GlobalKey<PlantListPageState> _plantKey =
      GlobalKey<PlantListPageState>();
  final GlobalKey<CatalogPageState> _catalogKey = GlobalKey<CatalogPageState>();
  final GlobalKey<SupplyListPageState> _supplyKey =
      GlobalKey<SupplyListPageState>();

  Color get _green => const Color(0xFF2E7D32);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _logout() {
    saveUserData(id: null, name: '', email: '', address: null, isAdmin: false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openAdminProducts() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProductListPage()));
  }

  // Chamado pela Loja (barra flutuante) para ir para a aba Carrinho
  void _goToCartTab() {
    setState(() {
      if (_currentIndex != 3) {
        _tabQueries[_currentIndex] = _searchCtrl.text;
      }
      _currentIndex = 3;
      _searchCtrl.text = ''; // carrinho não usa busca
    });
  }

  String _currentHint() {
    switch (_currentIndex) {
      case 0:
        return _plantKey.currentState?.searchHint ?? 'Buscar Planta';
      case 1:
        return _catalogKey.currentState?.searchHint ?? 'Buscar Produto';
      case 2:
        return _supplyKey.currentState?.searchHint ?? 'Buscar Item';
      case 3:
        return 'Carrinho de Compras'; // sem busca
      default:
        return 'Buscar no SmartGreen';
    }
  }

  void _dispatchSearch(String q) {
    // Se estiver no Carrinho, ignorar (sem campo de busca)
    if (_currentIndex == 3) return;

    _tabQueries[_currentIndex] = q;
    switch (_currentIndex) {
      case 0:
        _plantKey.currentState?.applySearch(q);
        break;
      case 1:
        _catalogKey.currentState?.applySearch(q);
        break;
      case 2:
        _supplyKey.currentState?.applySearch(q);
        break;
    }
    setState(() {}); // atualiza ícone/placeholder
  }

  PreferredSizeWidget _buildGreenTopBar(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final isCart = _currentIndex == 3;
    final isAdmin = getUserData()?.isAdmin == true;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: _green,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
        child: Row(
          children: [
            if (canPop)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Voltar',
              ),

            // Se NÃO for carrinho: barra de busca
            if (!isCart)
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 22, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        // Theme local para zerar TODAS as bordas do TextField
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: const InputDecorationTheme(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                            ),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: _currentHint(),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            textInputAction: TextInputAction.search,
                            onChanged: _dispatchSearch,
                            onSubmitted: _dispatchSearch,
                          ),
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        IconButton(
                          tooltip: 'Limpar',
                          icon: const Icon(Icons.clear, color: Colors.black54),
                          onPressed: () {
                            _searchCtrl.clear();
                            _dispatchSearch('');
                          },
                        ),
                    ],
                  ),
                ),
              ),

            // Se for carrinho: título centralizado
            if (isCart)
              const Expanded(
                child: Center(
                  child: Text(
                    'Carrinho de Compras',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SizedBox(width: 8),

            // Engrenagem → menu
            PopupMenuButton<_TopMenuAction>(
              icon: const Icon(Icons.settings, color: Colors.white),
              tooltip: 'Menu',
              onSelected: (action) {
                switch (action) {
                  case _TopMenuAction.logout:
                    _logout();
                    break;
                  case _TopMenuAction.adminProducts:
                    _openAdminProducts();
                    break;
                }
              },
              itemBuilder:
                  (context) => <PopupMenuEntry<_TopMenuAction>>[
                    const PopupMenuItem(
                      value: _TopMenuAction.logout,
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Sair'),
                      ),
                    ),
                    if (isAdmin)
                      const PopupMenuItem(
                        value: _TopMenuAction.adminProducts,
                        child: ListTile(
                          leading: Icon(Icons.playlist_add),
                          title: Text('Cadastrar produtos'),
                        ),
                      ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      PlantListPage(key: _plantKey),
      CatalogPage(
        key: _catalogKey,
        goToCart: _goToCartTab,
      ), // <- callback p/ ir à aba Carrinho
      SupplyListPage(key: _supplyKey),
      const CartContent(), // conteúdo do carrinho (sem Scaffold)
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildGreenTopBar(context),
      body: SafeArea(top: false, child: pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() {
            // salva a busca atual da aba antiga (se não for carrinho)
            if (_currentIndex != 3) {
              _tabQueries[_currentIndex] = _searchCtrl.text;
            }
            _currentIndex = i;

            // restaura a busca da nova aba (se não for carrinho) e reaplica
            if (_currentIndex != 3) {
              _searchCtrl.text = _tabQueries[_currentIndex];
              _searchCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchCtrl.text.length),
              );
              _dispatchSearch(_searchCtrl.text);
            } else {
              // carrinho: limpar texto para não manter ícone de limpar antigo
              _searchCtrl.text = '';
            }
          });
        },
        selectedItemColor: _green,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            activeIcon: Icon(Icons.local_florist),
            label: 'Plantas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Loja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Estoque',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Carrinho',
          ),
        ],
      ),
    );
  }
}

enum _TopMenuAction { logout, adminProducts }
