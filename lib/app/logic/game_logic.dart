enum Player { x, o, triangle }

class Move {
  final int row;
  final int col;
  final Player player;

  Move(this.row, this.col, this.player);
}

class WinningLine {
  final List<int> positions; // Flat indices
  final Player player;

  WinningLine(this.positions, this.player);
}

class GameLogic {
  List<List<Player?>>? board;
  int boardSize;
  int winCondition;
  Player? currentPlayer;
  List<Player> players;
  List<Player> activePlayers;
  List<Move> moveHistory;
  WinningLine? winningLine; // The most recent winning line
  List<WinningLine> allWinningLines; // All winning lines in the current session (for survival mode)
  Player? winner; // The most recent winner
  List<Player> winners; // All winners in the current session
  bool isGameOver;

  GameLogic({
    this.boardSize = 3,
    this.winCondition = 3,
    this.players = const [Player.x, Player.o],
  })  : moveHistory = [],
        activePlayers = [],
        allWinningLines = [],
        winners = [],
        isGameOver = false {
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(boardSize, (_) => List.filled(boardSize, null));
    activePlayers = List.from(players);
    currentPlayer = activePlayers.isNotEmpty ? activePlayers[0] : null;
    winningLine = null;
    allWinningLines = [];
    winner = null;
    winners = [];
    isGameOver = false;
    moveHistory.clear();
  }

  bool makeMove(int row, int col) {
    if (isGameOver || board![row][col] != null || currentPlayer == null) {
      return false;
    }

    board![row][col] = currentPlayer;
    moveHistory.add(Move(row, col, currentPlayer!));

    final winLine = checkForWin(row, col);
    if (winLine != null) {
      winningLine = winLine;
      allWinningLines.add(winLine);
      winner = currentPlayer;
      winners.add(currentPlayer!);
      
      // Survival Mode Logic:
      // If there are more than 2 active players, the winner steps out, but game continues.
      if (activePlayers.length > 2) {
        activePlayers.remove(currentPlayer);
        // Reset current player to the next active player
        // We need to find who is next.
        // Since we just removed the current player, we can just pick the next one in the list (wrapping around)
        // But wait, we need to be careful about turn order.
        // Let's just pick the first active player for now or maintain index.
        if (activePlayers.isNotEmpty) {
           // Logic to find next player:
           // If we had [A, B, C] and A moved and won.
           // A is removed. Active: [B, C].
           // Next turn should be B.
           // If B moved and won. Active: [A, C].
           // Next turn should be C.
           
           // Simple approach: Just take the next one in the active list.
           // Since we removed the current one, the indices shift.
           // We should probably just set it to the first one or keep rotation.
           // Let's use _switchPlayer logic but adapted.
           
           // Actually, if the current player is removed, we just need to set currentPlayer to someone else.
           // Let's set it to the next player in the original `players` list that is still active.
           _switchPlayerAfterWin();
        }
        isGameOver = false; // Game continues
      } else {
        // Standard win or final survivor
        isGameOver = true;
      }
    } else if (isBoardFull()) {
      isGameOver = true;
    } else {
      _switchPlayer();
    }

    return true;
  }

  bool undoLastMove() {
    if (moveHistory.isEmpty) {
      return false;
    }

    // If game was over, it might not be anymore
    // If a player won and was removed, we need to add them back?
    // Undo in survival mode is tricky.
    // For now, let's support simple undo.
    
    final lastMove = moveHistory.removeLast();
    board![lastMove.row][lastMove.col] = null;
    
    // If this move caused a win
    if (winners.contains(lastMove.player)) {
       winners.remove(lastMove.player);
       winner = winners.isNotEmpty ? winners.last : null;
       
       // Remove the winning line associated with this move
       // This is a simplification. Ideally we track which move caused which win.
       if (allWinningLines.isNotEmpty) {
         allWinningLines.removeLast();
         winningLine = allWinningLines.isNotEmpty ? allWinningLines.last : null;
       }
       
       // If player was removed from active, add them back
       if (!activePlayers.contains(lastMove.player)) {
         // We need to insert them back in correct order? 
         // Or just add them and sort by original order?
         activePlayers.add(lastMove.player);
         activePlayers.sort((a, b) => players.indexOf(a).compareTo(players.indexOf(b)));
       }
    }
    
    isGameOver = false;
    currentPlayer = lastMove.player;

    return true;
  }

