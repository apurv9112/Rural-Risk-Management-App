import 'base.dart';

class MasterDataService {
  static const String baseUrl = baseAPIUrl;

  /// Fetch master data from API (currently stubbed since no API exists yet)
  Future<List<Map<String, dynamic>>> fetchMasterData(String token) async {
    // In a real implementation:
    // final response = await http.get(Uri.parse("$baseUrl/master-data"), headers: {"Authorization": "Bearer $token"});
    // return jsonDecode(response.body)["data"];

    // Stubbing the master data for M11 offline caching
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency

    return [
      // Reasons
      {'category': 'reasons', 'parent_key': 'tagging', 'key': '1', 'value': 'Reason A', 'is_active': 1},
      {'category': 'reasons', 'parent_key': 'tagging', 'key': '2', 'value': 'Reason B', 'is_active': 1},
      {'category': 'reasons', 'parent_key': 'retagging', 'key': '3', 'value': 'Tag Lost', 'is_active': 1},
      {'category': 'reasons', 'parent_key': 'retagging', 'key': '4', 'value': 'Tag Broken', 'is_active': 1},
      {'category': 'reasons', 'parent_key': 'claim', 'key': '5', 'value': 'Disease', 'is_active': 1},
      {'category': 'reasons', 'parent_key': 'claim', 'key': '6', 'value': 'Accident', 'is_active': 1},
      
      // Species
      {'category': 'species', 'parent_key': null, 'key': 'Buffalo', 'value': 'Buffalo', 'is_active': 1},
      {'category': 'species', 'parent_key': null, 'key': 'Cow', 'value': 'Cow', 'is_active': 1},
      {'category': 'species', 'parent_key': null, 'key': 'Sheep', 'value': 'Sheep', 'is_active': 1},
      {'category': 'species', 'parent_key': null, 'key': 'Goat', 'value': 'Goat', 'is_active': 1},
      
      // Breeds (Buffalo)
      {'category': 'breeds', 'parent_key': 'Buffalo', 'key': 'Murrah', 'value': 'Murrah', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Buffalo', 'key': 'Surti', 'value': 'Surti', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Buffalo', 'key': 'Jafarabadi', 'value': 'Jafarabadi', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Buffalo', 'key': 'Mehsana', 'value': 'Mehsana', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Buffalo', 'key': 'Banni', 'value': 'Banni', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Buffalo', 'key': 'Other', 'value': 'Other', 'is_active': 1},
      
      // Breeds (Cow)
      {'category': 'breeds', 'parent_key': 'Cow', 'key': 'Gir', 'value': 'Gir', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Cow', 'key': 'Kankrej', 'value': 'Kankrej', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Cow', 'key': 'Jersey', 'value': 'Jersey', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Cow', 'key': 'HF', 'value': 'HF', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Cow', 'key': 'Other', 'value': 'Other', 'is_active': 1},
      
      // Breeds (Sheep/Goat)
      {'category': 'breeds', 'parent_key': 'Sheep', 'key': 'Patanwadi', 'value': 'Patanwadi', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Sheep', 'key': 'Marwari', 'value': 'Marwari', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Sheep', 'key': 'Other', 'value': 'Other', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Goat', 'key': 'Zalawadi', 'value': 'Zalawadi', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Goat', 'key': 'Surti', 'value': 'Surti', 'is_active': 1},
      {'category': 'breeds', 'parent_key': 'Goat', 'key': 'Other', 'value': 'Other', 'is_active': 1},
      
      // States
      {'category': 'states', 'parent_key': null, 'key': 'GJ', 'value': 'Gujarat', 'is_active': 1},
      {'category': 'states', 'parent_key': null, 'key': 'MH', 'value': 'Maharashtra', 'is_active': 1},
      
      // Districts
      {'category': 'districts', 'parent_key': 'GJ', 'key': 'AHM', 'value': 'Ahmedabad', 'is_active': 1},
      {'category': 'districts', 'parent_key': 'GJ', 'key': 'SRT', 'value': 'Surat', 'is_active': 1},
      
      // Talukas
      {'category': 'talukas', 'parent_key': 'AHM', 'key': 'SND', 'value': 'Sanand', 'is_active': 1},
      {'category': 'talukas', 'parent_key': 'AHM', 'key': 'DHL', 'value': 'Dholka', 'is_active': 1},
      
      // Villages
      {'category': 'villages', 'parent_key': 'SND', 'key': '1', 'value': 'Bavla', 'is_active': 1},
      {'category': 'villages', 'parent_key': 'SND', 'key': '2', 'value': 'Chekhla', 'is_active': 1},
      {'category': 'villages', 'parent_key': 'DHL', 'key': '3', 'value': 'Chaloda', 'is_active': 1},
      {'category': 'villages', 'parent_key': 'DHL', 'key': '4', 'value': 'Koth', 'is_active': 1},
      {'category': 'villages', 'parent_key': 'ALL', 'key': '5', 'value': 'Other Village', 'is_active': 1}, // fallback

      // Banks
      {'category': 'banks', 'parent_key': null, 'key': 'HDFC', 'value': 'HDFC Bank', 'is_active': 1},
      {'category': 'banks', 'parent_key': null, 'key': 'SBI', 'value': 'State Bank of India', 'is_active': 1},
      
      // Bank Branches
      {'category': 'branches', 'parent_key': 'HDFC', 'key': '1', 'value': 'Ahmedabad Main', 'is_active': 1},
      {'category': 'branches', 'parent_key': 'HDFC', 'key': '2', 'value': 'Surat Main', 'is_active': 1},
      {'category': 'branches', 'parent_key': 'SBI', 'key': '3', 'value': 'Sanand Branch', 'is_active': 1},
      {'category': 'branches', 'parent_key': 'SBI', 'key': '4', 'value': 'Dholka Branch', 'is_active': 1},
    ];
  }
}
