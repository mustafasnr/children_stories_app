import 'package:children_stories/data/models/book_audio_model.dart';
import 'package:children_stories/data/models/book_model.dart';
import 'package:children_stories/data/repositories/book_repository.dart';
import 'package:children_stories/data/repositories/bookmark_repository.dart';
import 'package:flutter/foundation.dart';

class BookDetailViewModel extends ChangeNotifier {
  final BookRepository _repository = BookRepository();
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();

  Book? _book;
  BookAudio? _audio;
  bool _isLoading = false;
  String? _error;
  bool _isBookmarked = false;

  Book? get book => _book;
  BookAudio? get audio => _audio;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAudio => _audio != null;
  bool get isBookmarked => _isBookmarked;

  Future<void> loadBook(String bookId, String languageCode, {String? userId}) async {
    _isLoading = true;
    _error = null;
    _isBookmarked = false;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getBookById(bookId, languageCode),
        _repository.getBookAudio(bookId, languageCode),
        if (userId != null)
          _bookmarkRepository.isBookmarked(userId, bookId)
        else
          Future.value(false),
      ]);
      _book = results[0] as Book?;
      _audio = results[1] as BookAudio?;
      _isBookmarked = results[2] as bool;
    } catch (e) {
      _error = 'Failed to load book.';
      debugPrint('[BookDetailVM] error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleBookmark(String userId) async {
    if (_book == null) return;
    
    final bookId = _book!.id;
    try {
      if (_isBookmarked) {
        await _bookmarkRepository.removeBookmark(userId, bookId);
        _isBookmarked = false;
      } else {
        await _bookmarkRepository.addBookmark(userId, bookId);
        _isBookmarked = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[BookDetailVM] toggleBookmark error: $e');
    }
  }

  void reset() {
    _book = null;
    _audio = null;
    _isLoading = false;
    _error = null;
    _isBookmarked = false;
  }
}
