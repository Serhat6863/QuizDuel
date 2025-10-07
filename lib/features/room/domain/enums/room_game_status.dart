enum RoomGameStatus {
  waiting,
  playing,
  finished,
}

extension RoomGameStatusX on RoomGameStatus {
  bool get isWaiting => this == RoomGameStatus.waiting;
  bool get isPlaying => this == RoomGameStatus.playing;
  bool get isFinished => this == RoomGameStatus.finished;

  String toShortString() {
    return toString().split('.').last;
  }

  static RoomGameStatus fromString(String status) {
    switch (status) {
      case 'waiting':
        return RoomGameStatus.waiting;
      case 'playing':
        return RoomGameStatus.playing;
      case 'finished':
        return RoomGameStatus.finished;
      default:
        return RoomGameStatus.waiting;
    }
  }
}