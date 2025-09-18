import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../services/data_service.dart';
import '../models/location.dart';
import 'location_detail_screen.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '全部';
  List<Location> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _filteredLocations = _dataService.locations;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations() {
    setState(() {
      List<Location> results = _dataService.locations;

      // Filter by category
      if (_selectedCategory != '全部') {
        results = results.where((l) => l.category == _selectedCategory).toList();
      }

      // Filter by search query
      if (_searchController.text.isNotEmpty) {
        results = results.where((location) {
          final query = _searchController.text.toLowerCase();
          return location.name.toLowerCase().contains(query) ||
                 location.district.toLowerCase().contains(query);
        }).toList();
      }

      _filteredLocations = results;
    });
  }

  Future<void> _openInMaps(Location location) async {
    // Simply use location name and district for search
    final searchQuery = '${location.name} ${location.district}';
    final encodedName = Uri.encodeComponent(searchQuery);
    
    // Create Google Maps URL with just the search query (no coordinates)
    final url = Uri.parse(
      'comgooglemaps://?q=$encodedName'
    );
    
    // Fallback to web URL if Google Maps app is not installed
    final fallbackUrl = Uri.parse(
      'https://maps.google.com/maps?q=$encodedName'
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(fallbackUrl)) {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('無法開啟地圖應用程式')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final categories = ['全部', ..._dataService.getLocationCategories()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('地方問題'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜尋地方或地區...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterLocations();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) => _filterLocations(),
            ),
          ),

          // Category filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : '全部';
                        _filterLocations();
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '共 ${_filteredLocations.length} 個地方',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedCategory = '全部';
                      _filterLocations();
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('清除篩選'),
                ),
              ],
            ),
          ),

          // Locations list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final location = _filteredLocations[index];
                final isFavorite = appState.isLocationFavorite(location.id);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        location.id.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      location.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(location.district),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            location.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      onPressed: () {
                        appState.toggleLocationFavorite(location.id);
                      },
                    ),
                    onTap: () {
                      _openInMaps(location);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}