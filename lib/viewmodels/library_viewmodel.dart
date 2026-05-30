import 'package:children_stories/data/models/book_model.dart';
import 'package:children_stories/data/repositories/bookmark_repository.dart';
import 'package:flutter/foundation.dart';

class LibraryViewModel extends ChangeNotifier {
  final BookmarkRepository _repository = BookmarkRepository();

  List<Book> _books = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  String? _languageCode;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize({required String userId, required String languageCode}) async {
    _userId = userId;
    _languageCode = languageCode;
    await fetchBookmarks();
  }

  Future<void> fetchBookmarks() async {
    if (_userId == null || _languageCode == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _repository.getBookmarkedBooks(_userId!, _languageCode!);
    } catch (e) {
      _error = e.toString();
      _books = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchBookmarks();
  }
}