  void _switchPlayer() {
    if (activePlayers.isEmpty) return;
    int currentIndex = activePlayers.indexOf(currentPlayer!);
    if (currentIndex == -1) {
      // Should not happen unless player was removed
      currentPlayer = activePlayers[0];
    } else {
      currentPlayer = activePlayers[(currentIndex + 1) % activePlayers.length];
    }
  }
  
  void _switchPlayerAfterWin() {
    // Called when current player just won and was removed from activePlayers
    // We need to determine who plays next.
    // Since we removed the player, we can't use their index.
    // But we know the turn order is fixed in `players`.
    // We want the next active player after the one who just won.
    
    // Find the index of the winner in the original list
    int winnerIndex = players.indexOf(winner!);
    
    // Search forward from there for the first active player
    for (int i = 1; i < players.length; i++) {
      int nextIndex = (winnerIndex + i) % players.length;
      Player candidate = players[nextIndex];
      if (activePlayers.contains(candidate)) {
        currentPlayer = candidate;
        return;
      }
    }
  }

  bool isBoardFull() {
    return board!.every((row) => row.every((cell) => cell != null));
  }

  WinningLine? checkForWin(int row, int col) {
    Player? player = board![row][col];
    if (player == null) return null;

    // Check all directions
    final horizontal = _checkLine(player, row, col, 1, 0);
    if (horizontal != null) return horizontal;

    final vertical = _checkLine(player, row, col, 0, 1);
    if (vertical != null) return vertical;

    final diagonal = _checkLine(player, row, col, 1, 1);
    if (diagonal != null) return diagonal;

    final antiDiagonal = _checkLine(player, row, col, 1, -1);
    if (antiDiagonal != null) return antiDiagonal;

    return null;
  }

  WinningLine? _checkLine(Player player, int row, int col, int dr, int dc) {
    List<int> positions = [];
    int count = 1;
    positions.add(row * boardSize + col);

    // Check in the positive direction
    for (int i = 1; i < winCondition; i++) {
      int r = row + i * dr;
      int c = col + i * dc;
      if (r >= 0 && r < boardSize && c >= 0 && c < boardSize && board![r][c] == player) {
        count++;
        positions.add(r * boardSize + c);
      } else {
        break;
      }
    }

    // Check in the negative direction
    for (int i = 1; i < winCondition; i++) {
      int r = row - i * dr;
      int c = col - i * dc;
      if (r >= 0 && r < boardSize && c >= 0 && c < boardSize && board![r][c] == player) {
        count++;
        positions.add(r * boardSize + c);
      } else {
        break;
      }
    }

    if (count >= winCondition) {
      positions.sort();
      return WinningLine(positions, player);
    }
    return null;
  }

  void reset() {
    _initializeBoard();
  }

  void updateBoardSize(int newSize) {

    boardSize = newSize;
    _initializeBoard();
  }

  void updateWinCondition(int newCondition) {
    winCondition = newCondition;
    _initializeBoard();
  }

  void updatePlayers(List<Player> newPlayers) {
    players = newPlayers;
    _initializeBoard();
  }

  // AI Logic
  Move? getBestMove(Player aiPlayer, int difficultyLevel) {
    // difficultyLevel: 0=Easy, 1=Medium, 2=Hard, 3=Impossible
    
    // For larger boards, use heuristic to avoid performance issues
    if (boardSize > 3) {
      return _getHeuristicMove(aiPlayer, difficultyLevel);
    }

    // Random move for Easy
    if (difficultyLevel == 0) {
      return _getRandomMove();
    }

    // Medium: 50% chance of random, 50% best
    if (difficultyLevel == 1) {
      if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
        return _getRandomMove();
      }
    }

    // Hard/Impossible: Minimax
    // For Hard (level 2), we could add a small chance of error, but for now let's make it strong
    // Impossible (level 3) is perfect play
    
    int bestScore = -10000;
    Move? bestMove;
    List<Move> availableMoves = _getAvailableMoves();

    if (availableMoves.isEmpty) return null;

    // Optimization: If first move, take center or corner
    if (availableMoves.length == boardSize * boardSize) {
       return Move(1, 1, aiPlayer);
    }

