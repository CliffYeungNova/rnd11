import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/data_service.dart';
import '../models/route.dart';

class RouteQuizScreen extends StatefulWidget {
  const RouteQuizScreen({super.key});

  @override
  State<RouteQuizScreen> createState() => _RouteQuizScreenState();
}

class _RouteQuizScreenState extends State<RouteQuizScreen> {
  final DataService _dataService = DataService();
  final Random _random = Random();
  
  TaxiRoute? _currentRoute;
  List<String> _options = [];
  int? _selectedOptionIndex;
  bool _showResult = false;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  int _correctOptionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNewQuestion();
  }

  void _loadNewQuestion() {
    if (_dataService.routes.isEmpty) return;

    setState(() {
      // Select a random route
      _currentRoute = _dataService.routes[_random.nextInt(_dataService.routes.length)];
      
      // Generate options (3 wrong + 1 correct route descriptions)
      _options = [];
      
      // Add correct answer
      _options.add(_currentRoute!.routeDescription);
      
      // Add 3 wrong answers from other routes
      final otherRoutes = _dataService.routes
          .where((r) => r.id != _currentRoute!.id)
          .toList();
      otherRoutes.shuffle(_random);
      
      for (var i = 0; i < min(3, otherRoutes.length); i++) {
        _options.add(otherRoutes[i].routeDescription);
      }
      
      // Shuffle options
      _options.shuffle(_random);
      
      // Find correct answer index
      _correctOptionIndex = _options.indexOf(_currentRoute!.routeDescription);
      
      // Reset state
      _selectedOptionIndex = null;
      _showResult = false;
    });
  }

  void _submitAnswer(int index) {
    if (_showResult) return;

    setState(() {
      _selectedOptionIndex = index;
      _showResult = true;
      _totalQuestions++;
      
      if (index == _correctOptionIndex) {
        _correctAnswers++;
      }
    });

    // Update score in app state
    final appState = Provider.of<AppState>(context, listen: false);
    if (index == _correctOptionIndex) {
      appState.updateRouteQuizScore(1, 1);
    } else {
      appState.updateRouteQuizScore(0, 1);
    }
  }

  Color _getOptionColor(int index) {
    if (!_showResult) {
      return _selectedOptionIndex == index
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface;
    }
    
    if (index == _correctOptionIndex) {
      return Colors.green.withOpacity(0.3);
    } else if (index == _selectedOptionIndex) {
      return Colors.red.withOpacity(0.3);
    }
    
    return Theme.of(context).colorScheme.surface;
  }

  IconData? _getOptionIcon(int index) {
    if (!_showResult) return null;
    
    if (index == _correctOptionIndex) {
      return Icons.check_circle;
    } else if (index == _selectedOptionIndex) {
      return Icons.cancel;
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('路線測驗'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '得分: $_correctAnswers / $_totalQuestions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _currentRoute == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress indicator
                  if (appState.routeQuizTotal > 0)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: appState.routeQuizScore / appState.routeQuizTotal,
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '總成績: ${appState.routeQuizScore} / ${appState.routeQuizTotal} '
                          '(${(appState.routeQuizScore * 100 / appState.routeQuizTotal).toStringAsFixed(1)}%)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Question card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.route,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '問題 ${_totalQuestions + 1}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.trip_origin,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '起點',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _currentRoute!.startPoint,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '目的地',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _currentRoute!.endPoint,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '選擇最直接可行的路線',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Answer options
                  Expanded(
                    child: ListView.builder(
                      itemCount: _options.length,
                      itemBuilder: (context, index) {
                        final icon = _getOptionIcon(index);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Material(
                            color: _getOptionColor(index),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _showResult ? null : () => _submitAnswer(index),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedOptionIndex == index
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                    width: _selectedOptionIndex == index ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                      ),
                                      child: Center(
                                        child: Text(
                                          String.fromCharCode(65 + index), // A, B, C, D
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _options[index],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (icon != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Icon(
                                          icon,
                                          color: index == _correctOptionIndex
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Next button
                  if (_showResult)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: _loadNewQuestion,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('下一題'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}