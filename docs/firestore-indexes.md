# Firestore Indexes Configuration

## Overview
This file contains comprehensive Firestore indexes for the Padel Arena application to support all lobby-related queries efficiently.

## Index Types Created

### 1. Basic Query Indexes
- **status + dateTime**: For filtering lobbies by status (open, closed, cancelled) ordered by date
- **skillLevel + dateTime**: For filtering by skill level (beginner, intermediate, advanced) ordered by date
- **matchType + dateTime**: For filtering by match type (friendly, competitive, tournament) ordered by date
- **genderPreference + dateTime**: For filtering by gender preference ordered by date
- **clubName + dateTime**: For filtering by club name ordered by date

### 2. Array Query Indexes
- **players (array-contains) + dateTime**: For finding lobbies that contain specific players ordered by date

### 3. Composite Query Indexes
- **status + skillLevel + dateTime**: For combined filtering by status and skill level
- **status + matchType + dateTime**: For combined filtering by status and match type

### 4. Field Overrides
- **dateTime**: Both ASCENDING and DESCENDING indexes for flexible date sorting

## Environments Covered
All indexes are created for:
- `dev_lobbies` (development environment)
- `staging_lobbies` (staging environment) 
- `prod_lobbies` (production environment)

## Query Examples Supported

### Basic Filtering
```dart
// Filter open lobbies ordered by date
.where('status', isEqualTo: 'open')
.orderBy('dateTime', descending: false)

// Filter by skill level
.where('skillLevel', isEqualTo: 'intermediate')
.orderBy('dateTime', descending: false)
```

### User Lobbies
```dart
// Find lobbies containing a specific user
.where('players', arrayContainsAny: [{'userId': userId}])
.orderBy('dateTime', descending: false)
```

### Combined Filters
```dart
// Filter open intermediate lobbies
.where('status', isEqualTo: 'open')
.where('skillLevel', isEqualTo: 'intermediate')
.orderBy('dateTime', descending: false)
```

## Performance Benefits
- ✅ Eliminates "requires an index" errors
- ✅ Optimizes query performance for large datasets
- ✅ Supports real-time updates efficiently
- ✅ Scales with application growth

## Maintenance
- Indexes are automatically maintained by Firebase
- New query patterns may require additional indexes
- Monitor query performance in Firebase Console

## Deployment
Deploy indexes using:
```bash
firebase deploy --only firestore:indexes
```

Index building typically takes 2-5 minutes for empty collections and longer for collections with existing data.