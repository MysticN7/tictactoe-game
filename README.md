# Tic Tac Toe 3 Player X O △

A Flutter-based Tic Tac Toe game with a "Liquid Glass" theme.

## How to Customize

### Change App Name

1.  Open `android/app/src/main/AndroidManifest.xml` and change the `android:label` attribute.
2.  Open `pubspec.yaml` and change the `name` attribute.

### Change Package Name

1.  Use the `flutter pub run change_app_package_name:main com.new.package.name` command.

### Add AdMob IDs

1.  Open `android/app/src/main/AndroidManifest.xml` and replace the placeholder `com.google.android.gms.ads.APPLICATION_ID` with your own AdMob App ID.
2.  Open `lib/app/utils/admob_service.dart` and replace the placeholder ad unit IDs with your own.

## How to Build

### Generate a signed APK

1.  Create a keystore: `keytool -genkey -v -keystore my-release-key.jks -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000`
2.  Create a `key.properties` file in the `android` directory with the following content:

    ```
    storePassword=<password>
    keyPassword=<password>
    keyAlias=my-key-alias
    storeFile=my-release-key.jks
    ```

3.  Run `flutter build apk --release`

### Generate an App Bundle

1.  Follow the same steps as for generating a signed APK.
2.  Run `flutter build appbundle --release`
