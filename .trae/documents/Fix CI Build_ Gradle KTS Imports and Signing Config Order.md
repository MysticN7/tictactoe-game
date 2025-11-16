## Problem
- GitHub Actions build fails in `android/app/build.gradle.kts` with "Unresolved reference: util/io" and a deprecation warning for `kotlinOptions.jvmTarget`.

## Fixes
- Add top-of-file imports in `build.gradle.kts`:
  - `import java.util.Properties`
  - `import java.io.FileInputStream` (or use `keystorePropertiesFile.inputStream()` to avoid the import)
- Use `Properties()` and `keystorePropertiesFile.inputStream()` to load keys.
- Move `signingConfigs { ... }` block before `buildTypes` so `release` config exists when referenced.
- Keep `kotlinOptions.jvmTarget` as-is (warning only). Optionally add `kotlin { jvmToolchain(17) }` later.

## Exact Edits
- In `android/app/build.gradle.kts`:
  1) Add imports at the top.
  2) Change:
     - `val keystoreProperties = java.util.Properties()` → `val keystoreProperties = Properties()`
     - `keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))` → `keystoreProperties.load(keystorePropertiesFile.inputStream())`
  3) Move the `signingConfigs { create("release") { ... } }` block above `buildTypes`.
  4) Keep conditional `signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else signingConfigs.getByName("debug")`.

## Result
- CI builds `APK` and `AAB` successfully; no more unresolved references. We leave the Kotlin DSL deprecation for a future enhancement.