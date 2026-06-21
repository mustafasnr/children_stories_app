import 'package:children_stories/data/models/book_model.dart';
import 'package:children_stories/data/models/category_model.dart';
import 'package:children_stories/data/repositories/book_repository.dart';
import 'package:flutter/foundation.dart' hide Category;

class SearchViewModel extends ChangeNotifier {
  final BookRepository _repository = BookRepository();

  String _searchQuery = '';
  final Set<int> _selectedCategoryIds = {};
  final Set<int> _selectedAges = {}; // 3, 7, 11
  bool? _selectedIsPremium; // true, false

  List<Category> _categories = [];
  List<Book> _searchResults = [];
  bool _isLoading = false;
  bool _isLoadMoreRunning = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _error;
  String _lastLanguageCode = '';

  // Cache for default search results (no filters, empty query)
  List<Book> _defaultSearchResults = [];
  bool _defaultHasMore = true;
  int _defaultCurrentPage = 0;

  // Getters
  String get searchQuery => _searchQuery;
  Set<int> get selectedCategoryIds => _selectedCategoryIds;
  Set<int> get selectedAges => _selectedAges;
  bool? get selectedIsPremium => _selectedIsPremium;
  List<Category> get categories => _categories;
  List<Book> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isLoadMoreRunning => _isLoadMoreRunning;
  bool get hasMore => _hasMore;
  String? get error => _error;

  bool get hasActiveFilters =>
      _selectedCategoryIds.isNotEmpty ||
      _selectedAges.isNotEmpty ||
      _selectedIsPremium != null;

  /// Fetch categories for the current language if they are not loaded or language changed.
  Future<void> ensureCategoriesLoaded(String languageCode) async {
    if (_categories.isNotEmpty && _lastLanguageCode == languageCode) return;
    _lastLanguageCode = languageCode;
    try {
      _categories = await _repository.getCategoriesByLanguage(languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('[SearchVM] error loading categories: $e');
    }
  }

  /// Initialize or refresh search results
  Future<void> search(
    String queryText,
    String languageCode, {
    bool forceLoadingState = true,
  }) async {
    _searchQuery = queryText;
    _currentPage = 0;
    _hasMore = true;
    _error = null;

    if (_lastLanguageCode != languageCode) {
      _defaultSearchResults = [];
      _defaultHasMore = true;
      _defaultCurrentPage = 0;
    }

    if (queryText.trim().isEmpty && !hasActiveFilters) {
      if (_defaultSearchResults.isNotEmpty) {
        _searchResults = List.from(_defaultSearchResults);
        _currentPage = _defaultCurrentPage;
        _hasMore = _defaultHasMore;
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    if (forceLoadingState) {
      _isLoading = true;
      notifyListeners();
    }

    await ensureCategoriesLoaded(languageCode);

    try {
      final results = await _repository.searchBooks(
        languageCode,
        queryText: _searchQuery,
        categoryIds: _selectedCategoryIds.toList(),
        childAges: _selectedAges.toList(),
        isPremium: _selectedIsPremium,
        limit: 10,
        offset: 0,
      );

      _searchResults = results;
      if (results.length < 10) {
        _hasMore = false;
      }

      if (queryText.trim().isEmpty && !hasActiveFilters) {
        _defaultSearchResults = List.from(results);
        _defaultCurrentPage = _currentPage;
        _defaultHasMore = _hasMore;
      }
    } catch (e) {
      _error = 'Failed to load search results. Please try again.';
      debugPrint('[SearchVM] search error: $e');
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load next page for infinite scrolling
  Future<void> loadNextPage(String languageCode) async {
    if (_isLoading || _isLoadMoreRunning || !_hasMore) return;

    _isLoadMoreRunning = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final offset = nextPage * 10;

      final nextResults = await _repository.searchBooks(
        languageCode,
        queryText: _searchQuery,
        categoryIds: _selectedCategoryIds.toList(),
        childAges: _selectedAges.toList(),
        isPremium: _selectedIsPremium,
        limit: 10,
        offset: offset,
      );

      if (nextResults.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        if (nextResults.length < 10) {
          _hasMore = false;
        }
        _searchResults = [..._searchResults, ...nextResults];
      }

      if (_searchQuery.trim().isEmpty && !hasActiveFilters) {
        _defaultSearchResults = List.from(_searchResults);
        _defaultCurrentPage = _currentPage;
        _defaultHasMore = _hasMore;
      }
    } catch (e) {
      debugPrint('[SearchVM] loadNextPage error: $e');
    } finally {
      _isLoadMoreRunning = false;
      notifyListeners();
    }
  }

  /// Filter operations
  void toggleCategory(int categoryId) {
    if (_selectedCategoryIds.contains(categoryId)) {
      _selectedCategoryIds.remove(categoryId);
    } else {
      _selectedCategoryIds.add(categoryId);
    }
    notifyListeners();
  }

  void toggleAge(int age) {
    if (_selectedAges.contains(age)) {
      _selectedAges.remove(age);
    } else {
      _selectedAges.add(age);
    }
    notifyListeners();
  }

  void setSelectedIsPremium(bool? isPremium) {
    _selectedIsPremium = isPremium;
    notifyListeners();
  }

  Future<void> setFilters({
    required Set<int> categoryIds,
    required Set<int> ages,
    required bool? isPremium,
    required String languageCode,
  }) async {
    _selectedCategoryIds.clear();
    _selectedCategoryIds.addAll(categoryIds);
    _selectedAges.clear();
    _selectedAges.addAll(ages);
    _selectedIsPremium = isPremium;

    await search(_searchQuery, languageCode, forceLoadingState: true);
  }

  Future<void> clearFilters(String languageCode) async {
    if (!hasActiveFilters) return;
    _selectedCategoryIds.clear();
    _selectedAges.clear();
    _selectedIsPremium = null;
    await search(_searchQuery, languageCode, forceLoadingState: true);
  }
}
