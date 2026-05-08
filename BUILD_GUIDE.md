# SecureGuard — Complete Build & Setup Guide

## Project Structure

```
secureguard/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── constants/app_constants.dart   # Enums, tokens, config
│   │   └── theme/app_theme.dart           # Dark neon theme
│   ├── data/
│   │   ├── models/
│   │   │   ├── alert_event.dart           # Alert data model
│   │   │   └── app_settings.dart          # Settings model
│   │   └── repositories/
│   │       └── settings_repository.dart   # SharedPreferences I/O
│   ├── services/
│   │   ├── bluetooth_service.dart         # HC-05 BT Classic service
│   │   ├── alert_service.dart             # Alert parsing & vibration
│   │   └── permission_service.dart        # Android runtime permissions
│   └── presentation/
│       ├── screens/
│       │   ├── home_shell.dart            # Bottom nav shell
│       │   ├── bluetooth/bluetooth_screen.dart
│       │   ├── dashboard/dashboard_screen.dart
│       │   ├── history/history_screen.dart
│       │   └── settings/settings_screen.dart
│       └── widgets/
│           ├── common/neon_card.dart      # NeonCard, GlowText, StatusDot...
│           ├── alerts/alert_cards.dart    # Motion/Smoke alert cards
│           └── status/system_status_widget.dart
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml        # All BT permissions
│   │       ├── kotlin/com/secureguard/app/MainActivity.kt
│   │       └── res/
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle.properties
├── assets/
│   ├── sounds/
│   └── animations/
└── pubspec.yaml
```

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | 3.19+ |
| Dart SDK | 3.0+ |
| Android Studio | Hedgehog+ |
| Android SDK | API 21–34 |
| JDK | 17 |
| HC-05 paired | in Android BT settings |

---

## Step 1 — Flutter Setup

```bash
# Verify Flutter installation
flutter doctor -v

# If Flutter not installed:
# Download from https://docs.flutter.dev/get-started/install/windows/mobile

# Get dependencies
cd secureguard
flutter pub get
```

---

## Step 2 — Pair HC-05 Before Running

1. Power on the Arduino + HC-05
2. Go to Android Settings → Bluetooth → Scan
3. Find **HC-05** in the list (default PIN: **1234** or **0000**)
4. Pair it — it will appear in paired devices list
5. Launch SecureGuard → tap Bluetooth tab → tap **CONNECT**

---

## Step 3 — Run in Debug Mode

```bash
# List connected devices
flutter devices

# Run on connected Android phone
flutter run

# Run with verbose logging
flutter run -v
```

---

## Step 4 — Build Release APK

```bash
# Build unsigned APK (for demo/testing)
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk

# Build split APKs (smaller download per device ABI)
flutter build apk --split-per-abi

# Install directly on device
flutter install
```

---

## Arduino Code (upload before testing)

