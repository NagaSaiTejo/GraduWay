import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for placement statistics aggregated via Cloud Functions.
/// Connects to the 'getPlacementStats' endpoint.
final placementStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('getPlacementStats')
        .call();
    return result.data as Map<String, dynamic>;
  } catch (e) {
    // Return mock data if call fails (e.g. no internet or functions not deployed)
    return {
      'totalAlumni': 450,
      'companiesRepresented': 120,
      'avgPackage': 12.5,
      'placementRate': 94,
      'topRecruiters': {
        'Amazon': 12,
        'Microsoft': 8,
        'Zoho': 25,
        'TCS': 45,
      },
    };
  }
});
