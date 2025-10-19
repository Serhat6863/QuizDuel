import 'package:flutter_test/flutter_test.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:quizduel/features/game/data/model/quiz_model.dart';
import 'package:quizduel/features/room/data/model/room_model.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';

void main() {
  group("RoomModel", () {
    final mockUser = UserModel(
      id: "u1",
      email: "test@example.com",
      username: "Serhat",
      isReady: true,
      score: 100,
      isOnline: true,
      deviceId: "device-123",
    );

    final mockQuiz = QuizModel(
      category: "Science",
      difficulty: "Easy",
      question: "What is H2O?",
      options: ["Water", "Fire", "Earth", "Air"],
      correctAnswerIndex: 0,
    );

    final mockRoom = RoomModel(
      roomId: "r1",
      roomName: "Test Room",
      hostId: "h1",
      user: [mockUser],
      status: RoomGameStatus.waiting,
      joinCode: "ABCD",
      createdAt: DateTime.parse("2024-01-01T12:00:00Z"),
      maxPlayers: 4,
      quiz: [mockQuiz],
    );

    final mockJson = {
      "roomId": "r1",
      "roomName": "Test Room",
      "hostId": "h1",
      "user": {
        "u1": {
          "id": "u1",
          "email": "test@example.com",
          "username": "Serhat",
          "isReady": true,
          "score": 100,
        }
      },
      "status": "waiting",
      "joinCode": "ABCD",
      "createdAt": "2024-01-01T12:00:00Z",
      "maxPlayers": 4,
      "quiz": [
        {
          "category": "Science",
          "difficulty": "Easy",
          "question": "What is H2O?",
          "options": ["Water", "Fire", "Earth", "Air"],
          "correctAnswerIndex": 0,
        }
      ],
    };

    test("✅ fromJson() retourne un RoomModel correct", () {
      final result = RoomModel.fromJson(mockJson);

      expect(result.roomId, equals("r1"));
      expect(result.roomName, equals("Test Room"));
      expect(result.hostId, equals("h1"));
      expect(result.user.length, equals(1));
      expect(result.user.first.username, equals("Serhat"));
      expect(result.status, equals(RoomGameStatus.waiting));
      expect(result.joinCode, equals("ABCD"));
      expect(result.maxPlayers, equals(4));
      expect(result.quiz.length, equals(1));
      expect(result.quiz.first.category, equals("Science"));
    });

    test("✅ toJson() retourne la map correcte", () {
      final json = mockRoom.toJson();

      expect(json["roomId"], equals("r1"));
      expect(json["roomName"], equals("Test Room"));
      expect(json["hostId"], equals("h1"));
      expect(json["user"], isA<Map>());
      expect((json["user"] as Map).containsKey("u1"), isTrue);
      expect(json["status"], equals("waiting"));
      expect(json["joinCode"], equals("ABCD"));
      expect(json["maxPlayers"], equals(4));
      expect(json["quiz"], isA<List>());
      expect(json["quiz"].first["category"], equals("Science"));
    });

    test("✅ toEntity() retourne une RoomEntity correcte", () {
      final entity = mockRoom.toEntity();

      expect(entity.roomId, equals("r1"));
      expect(entity.roomName, equals("Test Room"));
      expect(entity.hostId, equals("h1"));
      expect(entity.user.first.username, equals("Serhat"));
      expect(entity.status, equals(RoomGameStatus.waiting));
      expect(entity.quiz.first.category, equals("Science"));
    });

    test("✅ fromJson() gère les valeurs manquantes sans erreur", () {
      final emptyJson = <String, dynamic>{};
      final result = RoomModel.fromJson(emptyJson);

      expect(result.roomId, equals(''));
      expect(result.roomName, equals('Room'));
      expect(result.hostId, equals(''));
      expect(result.user, isEmpty);
      expect(result.status, equals(RoomGameStatus.waiting));
      expect(result.maxPlayers, equals(4));
      expect(result.quiz, isEmpty);
    });
  });
}
