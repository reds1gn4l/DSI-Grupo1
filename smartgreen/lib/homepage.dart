import 'package:flutter/material.dart';
import 'package:smartgreen/globals.dart';

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

  // Tabs criadas para exemplificar a navegação e o layout para o pitch.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartGreen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.store), text: 'Loja'),
            Tab(icon: Icon(Icons.settings), text: 'Configurações'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: Text('Olá, ${(currentUser?.name ?? "usuário")}!')),
          Center(child: Text('Loja Screen')),
          Center(child: Text('Config Screen')),
        ],
      ),
    );
  }
}
