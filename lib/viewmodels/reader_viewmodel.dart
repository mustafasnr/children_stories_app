import 'package:children_stories/data/models/book_audio_model.dart';
import 'package:children_stories/data/models/book_model.dart';
import 'package:children_stories/data/models/book_page_model.dart';
import 'package:children_stories/data/repositories/book_repository.dart';
import 'package:flutter/foundation.dart';

class ReaderViewModel extends ChangeNotifier {
  final BookRepository _repository = BookRepository();

  Book? _book;
  BookAudio? _audio;
  List<BookPage> _pages = [];
  int _currentPageIndex = 0;
  bool _isLoading = false;
  String? _error;

  Book? get book => _book;
  BookAudio? get audio => _audio;
  List<BookPage> get pages => _pages;
  int get currentPageIndex => _currentPageIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalPages => _pages.length;
  bool get isFirstPage => _currentPageIndex == 0;
  bool get isLastPage => _currentPageIndex == _pages.length - 1;
  bool get hasAudio => _audio != null;
  BookPage? get currentPage =>
      _pages.isNotEmpty ? _pages[_currentPageIndex] : null;

  Future<void> loadReader(String bookId, String languageCode) async {
    _isLoading = true;
    _currentPageIndex = 0;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getBookById(bookId, languageCode),
        _repository.getBookPages(bookId, languageCode),
        _repository.getBookAudio(bookId, languageCode),
      ]);
      _book = results[0] as Book?;
      _pages = results[1] as List<BookPage>;
      _audio = results[2] as BookAudio?;
    } catch (e) {
      _error = 'Failed to load book pages.';
      debugPrint('[ReaderVM] error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void goToPage(int index) {
    if (index >= 0 && index < _pages.length) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  int getPageIndexForPosition(Duration position) {
    if (_pages.isEmpty) return 0;
    final seconds = position.inMilliseconds / 1000.0;
    for (int i = _pages.length - 1; i >= 0; i--) {
      if (seconds >= _pages[i].audioSeekSeconds) {
        return i;
      }
    }
    return 0;
  }

  void nextPage() {
    if (!isLastPage) goToPage(_currentPageIndex + 1);
  }

  void previousPage() {
    if (!isFirstPage) goToPage(_currentPageIndex - 1);
  }

  void reset() {
    _book = null;
    _audio = null;
    _pages = [];
    _currentPageIndex = 0;
    _isLoading = false;
    _error = null;
  }
}
