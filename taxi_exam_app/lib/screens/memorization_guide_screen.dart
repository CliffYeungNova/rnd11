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
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // Main sections
      if (line.contains('港島區') || line.contains('HONG KONG ISLAND')) {
        if (currentMainSection.isNotEmpty && currentWidgets.isNotEmpty) {
          _sectionWidgets[currentMainSection] = List.from(currentWidgets);
          currentWidgets.clear();
        }
        currentMainSection = '港島區';
        if (!_sections.contains(currentMainSection)) {
          _sections.add(currentMainSection);
        }
        currentWidgets.add(_buildSectionHeader('港島區 HONG KONG ISLAND'));
      } else if (line.contains('九龍區') || line.contains('KOWLOON')) {
        if (currentMainSection.isNotEmpty && currentWidgets.isNotEmpty) {
          _sectionWidgets[currentMainSection] = List.from(currentWidgets);
          currentWidgets.clear();
        }
        currentMainSection = '九龍區';
        if (!_sections.contains(currentMainSection)) {
          _sections.add(currentMainSection);
        }
        currentWidgets.add(_buildSectionHeader('九龍區 KOWLOON'));
      } else if (line.contains('新界區') || line.contains('NEW TERRITORIES')) {
        if (currentMainSection.isNotEmpty && currentWidgets.isNotEmpty) {
          _sectionWidgets[currentMainSection] = List.from(currentWidgets);
          currentWidgets.clear();
        }
        currentMainSection = '新界區';
        if (!_sections.contains(currentMainSection)) {
          _sections.add(currentMainSection);
        }
        currentWidgets.add(_buildSectionHeader('新界區 NEW TERRITORIES'));
      } else if (line.contains('路線問題記憶指南') || (line.contains('ROUTES') && line.contains('320'))) {
        if (currentMainSection.isNotEmpty && currentWidgets.isNotEmpty) {
          _sectionWidgets[currentMainSection] = List.from(currentWidgets);
          currentWidgets.clear();
        }
        currentMainSection = '路線';
        if (!_sections.contains(currentMainSection)) {
          _sections.add(currentMainSection);
        }
        currentWidgets.add(_buildSectionHeader('路線問題 ROUTES (320-356)'));
      } else if (line.contains('記憶輔助工具') || line.contains('記憶技巧')) {
        if (currentMainSection.isNotEmpty && currentWidgets.isNotEmpty) {
          _sectionWidgets[currentMainSection] = List.from(currentWidgets);
          currentWidgets.clear();
        }
        currentMainSection = '記憶技巧';
        if (!_sections.contains(currentMainSection)) {
          _sections.add(currentMainSection);
        }
        currentWidgets.add(_buildSectionHeader('記憶技巧 MEMORY AIDS'));
      }
      // District headers (e.g., 【中環金鐘區】)
      else if (line.startsWith('【') && line.endsWith('】')) {
        currentDistrict = line.replaceAll('【', '').replaceAll('】', '');
        final nextLine = i + 1 < lines.length ? lines[i + 1] : '';
        currentWidgets.add(_buildDistrictHeader(currentDistrict, nextLine));
      }
      // Category headers (e.g., 醫院：, 酒店：)
      else if (line.endsWith('：') || line.endsWith(':')) {
        currentCategory = line.replaceAll('：', '').replaceAll(':', '');
        currentWidgets.add(_buildCategoryHeader(currentCategory));
      }
      // Location entries (e.g., "1. 瑪麗醫院 - 薄扶林")
      else if (RegExp(r'^\d+\.\s+.+\s+-\s+.+$').hasMatch(line)) {
        currentWidgets.add(_buildLocationTile(line, currentCategory));
      }
      // Route entries (e.g., "320. 沙田富豪花園 → 屯門市廣場")
      else if (RegExp(r'^\d+\.\s+.+\s+→\s+.+$').hasMatch(line)) {
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
      _sectionWidgets[currentMainSection] = List.from(currentWidgets);
    }
    
    // Create tab controller
    if (_sections.isNotEmpty) {
      _tabController = TabController(length: _sections.length, vsync: this);
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
            Icons.tunnel,
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
        child: ListTile(
          leading: CircleAvatar(
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
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(district, style: const TextStyle(fontSize: 13)),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.map, size: 20),
            onPressed: () => _openInMaps('$name $district'),
            tooltip: '在地圖中查看',
          ),
          dense: true,
        ),
      );
    }
    return const SizedBox.shrink();
  }
  
  Widget _buildRouteTile(String line, String nextLine) {
    final match = RegExp(r'^(\d+)\.\s+(.+?)\s+→\s+(.+)$').firstMatch(line.trim());
    if (match != null) {
      final number = match.group(1)!;
      final start = match.group(2)!;
      final end = match.group(3)!;
      
      String route = '';
      if (nextLine.trim().startsWith('路線：')) {
        route = nextLine.trim().substring(3).trim();
      }
      
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            radius: 18,
            child: Text(
              number,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(start, style: const TextStyle(fontSize: 14)),
              Row(
                children: [
                  const Icon(Icons.arrow_downward, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      end,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.directions, size: 20),
            onPressed: () => _openRouteInMaps(start, end),
            tooltip: '導航路線',
          ),
          children: route.isNotEmpty ? [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.surface,
              child: Text(
                '路線：$route',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ] : [],
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
                    return ListView(
                      padding: const EdgeInsets.only(bottom: 20),
                      children: widgets,
                    );
                  }).toList(),
                )
              : const Center(
                  child: Text('無法載入溫習指南'),
                ),
    );
  }
}