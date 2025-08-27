// lib/shared/searchable_tab.dart

/// Contrato que páginas “buscáveis” implementam.
/// É só uma interface: o State da página continua sendo State<...>.
mixin SearchableTab {
  void applySearch(String query);
  String get searchHint;
}
