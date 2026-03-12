import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

enum ProductListState { initial, loading, loaded, error, refreshing }

class ProductListProvider extends ChangeNotifier {
  ProductListState _state = ProductListState.initial;
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];

  String _filterQuery = '';
  bool? _sortAscending; // Remembers sort order for when filters change

  final Map<String, VariantModel> _selectedVariants = {};
  final Set<String> _favoriteIds = {};
  String? _errorMessage;

  // Getters
  ProductListState get state => _state;
  List<ProductModel> get products => List.unmodifiable(_products);
  List<ProductModel> get filteredProducts =>
      List.unmodifiable(_filteredProducts);
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    // 1. Handle state transitions
    if (_state == ProductListState.loaded || _state == ProductListState.error) {
      _state = ProductListState.refreshing;
    } else if (_state != ProductListState.refreshing) {
      _state = ProductListState.loading;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      final service = GetIt.instance<ProductService>();
      final fetched = await service.fetchProducts();

      _products = fetched;

      // 2. Set default variants for new products
      for (final p in _products) {
        if (p.variants.isNotEmpty && !_selectedVariants.containsKey(p.id)) {
          _selectedVariants[p.id] = p.variants.first;
        }
      }

      _state = ProductListState.loaded;

      // 3. Apply any active filters and sorts to the newly fetched data
      _applyFilterAndSort();
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProductListState.error;
      notifyListeners();
    }
  }

  void selectVariant(String productId, VariantModel variant) {
    _selectedVariants[productId] = variant;
    notifyListeners();
  }

  VariantModel? selectedVariantFor(String productId) =>
      _selectedVariants[productId];

  void filterProducts(String query) {
    _filterQuery = query.trim().toLowerCase();
    _applyFilterAndSort();
  }

  void sortByPrice({required bool ascending}) {
    _sortAscending = ascending;
    _applyFilterAndSort();
  }

  // Helper method to ensure filter and sort always play nicely together
  void _applyFilterAndSort() {
    // Step 1: Apply Filter
    if (_filterQuery.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products
          .where((p) => p.title.toLowerCase().contains(_filterQuery))
          .toList();
    }

    // Step 2: Apply Sort (if a sort has been requested)
    if (_sortAscending != null) {
      _filteredProducts.sort((a, b) {
        final variantA = _selectedVariants[a.id];
        final variantB = _selectedVariants[b.id];

        // Handle products with no variants (push them to the end)
        if (variantA == null && variantB == null) return 0;
        if (variantA == null) return 1;
        if (variantB == null) return -1;

        return _sortAscending!
            ? variantA.price.compareTo(variantB.price)
            : variantB.price.compareTo(variantA.price);
      });
    }

    // Notify listeners once all list transformations are complete
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);
}
