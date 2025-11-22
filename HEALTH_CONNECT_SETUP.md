# Health Connect Setup Guide

## Problem: "Google Health Connect is not available on this Android device"

This error occurs because **Google Health Connect** is not installed on your device.

## Solution

### Step 1: Install Google Health Connect

1. Look for the **"Cài Health Connect"** button on the Health Screen
2. Click the button to open Google Play Store
3. Install **"Google Health Connect"** app
   - Alternative: Go to Play Store → Search "Google Health Connect" → Install

### Step 2: Sync Your Health Data

After installing Health Connect:

1. Return to the app
2. Click **"Đồng Bộ Google Fit"** button
3. Grant permissions when prompted
4. Wait for data to sync

## What Health Connect Does

- Acts as a central hub for health data on Android devices
- Allows apps like MediMinder to securely access health metrics
- Supports data from multiple sources:
  - Steps
  - Heart Rate
  - Blood Glucose
  - BMI

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Permission denied | Restart app and try again |
| No data synced | Ensure your fitness app has data in Health Connect |
| App crashes | Clear app cache: Settings → Apps → MediMinder → Storage → Clear Cache |

## Files Modified

- `lib/services/google_fit_sync_service.dart` - Added `installHealthConnect()` method
- `lib/screens/health_screen.dart` - Added "Cài Health Connect" button
- `android/app/build.gradle.kts` - Updated minSdk to 26
- `android/app/src/main/AndroidManifest.xml` - Added health permissions

## API Levels Required

- **Minimum SDK**: Android 8.0+ (API 26+)
- **Target SDK**: Latest (API 35+)
- **Health Connect**: Google Play Services 21.1.0+

