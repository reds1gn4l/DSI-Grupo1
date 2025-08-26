import 'package:flutter/material.dart';
import '../screens/catalog_page.dart';
import '../globals.dart';
import 'screens/login_screen.dart';
import '../screens/supply_list_page.dart';
import 'screens/plant_list_page.dart';

class HomePage
    extends
        StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  HomePageState createState() =>
      HomePageState(); // Tipo público aqui
}

// Classe do estado agora é pública (sem underscore)
class HomePageState
    extends
        State<
          HomePage
        >
    with
        SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length:
          3,
      vsync:
          this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false,
        title: const Text(
          'SmartGreen',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            tooltip:
                'Logout',
            onPressed: () {
              saveUserData(
                id:
                    null,
                name:
                    '',
                email:
                    '',
                address:
                    null,
                isAdmin:
                    false,
              );
              Navigator.of(
                context,
              ).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder:
                      (
                        _,
                      ) =>
                          LoginScreen(),
                ),
                (
                  route,
                ) =>
                    false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller:
              _tabController,
          tabs: const [
            Tab(
              icon: Icon(
                Icons.home,
              ),
              text:
                  'Home',
            ),
            Tab(
              icon: Icon(
                Icons.store,
              ),
              text:
                  'Loja',
            ),
            Tab(
              icon: Icon(
                Icons.inventory,
              ),
              text:
                  'Insumos',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller:
            _tabController,
        children: const [
          Center(
            child:
                PlantListPage(),
          ),
          CatalogPage(),
          SupplyListPage(),
        ],
      ),
    );
  }
}
