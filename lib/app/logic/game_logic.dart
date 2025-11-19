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
  List<Move> moveHistory;
  WinningLine? winningLine;
  Player? winner;
  bool isGameOver;

  GameLogic({
    this.boardSize = 3,
    this.winCondition = 3,
    this.players = const [Player.x, Player.o],
  })  : moveHistory = [],
        isGameOver = false {
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(boardSize, (_) => List.filled(boardSize, null));
    currentPlayer = players[0];
    winningLine = null;
    winner = null;
    isGameOver = false;
    moveHistory.clear();
  }

  bool makeMove(int row, int col) {
    if (isGameOver || board![row][col] != null) {
      return false;
    }

    board![row][col] = currentPlayer;
    moveHistory.add(Move(row, col, currentPlayer!));

    final winLine = checkForWin(row, col);
    if (winLine != null) {
      winningLine = winLine;
      winner = currentPlayer;
      isGameOver = true;
    } else if (isBoardFull()) {
      isGameOver = true;
    } else {
      _switchPlayer();
    }

    return true;
  }

  bool undoLastMove() {
    if (moveHistory.isEmpty || isGameOver) {
      return false;
    }

    final lastMove = moveHistory.removeLast();
    board![lastMove.row][lastMove.col] = null;
    winningLine = null;
    winner = null;
    isGameOver = false;

    // Restore current player to the one who made the last move (before it was undone)
    // This is correct because after undoing, it should be that player's turn again
    // If no moves remain, reset to first player
    if (moveHistory.isEmpty) {
      currentPlayer = players[0];
    } else {
      currentPlayer = lastMove.player;
    }

    return true;
  }

  void _switchPlayer() {
    int currentIndex = players.indexOf(currentPlayer!);
    currentPlayer = players[(currentIndex + 1) % players.length];
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

     Player opponent = players.firstWhere((p) => p != aiPlayer);

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
         board![move.row][move.col] = opponent;
         if (_checkWinForPlayer(opponent)) {
           board![move.row][move.col] = null;
           return Move(move.row, move.col, aiPlayer);
         }
         board![move.row][move.col] = null;
       }
     }

     return _getRandomMove();
  }
}
