import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../services/data_service.dart';
import '../models/route.dart';
import 'route_detail_screen.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();
  List<TaxiRoute> _filteredRoutes = [];

  @override
  void initState() {
    super.initState();
    _filteredRoutes = _dataService.routes;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRoutes() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredRoutes = _dataService.routes;
      } else {
        _filteredRoutes = _dataService.searchRoutes(_searchController.text);
      }
    });
  }

  Future<void> _openInMaps(TaxiRoute route) async {
    // URL encode just the location names for search
    final encodedStart = Uri.encodeComponent(route.startPoint);
    final encodedEnd = Uri.encodeComponent(route.endPoint);
    
    // Create Google Maps URL with location names for navigation
    final url = Uri.parse(
      'comgooglemaps://?saddr=$encodedStart&daddr=$encodedEnd&directionsmode=driving'
    );
    
    // Fallback to web URL if Google Maps app is not installed
    final fallbackUrl = Uri.parse(
      'https://maps.google.com/maps?saddr=$encodedStart&daddr=$encodedEnd'
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('路線問題'),
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
                hintText: '搜尋起點或目的地...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterRoutes();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) => _filterRoutes(),
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '共 ${_filteredRoutes.length} 條路線',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_searchController.text.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      _filterRoutes();
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('清除搜尋'),
                  ),
              ],
            ),
          ),

          // Routes list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRoutes.length,
              itemBuilder: (context, index) {
                final route = _filteredRoutes[index];
                final isFavorite = appState.isRouteFavorite(route.id);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        route.id.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.trip_origin,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  route.startPoint,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.arrow_forward, size: 16),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  route.endPoint,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        route.routeDescription,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      onPressed: () {
                        appState.toggleRouteFavorite(route.id);
                      },
                    ),
                    onTap: () {
                      _openInMaps(route);
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