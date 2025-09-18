import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location.dart';
import '../models/route.dart';

class AppState extends ChangeNotifier {
  // Current tab index
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // Quiz scores
  int _locationQuizScore = 0;
  int _routeQuizScore = 0;
  int _locationQuizTotal = 0;
  int _routeQuizTotal = 0;

  int get locationQuizScore => _locationQuizScore;
  int get routeQuizScore => _routeQuizScore;
  int get locationQuizTotal => _locationQuizTotal;
  int get routeQuizTotal => _routeQuizTotal;

  // Favorites
  final Set<int> _favoriteLocationIds = {};
  final Set<int> _favoriteRouteIds = {};

  Set<int> get favoriteLocationIds => _favoriteLocationIds;
  Set<int> get favoriteRouteIds => _favoriteRouteIds;

  // Search queries
  String _locationSearchQuery = '';
  String _routeSearchQuery = '';

  String get locationSearchQuery => _locationSearchQuery;
  String get routeSearchQuery => _routeSearchQuery;

  AppState() {
    _loadPreferences();
  }

  void setCurrentTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void updateLocationSearchQuery(String query) {
    _locationSearchQuery = query;
    notifyListeners();
  }

  void updateRouteSearchQuery(String query) {
    _routeSearchQuery = query;
    notifyListeners();
  }

  void toggleLocationFavorite(int locationId) {
    if (_favoriteLocationIds.contains(locationId)) {
      _favoriteLocationIds.remove(locationId);
    } else {
      _favoriteLocationIds.add(locationId);
    }
    _savePreferences();
    notifyListeners();
  }

  void toggleRouteFavorite(int routeId) {
    if (_favoriteRouteIds.contains(routeId)) {
      _favoriteRouteIds.remove(routeId);
    } else {
      _favoriteRouteIds.add(routeId);
    }
    _savePreferences();
    notifyListeners();
  }

  bool isLocationFavorite(int locationId) {
    return _favoriteLocationIds.contains(locationId);
  }

  bool isRouteFavorite(int routeId) {
    return _favoriteRouteIds.contains(routeId);
  }

  void updateLocationQuizScore(int correct, int total) {
    _locationQuizScore += correct;
    _locationQuizTotal += total;
    _savePreferences();
    notifyListeners();
  }

  void updateRouteQuizScore(int correct, int total) {
    _routeQuizScore += correct;
    _routeQuizTotal += total;
    _savePreferences();
    notifyListeners();
  }

  void resetQuizScores() {
    _locationQuizScore = 0;
    _locationQuizTotal = 0;
    _routeQuizScore = 0;
    _routeQuizTotal = 0;
    _savePreferences();
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    _locationQuizScore = prefs.getInt('locationQuizScore') ?? 0;
    _locationQuizTotal = prefs.getInt('locationQuizTotal') ?? 0;
    _routeQuizScore = prefs.getInt('routeQuizScore') ?? 0;
    _routeQuizTotal = prefs.getInt('routeQuizTotal') ?? 0;

    final locationFavs = prefs.getStringList('favoriteLocations') ?? [];
    _favoriteLocationIds.addAll(locationFavs.map(int.parse));

    final routeFavs = prefs.getStringList('favoriteRoutes') ?? [];
    _favoriteRouteIds.addAll(routeFavs.map(int.parse));

    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('locationQuizScore', _locationQuizScore);
    await prefs.setInt('locationQuizTotal', _locationQuizTotal);
    await prefs.setInt('routeQuizScore', _routeQuizScore);
    await prefs.setInt('routeQuizTotal', _routeQuizTotal);

    await prefs.setStringList(
      'favoriteLocations',
      _favoriteLocationIds.map((id) => id.toString()).toList(),
    );
    await prefs.setStringList(
      'favoriteRoutes',
      _favoriteRouteIds.map((id) => id.toString()).toList(),
    );
  }
}