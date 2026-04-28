import 'package:flutter/material.dart';
import 'package:ascesa/features/blog/domain/entities/blog_post.dart';
import 'package:ascesa/features/blog/domain/usecases/get_blogs.dart';
import 'package:ascesa/features/blog/domain/usecases/get_blog_by_slug.dart';

class BlogController extends ChangeNotifier {
  final GetBlogs getBlogsUseCase;
  final GetBlogBySlug getBlogBySlugUseCase;

  bool _isLoading = false;
  bool _isDetailLoading = false;
  String? _errorMessage;
  List<BlogPost> _blogs = [];
  BlogPost? _selectedBlog;

  BlogController({
    required this.getBlogsUseCase,
    required this.getBlogBySlugUseCase,
  });

  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get errorMessage => _errorMessage;
  List<BlogPost> get blogs => _blogs;
  BlogPost? get selectedBlog => _selectedBlog;

  Future<void> fetchBlogs() async {
    _isLoading = true;
    _errorMessage = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _blogs = await getBlogsUseCase.call();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBlogDetail(String slug) async {
    _isDetailLoading = true;
    _errorMessage = null;
    _selectedBlog = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _selectedBlog = await getBlogBySlugUseCase.call(slug);
      _isDetailLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
