import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ascesa/features/benefits/data/models/partner_model.dart';

class BenefitsLocalDataSource {
  static const String _partnersKey = 'CACHED_PARTNERS';

  Future<void> cachePartners(List<PartnerModel> partners) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      partners.map((p) => p.toJson()).toList(),
    );
    await prefs.setString(_partnersKey, jsonString);
  }

  Future<List<PartnerModel>> getCachedPartners() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_partnersKey);
    
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => PartnerModel.fromJson(json)).toList();
    }
    
    return [];
  }
}
