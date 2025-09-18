# Flutter Taxi Exam App - Development Todo List

## Project Overview
Build a Flutter application for Hong Kong taxi driver exam preparation with 4 main tabs:
1. 地方問題 (Locations) with Google Maps
2. 路線問題 (Routes) with Google Maps
3. MC Questions for Locations
4. MC Questions for Routes

## Development Tasks

### Initial Setup & Configuration
- [ ] Set up Flutter project and dependencies
  - google_maps_flutter
  - http for API calls
  - shared_preferences for data persistence
  - provider/riverpod for state management
  - path_provider for file operations

- [ ] Create app structure with bottom navigation for 4 tabs
  - Main scaffold with BottomNavigationBar
  - Tab controllers and navigation logic
  - Basic page structures for each tab

- [ ] Parse and structure data from taxi_exam_locations_routes_edited.txt
  - Create data models for locations and routes
  - Build parser to extract information from text file
  - Store structured data in appropriate format

### Tab 1: 地方問題 (Locations)
- [ ] Implement Tab 1: 地方問題 (Locations) with search and list view
  - Categorized list view (醫院, 酒店, 政府樓宇, etc.)
  - Search functionality by name or district
  - Detail view for each location

- [ ] Integrate Google Maps for Tab 1 location display
  - Show map pin for selected location
  - Display location name and district on map
  - Add marker clustering for multiple locations

### Tab 2: 路線問題 (Routes)
- [ ] Implement Tab 2: 路線問題 (Routes) with start/end point selection
  - List view of all routes
  - Search by starting point or destination
  - Route detail display

- [ ] Integrate Google Maps for Tab 2 route visualization
  - Draw polyline for selected route
  - Show start and end markers
  - Display route segments with street names

### Quiz Features
- [ ] Create MC question logic and UI components
  - Question display component
  - Answer selection UI
  - Timer component (optional)
  - Progress indicator

- [ ] Implement Tab 3: MC questions for 地方問題 (Location quiz)
  - Random question generation
  - 4 multiple choice options per question
  - Show correct answer with explanation
  - Track correct/incorrect answers

- [ ] Implement Tab 4: MC questions for 路線問題 (Route quiz)
  - Question format: Given start and end, select correct route
  - Display route options
  - Visual feedback for answers
  - Review incorrect answers

### Enhancement Features
- [ ] Add quiz scoring and progress tracking
  - Score calculation system
  - Historical score tracking
  - Progress bars for each category
  - Achievement badges

- [ ] Implement data persistence for quiz scores and favorites
  - Save quiz history
  - Bookmark favorite locations/routes
  - User preferences storage
  - Offline data caching

- [ ] Add search and filter functionality across all tabs
  - Global search bar
  - Filter by category
  - Filter by district/area
  - Recent searches

### Performance & Optimization
- [ ] Optimize Google Maps performance and caching
  - Implement map tile caching
  - Lazy loading for markers
  - Reduce API calls
  - Memory management

### Localization & Accessibility
- [ ] Add localization support (Traditional Chinese/English)
  - String resources for both languages
  - Language switcher in settings
  - Proper text direction handling
  - Font support for Chinese characters

### Error Handling & Offline Support
- [ ] Implement error handling and offline mode
  - Network connectivity detection
  - Offline data availability
  - Error messages and retry logic
  - Graceful degradation

### UI/UX Polish
- [ ] Add app theming and UI polish
  - Light/Dark mode support
  - Custom color scheme
  - Consistent typography
  - Smooth animations and transitions

### Testing & Quality Assurance
- [ ] Test app on iOS and Android devices
  - Device compatibility testing
  - Performance testing
  - UI/UX testing across screen sizes
  - Bug fixes and optimization

### Analytics & Monitoring
- [ ] Add analytics and crash reporting
  - Firebase Analytics integration
  - Crashlytics setup
  - User behavior tracking
  - Performance monitoring

### Release Preparation
- [ ] Prepare app for release (icons, splash screen, app store assets)
  - App icon design for iOS and Android
  - Splash screen implementation
  - App store screenshots
  - App description and metadata
  - Privacy policy and terms of service

## Technical Stack
- **Framework**: Flutter
- **State Management**: Provider/Riverpod
- **Maps**: Google Maps Flutter
- **Storage**: SharedPreferences, SQLite
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics

## Data Source
- Primary data from: `/Users/cliffyeung/Development/rnd11_car/docs/taxi_exam_locations_routes_edited.txt`
- Document revision: 二○二四年十二月修訂 (December 2024 Revision)

## Notes
- Ensure compliance with Hong Kong Transport Department guidelines
- Consider adding future updates mechanism for exam content changes
- Implement feedback system for users to report errors or suggestions