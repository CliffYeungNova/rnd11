# 📍 How to View Maps in the Taxi Exam App

## Where to Find the Maps

Maps are displayed in the **detail screens**, not in the main list views. Here's how to access them:

### 📍 View Location Maps:

1. Open the app in your browser
2. Click on **Tab 1: 地方問題** (Locations) at the bottom
3. **Click on any location** from the list (e.g., "瑪麗醫院")
4. You'll be taken to the location detail screen
5. **The map placeholder will be shown at the top** of the detail screen

### 🗺️ View Route Maps:

1. Click on **Tab 2: 路線問題** (Routes) at the bottom
2. **Click on any route** from the list (e.g., Route 320)
3. You'll be taken to the route detail screen
4. **The map placeholder will be shown at the top** of the detail screen

## What You Should See:

Since we don't have a Google Maps API key, you'll see a **placeholder map** that shows:
- An icon (location pin or route icon)
- The location/route name
- The district or route number
- A "地圖預覽" (Map Preview) label

## Navigation Flow:

```
Main App
├── Tab 1: 地方問題 (List of locations)
│   └── Click any location → Location Detail Screen (WITH MAP)
├── Tab 2: 路線問題 (List of routes)
│   └── Click any route → Route Detail Screen (WITH MAP)
├── Tab 3: 地方測驗 (Quiz - no map)
└── Tab 4: 路線測驗 (Quiz - no map)
```

## Troubleshooting:

If you don't see the detail screens:
1. Make sure you're **clicking on a location or route item** in the list
2. The detail screen should open with the map at the top
3. Scroll down to see more details about the location/route

## Note:
- The quiz tabs (Tab 3 & 4) don't have maps - they're for testing knowledge
- Only the detail screens (accessed from Tab 1 & 2) have map views