```cpp
// SecureGuard Arduino Sketch
// Hardware: Arduino Uno + HC-05 + PIR + MQ-2 + LED + Buzzer

#include <SoftwareSerial.h>

// HC-05 connected to pins 10 (RX) and 11 (TX)
SoftwareSerial btSerial(10, 11);

// Pin definitions
const int PIR_PIN    = 7;
const int MQ2_PIN    = A0;
const int LED_PIN    = 13;
const int BUZZER_PIN = 8;

// Thresholds
const int  SMOKE_THRESHOLD = 400;  // Adjust for your MQ-2 calibration
const long MOTION_COOLDOWN = 5000; // ms between motion alerts
const long SMOKE_COOLDOWN  = 5000;

// State
bool lastMotion = false;
bool lastSmoke  = false;
unsigned long lastMotionTime = 0;
unsigned long lastSmokeTime  = 0;

void setup() {
  Serial.begin(9600);   // Debug via USB
  btSerial.begin(9600); // HC-05 default baud

  pinMode(PIR_PIN,    INPUT);
  pinMode(MQ2_PIN,    INPUT);
  pinMode(LED_PIN,    OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  digitalWrite(LED_PIN,    LOW);
  digitalWrite(BUZZER_PIN, LOW);

  Serial.println("SecureGuard Ready");
  btSerial.println("SYSTEM NORMAL");
  delay(2000);
}

void loop() {
  unsigned long now = millis();

  // ── Read sensors ─────────────────────────────────────
  bool motionDetected = digitalRead(PIR_PIN) == HIGH;
  int  smokeLevel     = analogRead(MQ2_PIN);
  bool smokeDetected  = smokeLevel > SMOKE_THRESHOLD;

  // ── Smoke alert (higher priority) ────────────────────
  if (smokeDetected && (now - lastSmokeTime > SMOKE_COOLDOWN)) {
    lastSmokeTime = now;
    lastSmoke = true;

    digitalWrite(LED_PIN, HIGH);

    // Urgent buzzer pattern
    for (int i = 0; i < 3; i++) {
      tone(BUZZER_PIN, 1000, 300);
      delay(400);
    }

    btSerial.println("SMOKE ALERT");
    Serial.print("SMOKE ALERT - Level: ");
    Serial.println(smokeLevel);
  }
  else if (!smokeDetected && lastSmoke) {
    lastSmoke = false;
    if (!motionDetected) {
      digitalWrite(LED_PIN, LOW);
      noTone(BUZZER_PIN);
    }
    btSerial.println("ALL CLEAR");
  }

  // ── Motion alert ──────────────────────────────────────
  if (motionDetected && !lastMotion &&
      (now - lastMotionTime > MOTION_COOLDOWN)) {
    lastMotionTime = now;
    lastMotion = true;

    digitalWrite(LED_PIN, HIGH);

    // Single short beep
    tone(BUZZER_PIN, 800, 200);

    btSerial.println("MOTION DETECTED");
    Serial.println("MOTION DETECTED");
  }
  else if (!motionDetected && lastMotion) {
    lastMotion = false;
    if (!smokeDetected) {
      digitalWrite(LED_PIN, LOW);
      noTone(BUZZER_PIN);
    }
  }

  delay(100); // 10 Hz sensor polling
}
```

**HC-05 Wiring:**
```
HC-05 VCC  → 5V
HC-05 GND  → GND
HC-05 TX   → Arduino Pin 10 (through voltage divider if 5V logic!)
HC-05 RX   → Arduino Pin 11
PIR  OUT   → Arduino Pin 7
MQ-2 AOUT  → Arduino A0
LED        → Arduino Pin 13 (via 220Ω resistor)
Buzzer +   → Arduino Pin 8
```

> ⚠️ HC-05 RX operates at 3.3V logic. Use a voltage divider
> (1kΩ + 2kΩ) between Arduino TX (5V) → HC-05 RX.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "No paired devices" | Pair HC-05 in Android BT settings first |
| Connection fails | HC-05 default PIN is **1234**. Try **0000** if that fails |
| No messages received | Check HC-05 baud rate matches `btSerial.begin(9600)` |
| App crashes on launch | Grant all permissions when prompted |
| Build error: minSdk | Edit `android/app/build.gradle` → `minSdk 21` |
| BT permissions error | Run on Android 12+ device or emulator with BT support |
| Messages not parsed | Confirm Arduino sends exact strings: `MOTION DETECTED` and `SMOKE ALERT` |

---

## Dependencies (pubspec.yaml)

```yaml
flutter_bluetooth_serial: ^0.4.0   # HC-05 Classic BT
permission_handler: ^11.3.1        # Runtime permissions
provider: ^6.1.2                   # State management
shared_preferences: ^2.2.3         # Settings persistence
vibration: ^1.9.0                  # Haptic feedback
audioplayers: ^6.0.0               # Sound alerts
intl: ^0.19.0                      # Date formatting
flutter_animate: ^4.5.0            # Smooth animations
google_fonts: ^6.2.1               # Rajdhani font
lottie: ^3.1.2                     # Lottie animations (optional)
```

---

## Notes for Demo

- Connect to HC-05 first from the Bluetooth tab
- Walk in front of PIR sensor → app shows orange **MOTION DETECTED** card
- Hold smoke/lighter near MQ-2 → app shows red **SMOKE ALERT** with pulse animation
- All events saved in History tab with timestamps
- Settings persist across app restarts
- Auto-reconnect enabled by default

---

*SecureGuard — University Cybersecurity & Embedded Systems Project*
