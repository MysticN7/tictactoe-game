import os

# Fix home_screen.dart
path_home = r'c:\tictactoe_game - Copy\lib\app\ui\screens\home_screen.dart'
if os.path.exists(path_home):
    with open(path_home, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    # Keep 0-356 (lines 1-357)
    # Skip 357-551 (lines 358-552)
    # Keep 552-end (lines 553-end)
    # Note: Indices are 0-based. Line 358 is index 357. Line 553 is index 552.
    # So we want lines[:357] and lines[552:]
    new_lines_home = lines[:357] + lines[552:]
    with open(path_home, 'w', encoding='utf-8') as f:
        f.writelines(new_lines_home)
    print(f"Fixed home_screen.dart. Old lines: {len(lines)}, New lines: {len(new_lines_home)}")
else:
    print("home_screen.dart not found")

# Fix game_board.dart
path_board = r'c:\tictactoe_game - Copy\lib\app\ui\widgets\game_board.dart'
if os.path.exists(path_board):
    with open(path_board, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    # Remove lines 251-252 (indices 250-251)
    # Keep 0-249, Skip 250-251, Keep 252-end
    new_lines_board = lines[:250] + lines[252:]
    with open(path_board, 'w', encoding='utf-8') as f:
        f.writelines(new_lines_board)
    print(f"Fixed game_board.dart. Old lines: {len(lines)}, New lines: {len(new_lines_board)}")
else:
    print("game_board.dart not found")
