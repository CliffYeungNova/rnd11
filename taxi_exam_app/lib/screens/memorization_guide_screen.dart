import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MemorizationGuideScreen extends StatefulWidget {
  const MemorizationGuideScreen({super.key});

  @override
  State<MemorizationGuideScreen> createState() => _MemorizationGuideScreenState();
}

class _MemorizationGuideScreenState extends State<MemorizationGuideScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  TabController? _tabController;
  List<String> _sections = [];
  final Map<String, List<Widget>> _sectionWidgets = {};
  final Map<String, List<Widget>> _allSectionWidgets = {};
  final Map<String, Set<String>> _sectionDistricts = {};
  final Map<String, String?> _selectedDistricts = {};
  String _guideContent = '';
  
  @override
  void initState() {
    super.initState();
    _loadGuide();
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  
  Future<void> _loadGuide() async {
    try {
      final String content = await rootBundle.loadString('assets/taxi_exam_memorization_guide.txt');
      setState(() {
        _guideContent = content;
        _parseGuideContent(content);
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to showing error message
      setState(() {
        _sections = ['錯誤'];
        _sectionWidgets['錯誤'] = [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('無法載入溫習指南：$e'),
          )
        ];
        _tabController = TabController(length: 1, vsync: this);
        _isLoading = false;
      });
    }
  }
  
  void _parseGuideContent(String content) {
    final lines = content.split('\n');
    String currentMainSection = '';
    String currentDistrict = '';
    String currentCategory = '';
    List<Widget> currentWidgets = [];
    Map<String, List<Widget>> districtWidgets = {};
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // Main sections - check for exact pattern to avoid matching routes section
      if (line.startsWith('★★★ 港島區') && !line.contains('路線')) {
        if (currentMainSection.isNotEmpty && currentWidgets.isNotEmpty) {
          _allSectionWidgets[currentMainSection] = List.from(currentWidgets);
          _sectionWidgets[currentMainSection] = List.from(currentWidgets);
          if (districtWidgets.isNotEmpty) {
            _sectionDistricts[currentMainSection] = districtWidgets.keys.toSet();
          }
          currentWidgets.clear();
          districtWidgets.clear();
        }
        currentMainSection = '港島區';
        if (!_sections.contains(currentMainSection)) {
          _sections.add(currentMainSection);
          _selectedDistricts[currentMainSection] = null; // null means "All"
        }
        currentWidgets.add(_buildSectionHeader('港島區 HONG KONG ISLAND'));
      } else if (line.startsWith('★★★ 九龍區') && !line.contains('路線')) {
        if (currentMainSection.isNotEmpty && currentWidgets.isNotEmpty) {
          _allSectionWidgets[currentMainSection] = List.from(currentWidgets);
          _sectionWidgets[currentMainSection] = List.from(currentWidgets);
          if (districtWidgets.isNotEmpty) {
            _sectionDistricts[currentMainSection] = districtWidgets.keys.toSet();
          }
          currentWidgets.clear();
          districtWidgets.clear();
        }
        currentMainSection = '九龍區';
        if (!_sections.contains(currentMainSection)) {
          _sections.add(currentMainSection);
          _selectedDistricts[currentMainSection] = null;
        }
        currentWidgets.add(_buildSectionHeader('九龍區 KOWLOON'));
      } else if (line.startsWith('★★★ 新界區') && !line.contains('路線')) {
        if (currentMainSection.isNotEmpty && currentWidgets.isNotEmpty) {
          _allSectionWidgets[currentMainSection] = List.from(currentWidgets);
          _sectionWidgets[currentMainSection] = List.from(currentWidgets);
          if (districtWidgets.isNotEmpty) {
            _sectionDistricts[currentMainSection] = districtWidgets.keys.toSet();
          }
          currentWidgets.clear();
          districtWidgets.clear();
        }
        currentMainSection = '新界區';
        if (!_sections.contains(currentMainSection)) {
          _sections.add(currentMainSection);
          _selectedDistricts[currentMainSection] = null;
        }
        currentWidgets.add(_buildSectionHeader('新界區 NEW TERRITORIES'));
      } else if (line.contains('路線問題記憶指南') || (line.contains('ROUTES') && line.contains('320'))) {
        if (currentMainSection.isNotEmpty && currentWidgets.isNotEmpty) {
          _allSectionWidgets[currentMainSection] = List.from(currentWidgets);
          _sectionWidgets[currentMainSection] = List.from(currentWidgets);
          if (districtWidgets.isNotEmpty) {
            _sectionDistricts[currentMainSection] = districtWidgets.keys.toSet();
          }
          currentWidgets.clear();
          districtWidgets.clear();
        }
        currentMainSection = '路線';
        if (!_sections.contains(currentMainSection)) {
          _sections.add(currentMainSection);
          _selectedDistricts[currentMainSection] = null;
        }
        currentWidgets.add(_buildSectionHeader('路線問題 ROUTES (320-356)'));
      } else if (line.contains('記憶輔助工具') || line.contains('記憶技巧')) {
        if (currentMainSection.isNotEmpty && currentWidgets.isNotEmpty) {
          _allSectionWidgets[currentMainSection] = List.from(currentWidgets);
          _sectionWidgets[currentMainSection] = List.from(currentWidgets);
          if (districtWidgets.isNotEmpty) {
            _sectionDistricts[currentMainSection] = districtWidgets.keys.toSet();
          }
          currentWidgets.clear();
          districtWidgets.clear();
        }
        currentMainSection = '記憶技巧';
        if (!_sections.contains(currentMainSection)) {
          _sections.add(currentMainSection);
          _selectedDistricts[currentMainSection] = null;
        }
        currentWidgets.add(_buildSectionHeader('記憶技巧 MEMORY AIDS'));
      }
      // District headers (e.g., 【中環金鐘區】)
      else if (line.startsWith('【') && line.endsWith('】')) {
        currentDistrict = line.replaceAll('【', '').replaceAll('】', '');
        final nextLine = i + 1 < lines.length ? lines[i + 1] : '';
        final districtWidget = _buildDistrictHeader(currentDistrict, nextLine);
        currentWidgets.add(districtWidget);
        // Start a new district section
        if (!districtWidgets.containsKey(currentDistrict)) {
          districtWidgets[currentDistrict] = [];
        }
        districtWidgets[currentDistrict]!.add(districtWidget);
      }
      // Category headers (e.g., 醫院：, 酒店：)
      else if (line.endsWith('：') || line.endsWith(':')) {
        currentCategory = line.replaceAll('：', '').replaceAll(':', '');
        final headerWidget = _buildCategoryHeader(currentCategory);
        currentWidgets.add(headerWidget);
        if (currentDistrict.isNotEmpty && districtWidgets.containsKey(currentDistrict)) {
          districtWidgets[currentDistrict]!.add(headerWidget);
        }
      }
      // Location entries (e.g., "1. 瑪麗醫院 - 薄扶林")
      else if (RegExp(r'^\d+\.\s+.+\s+-\s+.+$').hasMatch(line)) {
        final tile = _buildLocationTile(line, currentCategory);
        currentWidgets.add(tile);
        if (currentDistrict.isNotEmpty && districtWidgets.containsKey(currentDistrict)) {
          districtWidgets[currentDistrict]!.add(tile);
        }
      }
      // Route entries (e.g., "- 320. 沙田富豪花園 → 屯門市廣場")
      else if (RegExp(r'^-?\s*\d+\.\s+.+\s+→\s+.+$').hasMatch(line)) {
        final nextLine = i + 1 < lines.length ? lines[i + 1] : '';
        currentWidgets.add(_buildRouteTile(line, nextLine));
        if (nextLine.trim().startsWith('路線：')) {
          i++; // Skip the route description line as it's already processed
        }
      }
      // Section dividers
      else if (line.startsWith('---') || line.startsWith('===')) {
        // Skip dividers
      }
      // Other content
      else if (line.isNotEmpty && !line.startsWith('★')) {
        // Check if it's a tunnel group header
        if ((line.contains('隧道') || line.contains('Tunnel')) && currentMainSection == '路線') {
          currentWidgets.add(_buildTunnelGroupHeader(line));
        } else if (!line.contains('記憶指南') && !line.contains('TABLE OF CONTENTS')) {
          // Add as regular text if not a header
          currentWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Text(line, style: const TextStyle(fontSize: 14)),
            )
          );
        }
      }
    }
    
    // Add the last section
    if (currentMainSection.isNotEmpty && currentWidgets.isNotEmpty) {
      _allSectionWidgets[currentMainSection] = List.from(currentWidgets);
      _sectionWidgets[currentMainSection] = List.from(currentWidgets);
      if (districtWidgets.isNotEmpty) {
        _sectionDistricts[currentMainSection] = districtWidgets.keys.toSet();
      }
    }
    
    // Create tab controller
    if (_sections.isNotEmpty) {
      _tabController = TabController(length: _sections.length, vsync: this);
    }
    
    // Debug: Print districts found
    for (var section in _sectionDistricts.keys) {
      print('Section: $section, Districts: ${_sectionDistricts[section]}');
    }
  }
  
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildDistrictHeader(String district, String subtitle) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            district,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          if (subtitle.isNotEmpty && !subtitle.contains('---'))
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.8),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryHeader(String category) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
  
  Widget _buildTunnelGroupHeader(String tunnel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.directions_subway,
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tunnel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationTile(String line, String category) {
    final match = RegExp(r'^(\d+)\.\s+(.+?)\s+-\s+(.+)$').firstMatch(line.trim());
    if (match != null) {
      final number = match.group(1)!;
      final name = match.group(2)!;
      final district = match.group(3)!;
      
      // Determine icon based on category
      IconData icon = Icons.place;
      if (category.contains('醫院')) icon = Icons.local_hospital;
      else if (category.contains('酒店')) icon = Icons.hotel;
      else if (category.contains('商場')) icon = Icons.shopping_cart;
      else if (category.contains('政府')) icon = Icons.account_balance;
      else if (category.contains('商業')) icon = Icons.business;
      else if (category.contains('大學')) icon = Icons.school;
      else if (category.contains('屋苑')) icon = Icons.home;
      
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    radius: 18,
                    child: Text(
                      number,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(icon, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Place name with map button
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.map, size: 18),
                              onPressed: () => _openInMaps(name),
                              tooltip: '$name 地圖',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        // District with map button
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                district,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.map_outlined, size: 18),
                              onPressed: () => _openInMaps(district),
                              tooltip: '$district 地圖',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
  
  Widget _buildRouteTile(String line, String nextLine) {
    // Remove leading dash if present
    line = line.trim().replaceFirst(RegExp(r'^-\s*'), '');
    
    // Parse the basic route information
    final match = RegExp(r'^(\d+)\.\s+(.+?)\s+→\s+(.+)$').firstMatch(line.trim());
    if (match != null) {
      final number = match.group(1)!;
      final start = match.group(2)!;
      final end = match.group(3)!.trim();
      
      String route = '';
      List<String> roadSegments = [];
      
      // Check if there's route info on the next line
      if (nextLine.trim().startsWith('路線：')) {
        route = nextLine.trim().substring(3).trim();
        // Split the route by comma and "及"
        roadSegments = route.split(RegExp(r'[、,]|及'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route header with number
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    radius: 22,
                    child: Text(
                      number,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          start,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.arrow_downward, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                end,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (route.isNotEmpty) ...[
                const SizedBox(height: 16),
                // Main navigation button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openRouteInMaps(start, end),
                    icon: const Icon(Icons.directions, size: 20),
                    label: Text(
                      '導航整條路線',
                      style: const TextStyle(fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Route details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '路線：',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        route,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Individual road segments
                Text(
                  '個別路段導航：',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: roadSegments.map((segment) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openInMaps(segment),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                segment,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
  
  Future<void> _openInMaps(String location) async {
    final encodedName = Uri.encodeComponent(location);
    final url = Uri.parse('comgooglemaps://?q=$encodedName');
    final fallbackUrl = Uri.parse('https://maps.google.com/maps?q=$encodedName');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(fallbackUrl)) {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    }
  }
  
  Future<void> _openRouteInMaps(String start, String end) async {
    final encodedStart = Uri.encodeComponent(start);
    final encodedEnd = Uri.encodeComponent(end);
    final url = Uri.parse('comgooglemaps://?saddr=$encodedStart&daddr=$encodedEnd&directionsmode=driving');
    final fallbackUrl = Uri.parse('https://maps.google.com/maps?saddr=$encodedStart&daddr=$encodedEnd');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(fallbackUrl)) {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    }
  }
  
  void _filterByDistrict(String section, String? district) {
    setState(() {
      _selectedDistricts[section] = district;
      if (district == null) {
        // Show all
        _sectionWidgets[section] = List.from(_allSectionWidgets[section] ?? []);
      } else {
        // Filter by district
        final allWidgets = _allSectionWidgets[section] ?? [];
        final filteredWidgets = <Widget>[];
        bool inSelectedDistrict = false;
        
        for (var widget in allWidgets) {
          // Check if it's a section header - always include
          if (widget is Container && widget.color == Theme.of(context).colorScheme.primaryContainer) {
            filteredWidgets.add(widget);
          }
          // Check if it's a district header
          else if (widget is Container) {
            // Check if this is a district header by examining its child structure
            final decoration = (widget as Container).decoration;
            if (decoration is BoxDecoration && decoration.color == Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5)) {
              // This is a district header
              final column = widget.child;
              if (column is Column) {
                final children = column.children;
                if (children.isNotEmpty) {
                  final firstChild = children.first;
                  if (firstChild is Text) {
                    final districtName = firstChild.data ?? '';
                    if (districtName == district) {
                      inSelectedDistrict = true;
                      filteredWidgets.add(widget);
                    } else {
                      inSelectedDistrict = false;
                    }
                  }
                }
              }
            }
          }
          // Add all widgets in selected district
          else if (inSelectedDistrict) {
            filteredWidgets.add(widget);
          }
        }
        _sectionWidgets[section] = filteredWidgets;
      }
    });
  }

  Widget _buildDistrictDropdown(String section) {
    final districts = _sectionDistricts[section] ?? {};
    // Always show dropdown, even if empty for debugging
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Row(
        children: [
          Text(
            '地區篩選：',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String?>(
              value: _selectedDistricts[section],
              isExpanded: true,
              hint: const Text('全部地區'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('全部地區'),
                ),
                ...districts.map((district) => DropdownMenuItem<String?>(
                  value: district,
                  child: Text(district),
                )),
              ],
              onChanged: (value) => _filterByDistrict(section, value),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('溫習指南'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: _tabController != null ? TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _sections.map((section) => Tab(text: section)).toList(),
        ) : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tabController != null && _sections.isNotEmpty
              ? TabBarView(
                  controller: _tabController,
                  children: _sections.map((section) {
                    final widgets = _sectionWidgets[section] ?? [];
                    return Column(
                      children: [
                        if (!['路線', '記憶技巧'].contains(section))
                          _buildDistrictDropdown(section),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(bottom: 20),
                            children: widgets,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                )
              : const Center(
                  child: Text('無法載入溫習指南'),
                ),
    );
  }
}