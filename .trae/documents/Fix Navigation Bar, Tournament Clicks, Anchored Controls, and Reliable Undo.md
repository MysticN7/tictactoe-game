## Objectives

- Restore a consistent, responsive navigation bar with correct z-ordering.
- Fix unresponsive controls in tournament rounds 2/3 and add visual feedback on moves.
- Anchor main controls (Restart, Undo, Tournament) so they are always visible without scrolling.
- Make Undo reliable with correct state management and edge-case handling plus visual confirmation.
- Implement automated tests, manual QA, and performance profiling; keep the build error-free.

## Architecture & Files Impacted

- `lib/app/ui/screens/home_screen.dart` (header/app bar, bottom controls layout)
- `lib/app/ui/screens/tournament_screen.dart` (header consistency, interaction flow, layout simplification)
- `lib/app/ui/widgets/game_board.dart` (grid config and tap handling, visual feedback)
- `lib/app/logic/game_logic.dart` (Undo logic fix and state handling)
- `lib/app/logic/game_provider.dart` (Undo availability, feedback triggering)
- Tests under `test/` (new widget/unit/integration tests)

## 1) Navigation Bar

- Convert Home’s in-body header to a proper `Scaffold.appBar` using the existing glass styling internals from `_buildAppBar` (`lib/app/ui/screens/home_screen.dart:277–326`).
- Remove `extendBodyBehindAppBar` on Home (`home_screen.dart:98`) and set a non-transparent background for the app bar to ensure contrast.
- Ensure Tournament app bar matches Home and is not fully transparent (`lib/app/ui/screens/tournament_screen.dart:79–123`).
- Verify z-index by keeping header in the `appBar` slot and moving overlays to `body` (`home_screen.dart:149–151`).

## 2) Tournament Functionality

- Ensure player set/reset sequence is robust: when advancing rounds, update active players first, then `resetGame()` (`tournament_screen.dart:644–651`).
- Reduce gesture conflicts: minimize nested `BackdropFilter` around `GameBoard` container in tournament (`tournament_screen.dart:332–346`).
- Add tap visual feedback per tile (brief scale/glow is present; ensure it triggers on every tap) (`lib/app/ui/widgets/game_board.dart:90–117, 137–147`).
- Add a subtle “Move registered” snackbar/toast on valid taps via `GameProvider.makeMove` notifications.

## 3) Main Screen Layout

- Move action controls from scrollable column into `Scaffold.bottomNavigationBar` (`home_screen.dart:153–159`). Compose a `Column`:
  - Controls row (glass style)
  - Ad banner (`AdWidget`) below controls
- Remove the in-content controls (`home_screen.dart:547–605`) to avoid duplication.
- Reduce vertical spacing to fit primary content without scroll (`home_screen.dart:124–139`).
- Ensure minimum hit target size 48x48 (buttons already meet it; verify and adjust if needed) (`home_screen.dart:645–660`).

## 4) Undo Functionality

- Fix Undo logic:
  - Set `currentPlayer = lastMove.player` when undoing (`lib/app/logic/game_logic.dart:74–86`).
  - Allow undo even right after game over (remove `|| isGameOver` early return) (`game_logic.dart:69–73`).
- Enable Undo button when `moveHistory.isNotEmpty`, even if the game is over (`home_screen.dart:559–567`).
- Add visual confirmation (brief toast/snackbar or status text update) when undo executes via `GameProvider.undoLastMove()` (`lib/app/logic/game_provider.dart:104–116`).
- Edge cases: no moves -> disabled; undo to empty board resets winner/winningLine/isGameOver correctly (verified in logic).

## 5) UI/UX Best Practices & Accessibility

- Maintain color contrast for text/icons on glass backgrounds (theme verified in `lib/app/ui/theme.dart`).
- Keep touch targets >= 48x48; verify tiles and buttons sizing.
- Provide consistent feedback: highlight current turn, animate marks, show toasts for actions.

## 6) Quality Assurance & Testing

- Unit tests:
  - `test/game_logic_undo_test.dart`: verify undo restores correct player and supports undo after game over.
- Widget/integration tests:
  - `test/home_controls_visibility_test.dart`: controls visible without scroll.
  - `test/tournament_round_interaction_test.dart`: taps work in rounds 2/3; next round advances.
- End-to-end flows (manual QA): full VS mode and tournament run-through on small/large screens; portrait/landscape.
- Performance profiling: use Flutter DevTools (frame times, rebuild counts). Optimize spacing/filters if needed.
- Build verification: `flutter analyze`, `flutter test`, `flutter build apk`/`ipa`/`windows` with zero errors.

## Implementation Notes

- No secrets logged; keep code clean and structured; follow existing style.
- Keep edits localized; avoid new files unless necessary for tests.
- Atomic commits grouped by feature: nav/app bar; bottom controls; undo logic; tournament interaction; tests.

## Deliverables

- Updated UI with restored nav bar and anchored controls.
- Reliable Undo with visual confirmation.
- Tournament interaction fixed with tap feedback.
- Updated tests (unit + widget) and passing build.
- Short performance notes from profiling.

If this plan looks good, I’ll implement the changes and run the full test/QA pass.