# 🧠 QuizDuel – Flutter Multiplayer Quiz App

![Flutter](https://img.shields.io/badge/Flutter-3.8.0+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.4+-blue?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%26%20Realtime%20DB-orange?logo=firebase)
![BLoC](https://img.shields.io/badge/State%20Management-BLoC-purple)
![API](https://img.shields.io/badge/API-Open%20Trivia%20DB-green)
![Status](https://img.shields.io/badge/Status-En%20cours-yellow)

---

## 📖 Introduction

**QuizDuel** est une application Flutter de **quiz multijoueur en ligne** avec gestion des *rooms*, synchronisation en temps réel et récupération dynamique de questions via l’**API Open Trivia DB**.  
Ce projet combine **Firebase Firestore**, **Realtime Database**, et **Retrofit/Dio** pour offrir une expérience de jeu fluide et connectée.

L’objectif : permettre à plusieurs joueurs de rejoindre une *room*, participer à un quiz en simultané et comparer leurs scores instantanément.

---

## 🌟 Fonctionnalités principales (en cours)

- 🏠 **Création & jointure de rooms multijoueur**  
- 🔥 **Synchronisation temps réel** via **Firebase Realtime Database**  
- 🧩 **Questions dynamiques** depuis l’**API Open Trivia DB**  
- 🧠 **Gestion des joueurs et du host** (créateur de la room)  
- 🏆 **Affichage du classement final** après chaque partie  
- 💬 **Interface fluide et moderne** avec gestion d’état via **BLoC**

---

## 🛠️ Technologies utilisées

- **Framework** : Flutter `3.8.0+`  
- **Langage** : Dart  
- **Architecture** : Clean (Domain / Data / Presentation)  
- **State Management** : BLoC  
- **Backend** : Firebase (Firestore + Realtime Database)  
- **API externe** : [Open Trivia DB](https://opentdb.com/)  
- **HTTP Client** : Dio + Retrofit  

---

## 📦 Packages principaux

| Package | Description |
|----------|-------------|
| `flutter_bloc` | Gestion d’état réactive avec BLoC |
| `firebase_core`, `cloud_firestore`, `firebase_database` | Backend et données en temps réel |
| `dio`, `retrofit`, `json_serializable` | Appels API Open Trivia et parsing JSON |
| `equatable` | Modèles immuables et égalité structurée |
| `awesome_snackbar_content` | Messages visuels personnalisés |

---

## ⚙️ Installation

### Prérequis
- Flutter SDK `3.8.0+`  
- Android Studio ou VS Code  
- Un émulateur ou appareil physique  
- Une configuration Firebase valide (`firebase_options.dart` déjà présent)  

### Étapes
```bash
# Cloner le projet
git clone https://github.com/votre-username/quizduel.git

# Aller dans le dossier
cd quizduel

# Installer les dépendances
flutter pub get

# Lancer l’application
flutter run

```
---

🏗️ Architecture du projet (en cours)
```
QuizDuel/
├── lib/
│   ├── core/
│   │   ├── error/                  # Gestion des erreurs
│   │   └── utils/                  # Méthodes utilitaires et constantes
│   ├── features/
│   │   ├── auth/                   # Authentification utilisateur
│   │   │   ├── data/
│   │   │   │   ├── model/
│   │   │   │   ├── repository/
│   │   │   │   └── service/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── screen/
│   │   │       └── widget/
│   │   ├── room/                   # Gestion des rooms
│   │   │   ├── data/
│   │   │   │   ├── model/
│   │   │   │   ├── repository/
│   │   │   │   └── service/
│   │   │   ├── domain/
│   │   │   │   ├── entity/
│   │   │   │   ├── enums/
│   │   │   │   └── repository/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── screen/
│   │   │       └── widget/
│   │   └── game/                   # Logique du quiz
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │           ├── bloc/
│   │           ├── screen/
│   │           └── widget/
│   ├── firebase_options.dart       # Configuration Firebase
│   └── main.dart                   # Point d’entrée principal
├── assets/
│   └── images/                     # Ressources visuelles
├── test/
│   └── ...                         # Tests unitaires à venir
└── pubspec.yaml
```

---

## 📅 Statut du projet

🚧 **En cours de développement**

L’application **QuizDuel** est actuellement en phase de développement actif.  
Certaines fonctionnalités clés sont déjà terminées, tandis que d’autres sont encore en cours d’implémentation ou prévues dans les prochaines itérations.

| 🧩 Fonctionnalité | 📌 Statut | 📝 Détails |
|------------------|-----------|------------|
| **Authentification utilisateur** | ✅ Terminée | Connexion et gestion des utilisateurs via Firebase Auth |
| **Création / jointure de room** | ✅ Terminée | Les joueurs peuvent créer ou rejoindre une partie en temps réel |
| **Suppression automatique d’une room** | ✅ Terminée | La room est supprimée quand le host quitte la partie |
| **Intégration API Open Trivia** | ✅ Terminée | Récupération des questions de quiz avec Retrofit & Dio |
| **Système de quiz multijoueur** | 🚧 En cours | Synchronisation des questions et réponses entre plusieurs joueurs |
| **Classement final & interface UI** | 🔜 À venir | Affichage des scores finaux et amélioration de la présentation |
| **Refactorisation architecture** | 🔜 Prévue | Optimisation du code et restructuration des couches Domain/Data/Presentation |

---

## Contact  

Si vous souhaitez en savoir plus sur ce projet ou discuter de développement Flutter, n’hésitez pas à me contacter :  

**kurkluserhat@gmail.com**   
[GitHub – Serhat6863](https://github.com/Serhat6863)  

---

✨ Développé avec **Flutter**  
© 2025 – Serhat KÜRKLÜ

