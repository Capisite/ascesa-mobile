import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ascesa/features/home/data/models/category_model.dart';

class HomeLocalDataSource {
  static const String _categoriesKey = 'CACHED_CATEGORIES';

  Future<void> cacheCategories(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      categories.map((c) => c.toJson()).toList(),
    );
    await prefs.setString(_categoriesKey, jsonString);
  }

  Future<List<CategoryModel>> getCachedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_categoriesKey);
    
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
    }
    
    return [];
  }
}
