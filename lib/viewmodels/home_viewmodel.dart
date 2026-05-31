import 'package:children_stories/data/models/book_model.dart';
import 'package:children_stories/data/models/category_model.dart';
import 'package:children_stories/data/models/language_model.dart';
import 'package:children_stories/data/repositories/book_repository.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends ChangeNotifier {
  final BookRepository _repository = BookRepository();

  List<Language> _languages = [];
  
  // Caches keyed by language code
  final Map<String, List<Category>> _cachedCategories = {};
  final Map<String, List<Book>> _cachedBooks = {}; // Currently fetched books for selected language/category
  final Map<String, List<Book>> _cachedFeaturedBooks = {};

  int _selectedLanguageIndex = 0;
  int? _selectedCategoryId;
  int? _childAge;
  bool _isLoading = false;
  String? _error;

  int _currentPage = 0;
  bool _isLoadMoreRunning = false;
  bool _hasMore = true;

  List<Language> get languages => _languages;
  
  Language? get selectedLanguage =>
      _languages.isNotEmpty ? _languages[_selectedLanguageIndex] : null;

  List<Category> get categories {
    final lang = selectedLanguage;
    if (lang == null) return [];
    return _cachedCategories[lang.code] ?? [];
  }

  List<Book> get books {
    final lang = selectedLanguage;
    if (lang == null) return [];
    return _cachedBooks[lang.code] ?? [];
  }

  List<Book> get featuredBooks {
    final lang = selectedLanguage;
    if (lang == null) return [];
    return _cachedFeaturedBooks[lang.code] ?? [];
  }

  int get selectedLanguageIndex => _selectedLanguageIndex;
  int? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoadMoreRunning => _isLoadMoreRunning;
  bool get hasMore => _hasMore;

  Future<void> initialize({int? childAge}) async {
    _childAge = childAge;
    if (_languages.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _languages = await _repository.getLanguages();
      if (_languages.isNotEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final savedCode = prefs.getString('selected_language_code');
          if (savedCode != null) {
            final idx = _languages.indexWhere((l) => l.code == savedCode);
            if (idx != -1) {
              _selectedLanguageIndex = idx;
            }
          } else {
            // Default to English if no preference is saved
            final enIdx = _languages.indexWhere((l) => l.code == 'en');
            if (enIdx != -1) {
              _selectedLanguageIndex = enIdx;
            }
          }
        } catch (e) {
          debugPrint('[HomeVM] error loading language preference: $e');
        }
        await _refreshAll();
      }
    } catch (e) {
      _error = 'Failed to load content. Pull to refresh.';
      debugPrint('[HomeVM] initialize error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _error = null;
    if (_languages.isEmpty) {
      await initialize(childAge: _childAge);
      return;
    }
    await _refreshAll(forceRefresh: true);
  }

  Future<void> selectLanguage(int index) async {
    if (index == _selectedLanguageIndex) return;
    _selectedLanguageIndex = index;
    _selectedCategoryId = null;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = selectedLanguage;
      if (lang != null) {
        await prefs.setString('selected_language_code', lang.code);
      }
    } catch (e) {
      debugPrint('[HomeVM] error saving language preference: $e');
    }

    await _refreshAll(); // Will fetch if not cached, or update in background if cached
  }

  Future<void> selectCategory(int? categoryId) async {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();
    final lang = selectedLanguage;
    if (lang != null) {
      _cachedBooks[lang.code] = await _repository.getBooksByLanguage(
        lang.code,
        categoryId: categoryId,
        childAge: _childAge,
        limit: 10,
        offset: 0,
      );
      if ((_cachedBooks[lang.code]?.length ?? 0) < 10) {
        _hasMore = false;
      }
      notifyListeners();
    }
  }

  Future<void> _refreshAll({bool forceRefresh = false}) async {
    final lang = selectedLanguage;
    if (lang == null) return;
    
    final code = lang.code;
    
    // If we have cached data and not forcing refresh, show it immediately 
    // and we could optionally fetch in background.
    bool hasData = _cachedCategories.containsKey(code) && 
                   _cachedBooks.containsKey(code) && 
                   _cachedFeaturedBooks.containsKey(code);
                   
    if (!hasData || forceRefresh) {
      if (!hasData) {
        _isLoading = true;
        notifyListeners();
      }
      
      _currentPage = 0;
      _hasMore = true;
      try {
        final results = await Future.wait([
          _repository.getCategoriesByLanguage(code),
          _repository.getBooksByLanguage(
            code,
            categoryId: _selectedCategoryId,
            childAge: _childAge,
            limit: 10,
            offset: 0,
          ),
          _repository.getFeaturedBooks(code, childAge: _childAge),
        ]);
        
        _cachedCategories[code] = results[0] as List<Category>;
        _cachedBooks[code] = results[1] as List<Book>;
        _cachedFeaturedBooks[code] = results[2] as List<Book>;
        _error = null;

        if ((results[1] as List).length < 10) {
          _hasMore = false;
        }
      } catch (e) {
        _error = 'Failed to load content. Pull to refresh.';
        debugPrint('[HomeVM] refreshAll error: $e');
      }

      if (!hasData) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (_isLoading || _isLoadMoreRunning || !_hasMore) return;

    final lang = selectedLanguage;
    if (lang == null) return;

    _isLoadMoreRunning = true;
    notifyListeners();

    try {
      final code = lang.code;
      final nextPage = _currentPage + 1;
      final offset = nextPage * 10;

      final newBooks = await _repository.getBooksByLanguage(
        code,
        categoryId: _selectedCategoryId,
        childAge: _childAge,
        limit: 10,
        offset: offset,
      );

      if (newBooks.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        if (newBooks.length < 10) {
          _hasMore = false;
        }
        final currentList = _cachedBooks[code] ?? [];
        _cachedBooks[code] = [...currentList, ...newBooks];
      }
    } catch (e) {
      debugPrint('[HomeVM] loadNextPage error: $e');
    } finally {
      _isLoadMoreRunning = false;
      notifyListeners();
    }
  }
}
