import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/route.dart';
import '../data/location_coordinates.dart';

class RouteMapView extends StatelessWidget {
  final TaxiRoute route;
  
  const RouteMapView({super.key, required this.route});

  Future<void> _openInMaps(BuildContext context) async {
    final startCoords = LocationCoordinates.getCoordinates(route.startPoint) ??
        LocationCoordinates.getDistrictCoordinates(route.startPoint.split(' ').last);
    final endCoords = LocationCoordinates.getCoordinates(route.endPoint) ??
        LocationCoordinates.getDistrictCoordinates(route.endPoint.split(' ').last);
    
    // URL encode just the location names for search
    final encodedStart = Uri.encodeComponent(route.startPoint);
    final encodedEnd = Uri.encodeComponent(route.endPoint);
    
    // Use start point coordinates, or end point if start is not available
    final coords = startCoords ?? endCoords;
    
    if (coords != null) {
      // Create Google Maps URL with location names for better accuracy
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('無法開啟地圖應用程式')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get coordinates for start and end points
    final startCoords = LocationCoordinates.getCoordinates(route.startPoint) ??
        LocationCoordinates.getDistrictCoordinates(route.startPoint.split(' ').last);
    final endCoords = LocationCoordinates.getCoordinates(route.endPoint) ??
        LocationCoordinates.getDistrictCoordinates(route.endPoint.split(' ').last);
    
    return GestureDetector(
      onTap: () => _openInMaps(context),
      child: Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade100,
            Colors.blue.shade50,
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Grid pattern background
          CustomPaint(
            size: const Size(double.infinity, 300),
            painter: RouteGridPainter(),
          ),
          
          // Start point marker
          Positioned(
            top: 60,
            left: 40,
            child: _buildLocationMarker(
              context,
              route.startPoint,
              '起點',
              Colors.green,
              Icons.trip_origin,
            ),
          ),
          
          // Route line
          CustomPaint(
            size: const Size(double.infinity, 300),
            painter: RouteLinePainter(),
          ),
          
          // End point marker
          Positioned(
            bottom: 60,
            right: 40,
            child: _buildLocationMarker(
              context,
              route.endPoint,
              '目的地',
              Colors.red,
              Icons.location_on,
            ),
          ),
          
          // Route segments display
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                route.routeSegments.take(2).join(' → '),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // Coordinates display
          if (startCoords != null && endCoords != null)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '起點: ${startCoords['lat']!.toStringAsFixed(4)}, ${startCoords['lng']!.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      '終點: ${endCoords['lat']!.toStringAsFixed(4)}, ${endCoords['lng']!.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Map type indicator with tap hint
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '點擊開啟路線',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
  
  Widget _buildLocationMarker(
    BuildContext context,
    String location,
    String label,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 40,
          color: color,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RouteGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 30.0;
    
    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(60, 100);
    path.quadraticBezierTo(
      size.width / 2, 
      size.height / 2,
      size.width - 60, 
      size.height - 100,
    );
    
    canvas.drawPath(path, paint);
    
    // Draw dotted line effect
    final dottedPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    const dashWidth = 5;
    const dashSpace = 5;
    double distance = 0;
    
    for (int i = 0; i < 20; i++) {
      if (i % 2 == 0) {
        canvas.drawCircle(
          Offset(
            60 + (size.width - 120) * (i / 20),
            100 + (size.height - 200) * (i / 20),
          ),
          2,
          dottedPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}