    for (var move in availableMoves) {
      board![move.row][move.col] = aiPlayer;
      int score = _minimax(board!, 0, false, aiPlayer, -10000, 10000);
      board![move.row][move.col] = null;

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove ?? _getRandomMove();
  }

  int _minimax(List<List<Player?>> board, int depth, bool isMaximizing, Player aiPlayer, int alpha, int beta) {
    // In survival mode, we might have multiple opponents.
    // For 3x3 standard, it's usually 1v1.
    // If we are in 3-player mode, minimax is complex.
    // For now, let's assume standard 2-player minimax for 3x3.
    // If 3 players are active, we might need to just use Heuristic or a simplified MaxN.
    // But since we switch to Heuristic for >3x3, and 3-player on 3x3 is chaotic, 
    // maybe we should force Heuristic for >2 players?
    
    if (players.length > 2) {
       // Fallback to heuristic for >2 players to avoid complexity of MaxN
       return 0; 
    }

    Player opponent = players.firstWhere((p) => p != aiPlayer);
    
    if (_checkWinForPlayer(aiPlayer)) return 10 - depth;
    if (_checkWinForPlayer(opponent)) return depth - 10;
    if (_isBoardFullInternal()) return 0;

    if (isMaximizing) {
      int bestScore = -10000;
      for (var move in _getAvailableMoves()) {
        board[move.row][move.col] = aiPlayer;
        int score = _minimax(board, depth + 1, false, aiPlayer, alpha, beta);
        board[move.row][move.col] = null;
        bestScore = score > bestScore ? score : bestScore;
        alpha = alpha > bestScore ? alpha : bestScore;
        if (beta <= alpha) break;
      }
      return bestScore;
    } else {
      int bestScore = 10000;
      for (var move in _getAvailableMoves()) {
        board[move.row][move.col] = opponent;
        int score = _minimax(board, depth + 1, true, aiPlayer, alpha, beta);
        board[move.row][move.col] = null;
        bestScore = score < bestScore ? score : bestScore;
        beta = beta < bestScore ? beta : bestScore;
        if (beta <= alpha) break;
      }
      return bestScore;
    }
  }

  bool _checkWinForPlayer(Player p) {
    // Simplified check for minimax state
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board![i][j] == p) {
           if (_checkLine(p, i, j, 1, 0) != null) return true;
           if (_checkLine(p, i, j, 0, 1) != null) return true;
           if (_checkLine(p, i, j, 1, 1) != null) return true;
           if (_checkLine(p, i, j, 1, -1) != null) return true;
        }
      }
    }
    return false;
  }

  bool _isBoardFullInternal() {
    return board!.every((row) => row.every((cell) => cell != null));
  }

  List<Move> _getAvailableMoves() {
    List<Move> moves = [];
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board![i][j] == null) {
          moves.add(Move(i, j, currentPlayer!)); // Player doesn't matter for location
        }
      }
    }
    return moves;
  }

  Move? _getRandomMove() {
    List<Move> moves = _getAvailableMoves();
    if (moves.isEmpty) return null;
    moves.shuffle();
    return moves.first;
  }

  Move? _getHeuristicMove(Player aiPlayer, int difficulty) {
     // Simple heuristic for larger boards:
     // 1. Win if possible
     // 2. Block if opponent winning
     // 3. Pick center/random
     
     List<Move> moves = _getAvailableMoves();
     if (moves.isEmpty) return null;

     // Identify opponents
     List<Player> opponents = players.where((p) => p != aiPlayer).toList();

     // Check for winning move
     for (var move in moves) {
       board![move.row][move.col] = aiPlayer;
       if (_checkWinForPlayer(aiPlayer)) {
         board![move.row][move.col] = null;
         return move;
       }
       board![move.row][move.col] = null;
     }

     // Check for blocking move (Medium+)
     if (difficulty > 0) {
       for (var move in moves) {
         for (var opponent in opponents) {
            board![move.row][move.col] = opponent;
            if (_checkWinForPlayer(opponent)) {
              board![move.row][move.col] = null;
              return Move(move.row, move.col, aiPlayer);
            }
            board![move.row][move.col] = null;
         }
       }
     }

     return _getRandomMove();
  }
}
