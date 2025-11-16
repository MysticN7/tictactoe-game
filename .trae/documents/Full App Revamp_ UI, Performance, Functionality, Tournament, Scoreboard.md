## Objectives
- Deliver a polished, modern, high-performance game with professional visuals, smooth interactions, robust logic, and dependable build outputs.
- Lock Tournament to 3-player mode with clear flow and professional UI.
- Fix and redesign the VS win counts at the top with accurate, persistent logic and engaging visuals.

## Architecture & Baseline Review
- Audit current UI, logic, providers and assets:
  - Home UI (`lib/app/ui/screens/home_screen.dart`), Board/UI (`lib/app/ui/widgets/game_board.dart`)
  - Settings (`lib/app/ui/screens/settings_screen.dart`, `settings_root_screen.dart`) and providers (`lib/app/logic/settings_provider.dart`)
  - Game/Tournament logic (`lib/app/logic/game_logic.dart`, `tournament_logic.dart`, `tournament_provider.dart`)
  - Score persistence (`lib/app/logic/scores_provider.dart`)
- Identify redundant rebuilds, heavy filters, and layout bottlenecks.

## Visual & UI Enhancements
- Cohesive theme: align colors, gradients, typography and spacing across Home/Board/Settings/Tournament.
- Home rework:
  - Top section: creative VS scoreboard banner (neon segments, animated counters, player icons/colors, subtle glow).
  - Clear status bar with winner/turn and micro-animations.
- Game Board:
  - Larger markers scaled per board size, crisp visuals, consistent glow and winning pulse.
  - Tile press/turn transitions at 60fps with minimal overdraw.
- Tournament UI overhaul (new professional screen):
  - Round header with progress indicator, animated brackets for 3→2→final.
  - Dynamic player cards (avatars, colors, names), match-up animations, result feedback.
  - Polished Next Round CTA with disabled states and success transitions.
- Settings:
  - Bottom navigation tabs styled to match brand; re-arranged controls with grouped cards.
  - Inputs with validation, error messages, and helper text; consistent controls for toggles and sliders.

## Performance Optimization
- Replace current confetti with custom lightweight particle system:
  - Implement performant Canvas-based particle emitter (no heavy widgets or large blur stacks), tuned for 60fps.
  - Configurable: amount, speed, gravity; disabled when off.
- Reduce BackdropFilter usage; use solid/gradient backgrounds with shadowing and fast blur only where necessary.
- Optimize rebuilds:
  - Wrap heavy widgets in `RepaintBoundary`; convert to `const` where possible; memoize computed styles.
  - Use `Selector`/`Consumer` scoping to minimize provider-triggered rebuilds.
- Animation best practices:
  - Single `TickerProvider` per screen; reuse controllers; avoid overlapping anims.

## Functionality Fixes
- Player name/icon editing:
  - TextFields backed by controllers and validators (length, allowed chars).
  - Live updates stored via provider with proper `notifyListeners()` and persistence.
  - Error states with tooltips/snackbars.
- Interactive feedback:
  - Unified haptic/sound events with guard rails (only when enabled).
  - Disabled states for buttons during transitions; debounce taps.

## Technical Improvements
- Code refactor to current best practices (2025):
  - Split UI into smaller Widgets; maintain state via providers with selective listeners.
  - Strong typing; avoid magic strings; centralize theme constants.
  - Clean imports and consistent naming (package id already updated).
- Optional tech upgrades (scoped to need):
  - Lightweight routing for settings/tournament (keep `Navigator` or consider `go_router` if complexity grows).

## Tournament Logic (3-Player Only)
- Gate tournament mode: only available when 3 players are active.
- Enforce players selection for tournament flows; auto-configure 3-player match settings when entering.
- UI states: Round 1 (3 players), Round 2 (remaining 2), Final (winner vs winner) with clear elimination indication.
- Persist tournament summary in history with timestamps and winners.

## VS Scoreboard (Accurate & Engaging)
- Fix logic:
  - Increment wins only when `game.isGameOver && game.winner != null`.
  - Persist wins by `Player` enum key, not name strings to avoid drift when names change.
  - Initialize once and avoid double-load increments.
- UI:
  - Top banner with per-player columns, animated counters, icons; optional reset control in settings.
  - Ensure numbers reflect actual play (no random values) and survive app restarts.

## Navigation & UX Refinement
- Update settings navigation bar visuals (matching game identity; icons, labels, feedback states).
- Reduce friction:
  - Clear CTAs, tooltips for controls; consistent back behavior; avoid hidden interactions.
  - Streamlined flows: Start Tournament, Restart, Next Round.

## Quality Assurance
- Unit tests:
  - `TournamentLogic` transitions and winner elimination.
  - `ScoresProvider` persistence and accuracy.
- Widget/integration tests:
  - Name/icon validation; scoreboard rendering; confetti toggle behavior.
- Manual checks:
  - Lag-free animations, fast taps, no jank across 3x3/4x4/5x5.

## Deliverables
- Redesigned Home, Board, Tournament, Settings screens with cohesive styling.
- High-performance confetti replacement and 60fps animations.
- Robust name/icon editing with validation.
- Accurate persistent VS scoreboard in top banner.
- Tournament restricted to 3-player mode with polished flow.
- Refactored, clean codebase adhering to modern Flutter practices.
- Tests added and passing; CI builds APK/AAB artifacts.

## Rollout Plan
- Implement changes in phases: Logic → Performance → UI → Navigation → Tests.
- Validate locally and via GitHub Actions; provide artifacts.
- Optional: Configure CI signing for Play Store.

Confirm to proceed and I will implement these enhancements end-to-end, verify with tests and CI, and hand over a production-ready app.