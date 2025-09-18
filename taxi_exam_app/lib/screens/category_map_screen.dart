import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/data_service.dart';
import '../models/location.dart';

class CategoryMapScreen extends StatefulWidget {
  const CategoryMapScreen({super.key});

  @override
  State<CategoryMapScreen> createState() => _CategoryMapScreenState();
}

class _CategoryMapScreenState extends State<CategoryMapScreen> {
  final DataService _dataService = DataService();
  String _selectedCategory = '醫院';
  List<Location> _filteredLocations = [];
  
  @override
  void initState() {
    super.initState();
    _filterByCategory();
  }
  
  void _filterByCategory() {
    setState(() {
      _filteredLocations = _dataService.locations
          .where((location) => location.category == _selectedCategory)
          .toList();
    });
  }
  
  Future<void> _openCategoryInMaps() async {
    if (_filteredLocations.isEmpty) return;
    
    // Create a search query with multiple locations
    // Google Maps can handle multiple waypoints in a search
    final locations = _filteredLocations.take(10).map((loc) => 
      '${loc.name} ${loc.district}'
    ).join(' | ');
    
    final encodedQuery = Uri.encodeComponent(locations);
    
    // Open Google Maps with the search query
    final url = Uri.parse(
      'comgooglemaps://?q=$encodedQuery'
    );
    
    final fallbackUrl = Uri.parse(
      'https://maps.google.com/maps?q=$encodedQuery'
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
  
  Future<void> _openSingleLocationInMaps(Location location) async {
    final searchQuery = '${location.name} ${location.district}';
    final encodedName = Uri.encodeComponent(searchQuery);
    
    final url = Uri.parse(
      'comgooglemaps://?q=$encodedName'
    );
    
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
    final categories = _dataService.getLocationCategories();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('分類地圖'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Category selector
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '選擇分類',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                          _filterByCategory();
                        });
                      }
                    },
                    items: categories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Category info card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategory,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_filteredLocations.length} 個地點',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _filteredLocations.isNotEmpty ? _openCategoryInMaps : null,
                        icon: const Icon(Icons.map),
                        label: Text('在地圖顯示所有${_selectedCategory}'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '地點列表（點擊查看單個地點）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Locations list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final location = _filteredLocations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
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
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () => _openSingleLocationInMaps(location),
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