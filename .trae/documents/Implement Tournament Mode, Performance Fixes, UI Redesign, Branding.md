## Tournament Mode (3 Players)
- Add `TournamentLogic` to orchestrate 3→2→final flow and auto-eliminate the 3rd player as described.
- Create `TournamentProvider` for state, tracking rounds, current match players, and tournament winner.
- Add `TournamentScreen` with:
  - Round status, current players, and embedded `GameBoard` for play.
  - "Next Round" action that records the winner and advances.
  - Final winner banner and option to restart tournament.
- Integrate a "Tournament" button on Home to launch this screen.

## Persistent Scores & Player Names
- Add persistent storage using `shared_preferences` to save:
  - Player names and icons (editable from settings)
  - Win counts per player (VS scoreboard)
- Update `GameProvider` to increment per-player win counts when a match ends (`lib/app/logic/game_provider.dart:71–95`), and expose a scoreboard.
- Display scoreboard on Home below the board with total wins.

## Confetti Fix & Toggle
- Fix slow-falling confetti by updating parameters in `ConfettiWidget` (`lib/app/ui/screens/home_screen.dart:135–152`): higher `gravity`, explosive directionality, fewer particles, shorter duration.
- Add a "Confetti" toggle to Settings; only play when enabled.
- Ensure ConfettiController lifecycle is efficient and only runs on win.

## Performance Improvements (Lag)
- Reduce heavy `BackdropFilter` blurs in Home (`lib/app/ui/screens/home_screen.dart:99–105, 187–190`) and Tiles (`lib/app/ui/widgets/game_board.dart:185–187`) to lighter values.
- Wrap `GameBoard` in `RepaintBoundary` to isolate re-renders.
- Avoid unnecessary rebuilds/animations: use `TickerMode` when the game is over, de-duplicate shadows, and prefer const widgets.

## Winning Pulse Bug (3x3/4x4)
- Root cause: the newly placed winning tile gets a brand-new state (key depends on player), so `didUpdateWidget` doesn’t fire and its pulse never starts.
- Fixes in `lib/app/ui/widgets/game_board.dart`:
  - Use stable keys per cell: `ValueKey('tile-$row-$col')` (`line ~38`).
  - Start pulse in `initState` if `widget.isWinning` is already true (`line ~86–98`).

## Bigger Markers
- Increase marker sizes dynamically based on board size in `_GameTile` (`lib/app/ui/widgets/game_board.dart:189–205`): e.g., 3x3 → ~64, 4x4 → ~52, 5x5 → ~44.
- Slightly enlarge tile hit areas and reduce padding for a bolder feel.

## Settings Redesign (Bottom Navigation)
- Replace single Settings screen with a bottom navigation container (`SettingsRootScreen`). Tabs:
  - Game (board size, win condition, player mode)
  - Players (names/icons)
  - Audio & Haptics (sound/vibration, confetti toggle)
  - Appearance (theme)
  - About (version)
- Reuse existing sections from `lib/app/ui/screens/settings_screen.dart`, split into sub-pages and route via `BottomNavigationBar`.

## Branding Updates
- Android: Change `applicationId` to `com.liquidarc.tictactoe` and `android:label="Tic Tac Toe"` in `AndroidManifest.xml`.
- Kotlin package: move `MainActivity` from `com.liquidarc.tic_tac_toe_3_player` to `com.liquidarc.tictactoe` (`android/app/src/main/kotlin/.../MainActivity.kt`).
- iOS: Update `PRODUCT_BUNDLE_IDENTIFIER` to `com.liquidarc.tictactoe` in Xcode project and confirm display name.
- App Icon: Use `icon.png` at project root via `flutter_launcher_icons`; ensure splash (`android/app/src/main/res/drawable/splash.xml:5–8`) references updated launcher icon.

## Verification
- Unit test `TournamentLogic` transitions (3→2→final).
- Manual run: verify confetti improvements and toggle, scoreboard increments, and winning pulse behavior across 3x3/4x4/5x5.
- Build Android APK via existing GitHub Actions; confirm artifact.

## Notes
- All import paths currently use `package:tic_tac_toe_3_player/...`. After renaming package to `tictactoe`, update imports accordingly across `lib/`.
- No secrets committed; use `shared_preferences` only for local persistence.

Confirm this plan and I’ll implement it end-to-end (code edits, UI, logic, performance fixes, branding, and tests).