import 'package:children_stories/data/models/book_model.dart';
import 'package:children_stories/data/models/category_model.dart';
import 'package:children_stories/data/models/language_model.dart';
import 'package:children_stories/data/repositories/book_repository.dart';
import 'package:flutter/foundation.dart' hide Category;

class HomeViewModel extends ChangeNotifier {
  final BookRepository _repository = BookRepository();

  List<Language> _languages = [];
  List<Category> _categories = [];
  List<Book> _books = [];
  List<Book> _featuredBooks = [];
  int _selectedLanguageIndex = 0;
  int? _selectedCategoryId;
  int? _childAge;
  bool _isLoading = false;
  String? _error;

  List<Language> get languages => _languages;
  List<Category> get categories => _categories;
  List<Book> get books => _books;
  List<Book> get featuredBooks => _featuredBooks;
  int get selectedLanguageIndex => _selectedLanguageIndex;
  int? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Language? get selectedLanguage =>
      _languages.isNotEmpty ? _languages[_selectedLanguageIndex] : null;

  Future<void> initialize({int? childAge}) async {
    _childAge = childAge;
    if (_languages.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _languages = await _repository.getLanguages();
      if (_languages.isNotEmpty) await _refreshAll();
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
    await _refreshAll();
  }

  Future<void> selectLanguage(int index) async {
    if (index == _selectedLanguageIndex && _books.isNotEmpty) return;
    _selectedLanguageIndex = index;
    _selectedCategoryId = null;
    _books = [];
    _featuredBooks = [];
    _categories = [];
    notifyListeners();
    await _refreshAll();
  }

  Future<void> selectCategory(int? categoryId) async {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    notifyListeners();
    final lang = selectedLanguage;
    if (lang != null) {
      _books = await _repository.getBooksByLanguage(
        lang.code,
        categoryId: categoryId,
        childAge: _childAge,
      );
      notifyListeners();
    }
  }

  Future<void> _refreshAll() async {
    final lang = selectedLanguage;
    if (lang == null) return;
    final results = await Future.wait([
      _repository.getCategoriesByLanguage(lang.code),
      _repository.getBooksByLanguage(
        lang.code,
        categoryId: _selectedCategoryId,
        childAge: _childAge,
      ),
      _repository.getFeaturedBooks(lang.code, childAge: _childAge),
    ]);
    _categories = results[0] as List<Category>;
    _books = results[1] as List<Book>;
    _featuredBooks = results[2] as List<Book>;
    notifyListeners();
  }
}
