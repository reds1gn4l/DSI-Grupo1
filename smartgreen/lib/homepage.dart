import 'package:flutter/material.dart';
import '../screens/catalog_page.dart';
import '../screens/supply_list_page.dart';
import 'screens/plant_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartGreen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.store), text: 'Loja'),
            Tab(icon: Icon(Icons.inventory), text: 'Insumos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(
            child: PlantListPage(),
          ), // Aqui entrará a lista de plantas futuramente
          CatalogPage(),
          SupplyListPage(),
        ],
      ),
    );
  }
}
