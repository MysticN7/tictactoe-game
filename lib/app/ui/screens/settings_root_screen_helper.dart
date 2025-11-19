  String _getBoardTip(int size) {
    switch (size) {
      case 3: return "Classic mode. Best with 3 to win.";
      case 4: return "More space. Try 4 to win for a challenge.";
      case 5: return "Expert mode. 4 or 5 to win recommended.";
      default: return "";
    }
  }
