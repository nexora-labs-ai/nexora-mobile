## Build & Run

```bash
# Install dependencies
flutter pub get

# Generate code (Freezed, JsonSerializable, Injectable)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on a device/emulator
flutter run --dart-define=FLAVOR=development

# Run tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Run flavors

| Flavor | Command |
|---|---|
| Development | `flutter run --dart-define=FLAVOR=development --dart-define=BASE_URL=http://10.0.2.2:3000/api/v1` |
| Staging | `flutter run --dart-define=FLAVOR=staging` |
| Production | `flutter run --dart-define=FLAVOR=production` |
