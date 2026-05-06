# Inggo VTC

VTC Moto-taxi à Djibouti

## Installation

```bash
flutter pub get
flutter run
```

## Structure

```
lib/
├── core/          # Design system, services, utils
├── l10n/          # Localisation FR/EN
├── model/         # Modèles Freezed
├── provider/      # Riverpod providers
├── screen/        # Écrans (splash, auth, customer, driver)
└── widget/        # Widgets réutilisables
```
cd ~/inggo && git pull origin main && cd android && ./gradlew clean && cd .. && flutter build apk --debug
rm -rf ~/.gradle/caches/8.11.1/transforms
rm -rf ~/.gradle/caches/journal-*
rm -rf ~/inggo/build
rm -rf ~/inggo/android/.gradle
rm -rf ~/inggo/android/app/build
flutter clean