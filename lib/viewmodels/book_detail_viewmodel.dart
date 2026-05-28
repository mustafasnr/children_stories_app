import 'package:children_stories/data/models/book_audio_model.dart';
import 'package:children_stories/data/models/book_model.dart';
import 'package:children_stories/data/repositories/book_repository.dart';
import 'package:flutter/foundation.dart';

class BookDetailViewModel extends ChangeNotifier {
  final BookRepository _repository = BookRepository();

  Book? _book;
  BookAudio? _audio;
  bool _isLoading = false;
  String? _error;

  Book? get book => _book;
  BookAudio? get audio => _audio;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAudio => _audio != null;

  Future<void> loadBook(String bookId, String languageCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getBookById(bookId, languageCode),
        _repository.getBookAudio(bookId, languageCode),
      ]);
      _book = results[0] as Book?;
      _audio = results[1] as BookAudio?;
    } catch (e) {
      _error = 'Failed to load book.';
      debugPrint('[BookDetailVM] error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _book = null;
    _audio = null;
    _isLoading = false;
    _error = null;
  }
}
