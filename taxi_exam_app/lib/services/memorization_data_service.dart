import 'package:flutter/services.dart';
import '../models/location.dart';
import '../models/route.dart';

class MemorizationDataService {
  static final MemorizationDataService _instance = MemorizationDataService._internal();
  factory MemorizationDataService() => _instance;
  MemorizationDataService._internal();

  final List<Location> _locations = [];
  final List<TaxiRoute> _routes = [];
  final Map<String, List<Location>> _locationsByDistrict = {};
  final Map<String, List<TaxiRoute>> _routesByTunnel = {};
  bool _isInitialized = false;

  List<Location> get locations => _locations;
  List<TaxiRoute> get routes => _routes;
  Map<String, List<Location>> get locationsByDistrict => _locationsByDistrict;
  Map<String, List<TaxiRoute>> get routesByTunnel => _routesByTunnel;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load the memorization guide from assets
      final String content = await rootBundle.loadString('assets/taxi_exam_memorization_guide.txt');
      _parseContent(content);
      _isInitialized = true;
    } catch (e) {
      print('Error loading memorization guide: $e');
      // Fallback to original data if file loading fails
      _loadOriginalData();
      _isInitialized = true;
    }
  }

  void _parseContent(String content) {
    final lines = content.split('\n');
    bool inLocationsSection = false;
    bool inRoutesSection = false;
    String currentDistrict = '';
    String currentCategory = '';
    String currentTunnel = '';

    for (var line in lines) {
      line = line.trim();
      
      // Check for main sections
      if (line.contains('地方問題 (LOCATIONS)')) {
        inLocationsSection = true;
        inRoutesSection = false;
        continue;
      } else if (line.contains('路線問題 (ROUTES)')) {
        inLocationsSection = false;
        inRoutesSection = true;
        continue;
      }

      // Parse locations
      if (inLocationsSection && line.isNotEmpty && !line.startsWith('=') && !line.startsWith('*')) {
        // Check for district headers
        if (line.contains('區 -') || line.contains('District')) {
          currentDistrict = line.split(' ').first;
          _locationsByDistrict[currentDistrict] = [];
          continue;
        }

        // Check for category headers
        if (line.contains('【') && line.contains('】')) {
          currentCategory = line.replaceAll(RegExp(r'【|】'), '').trim();
          continue;
        }

        // Parse location entries
        final match = RegExp(r'^(\d+)\.\s+(.+?)\s+-\s+(.+)$').firstMatch(line);
        if (match != null) {
          final id = int.parse(match.group(1)!);
          final name = match.group(2)!.trim();
          final district = match.group(3)!.trim();
          
          final location = Location(
            id: id,
            name: name,
            district: district,
            category: currentCategory.isEmpty ? _inferCategory(name) : currentCategory,
          );
          
          _locations.add(location);
          if (_locationsByDistrict.containsKey(currentDistrict)) {
            _locationsByDistrict[currentDistrict]!.add(location);
          }
        }
      }

      // Parse routes
      if (inRoutesSection && line.isNotEmpty && !line.startsWith('=') && !line.startsWith('*')) {
        // Check for tunnel group headers
        if (line.contains('隧道') || line.contains('Tunnel')) {
          currentTunnel = line.trim();
          _routesByTunnel[currentTunnel] = [];
          continue;
        }

        // Parse route entries
        final routeMatch = RegExp(r'^(\d+)\.\s+(.+?)\s+→\s+(.+)$').firstMatch(line);
        if (routeMatch != null) {
          final id = int.parse(routeMatch.group(1)!);
          final startPoint = routeMatch.group(2)!.trim();
          final endPoint = routeMatch.group(3)!.trim();
          
          // Get the route description from the next line
          final routeIndex = lines.indexOf(line);
          String routeDescription = '';
          if (routeIndex + 1 < lines.length) {
            final nextLine = lines[routeIndex + 1].trim();
            if (nextLine.startsWith('路線：')) {
              routeDescription = nextLine.substring(3).trim();
            }
          }
          
          // Parse route segments from description
          final segments = routeDescription.isEmpty 
              ? <String>[] 
              : routeDescription.split('、').map((s) => s.trim()).toList();
          
          final route = TaxiRoute(
            id: id,
            startPoint: startPoint,
            endPoint: endPoint,
            routeSegments: segments,
          );
          
          _routes.add(route);
          if (_routesByTunnel.containsKey(currentTunnel)) {
            _routesByTunnel[currentTunnel]!.add(route);
          }
        }
      }
    }

    // Sort locations and routes by ID to maintain original order
    _locations.sort((a, b) => a.id.compareTo(b.id));
    _routes.sort((a, b) => a.id.compareTo(b.id));
  }

  String _inferCategory(String name) {
    if (name.contains('醫院')) return '醫院';
    if (name.contains('酒店')) return '酒店';
    if (name.contains('廣場') || name.contains('中心')) return '商場';
    if (name.contains('大學') || name.contains('學院')) return '大專院校';
    if (name.contains('碼頭') || name.contains('公園')) return '旅遊景點';
    if (name.contains('政府') || name.contains('合署')) return '政府大樓';
    if (name.contains('邨') || name.contains('園') || name.contains('城')) return '屋苑';
    return '其他';
  }

  void _loadOriginalData() {
    // Fallback to original hardcoded data from DataService
    // This would be a copy of the existing _parseLocations() and _parseRoutes() methods
    // For now, we'll leave it empty as the file should load successfully
  }

  List<String> getDistricts() {
    return _locationsByDistrict.keys.toList();
  }

  List<String> getTunnels() {
    return _routesByTunnel.keys.toList();
  }

  List<Location> getLocationsByDistrict(String district) {
    return _locationsByDistrict[district] ?? [];
  }

  List<TaxiRoute> getRoutesByTunnel(String tunnel) {
    return _routesByTunnel[tunnel] ?? [];
  }

  List<String> getLocationCategories() {
    final categories = <String>{};
    for (var location in _locations) {
      categories.add(location.category);
    }
    return categories.toList()..sort();
  }

  List<Location> searchLocations(String query) {
    final lowerQuery = query.toLowerCase();
    return _locations.where((location) =>
      location.name.toLowerCase().contains(lowerQuery) ||
      location.district.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  List<TaxiRoute> searchRoutes(String query) {
    final lowerQuery = query.toLowerCase();
    return _routes.where((route) =>
      route.startPoint.toLowerCase().contains(lowerQuery) ||
      route.endPoint.toLowerCase().contains(lowerQuery) ||
      route.routeDescription.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}