# WhatsApp (clone) - Flutter + PHP + PostgreSQL

Projet de messagerie type WhatsApp. Frontend Flutter, backend PHP (API REST JSON), base de données PostgreSQL. Le modèle est volontairement simple pour une soutenance technique claire.

## Objectif
Construire un mini WhatsApp complet côté fonctionnalités essentielles : inscription/connexion, recherche d'utilisateurs, demandes d'amis, conversations directes, messagerie texte, statut en ligne/hors-ligne.

## Fonctionnalités couvertes
- Authentification par numéro de téléphone et mot de passe avec JWT.
- Recherche d'utilisateurs par préfixe de téléphone.
- Système d'amis (demande, acceptation, refus, annulation).
- Liste des conversations directes (basée sur les derniers messages).
- Envoi de messages texte et suppression de ses messages.
- Statut en ligne/hors ligne et "vu à".
- Notifications locales (son + vibration) sur nouveaux messages.
- Sauvegarde sécurisée du token et option "se souvenir de moi".

## Architecture globale
- `frontend/` : application Flutter (UI + logique client + stockage local).
- `backend/` : API PHP (routing, auth, services, repositories).
- PostgreSQL : stockage des utilisateurs, relations d'amis, messages, états de lecture.

Schéma d'échanges :
`Flutter UI -> ApiService -> HTTP JSON -> PHP Router/Controllers -> Services -> Repositories -> PostgreSQL`

## Arborescence complète (hors caches/artefacts)
Dossiers exclus volontairement : `.git`, `.dart_tool`, `build`, `.idea`, `.cache`, `.gradle`, `.cxx`, `.kotlin`.

```text
WhatsApp |-- backend |   |-- config |   |   `-- database.php |   |-- public |   |   `-- index.php |   |-- src |   |   |-- Auth |   |   |   `-- Jwt.php |   |   |-- Controller |   |   |   |-- AuthController.php |   |   |   |-- ConversationController.php |   |   |   |-- FriendController.php |   |   |   |-- MessageController.php |   |   |   `-- UserController.php |   |   |-- Core |   |   |   |-- Auth.php |   |   |   |-- Container.php |   |   |   |-- Request.php |   |   |   |-- Response.php |   |   |   `-- Router.php |   |   |-- Database |   |   |   `-- Connection.php |   |   |-- Repository |   |   |   |-- ConversationRepository.php |   |   |   |-- FriendRepository.php |   |   |   |-- MessageRepository.php |   |   |   `-- UserRepository.php |   |   |-- Service |   |   |   |-- AuthService.php |   |   |   |-- ConversationService.php |   |   |   |-- FriendService.php |   |   |   |-- MessageService.php |   |   |   `-- UserService.php |   |   |-- Support |   |   |   |-- Jwt.php |   |   |   `-- Phone.php |   |   `-- autoload.php |   `-- composer.json |-- frontend |   |-- android |   |   |-- app |   |   |   |-- src |   |   |   |   |-- debug |   |   |   |   |   `-- AndroidManifest.xml |   |   |   |   |-- main |   |   |   |   |   |-- java |   |   |   |   |   |   `-- io |   |   |   |   |   |       `-- flutter |   |   |   |   |   |           `-- plugins |   |   |   |   |   |               `-- GeneratedPluginRegistrant.java |   |   |   |   |   |-- kotlin |   |   |   |   |   |   `-- com |   |   |   |   |   |       `-- whatsapp |   |   |   |   |   |           `-- whatsapp |   |   |   |   |   |               `-- MainActivity.kt |   |   |   |   |   |-- res |   |   |   |   |   |   |-- drawable |   |   |   |   |   |   |   `-- launch_background.xml |   |   |   |   |   |   |-- drawable-v21 |   |   |   |   |   |   |   `-- launch_background.xml |   |   |   |   |   |   |-- mipmap-hdpi |   |   |   |   |   |   |   `-- ic_launcher.png |   |   |   |   |   |   |-- mipmap-mdpi |   |   |   |   |   |   |   `-- ic_launcher.png |   |   |   |   |   |   |-- mipmap-xhdpi |   |   |   |   |   |   |   `-- ic_launcher.png |   |   |   |   |   |   |-- mipmap-xxhdpi |   |   |   |   |   |   |   `-- ic_launcher.png |   |   |   |   |   |   |-- mipmap-xxxhdpi |   |   |   |   |   |   |   `-- ic_launcher.png |   |   |   |   |   |   |-- values |   |   |   |   |   |   |   `-- styles.xml |   |   |   |   |   |   `-- values-night |   |   |   |   |   |       `-- styles.xml |   |   |   |   |   `-- AndroidManifest.xml |   |   |   |   `-- profile |   |   |   |       `-- AndroidManifest.xml |   |   |   `-- build.gradle.kts |   |   |-- gradle |   |   |   `-- wrapper |   |   |       |-- gradle-wrapper.jar |   |   |       `-- gradle-wrapper.properties |   |   |-- .gitignore |   |   |-- build.gradle.kts |   |   |-- gradle.properties |   |   |-- gradlew |   |   |-- gradlew.bat |   |   |-- local.properties |   |   |-- settings.gradle.kts |   |   `-- whatsapp_android.iml |   |-- assets |   |   |-- audio |   |   |   `-- sound.mp3 |   |   `-- icon.png |   |-- ios |   |   |-- Flutter |   |   |   |-- ephemeral |   |   |   |   |-- flutter_lldb_helper.py |   |   |   |   `-- flutter_lldbinit |   |   |   |-- AppFrameworkInfo.plist |   |   |   |-- Debug.xcconfig |   |   |   |-- flutter_export_environment.sh |   |   |   |-- Generated.xcconfig |   |   |   `-- Release.xcconfig |   |   |-- Runner |   |   |   |-- Assets.xcassets |   |   |   |   |-- AppIcon.appiconset |   |   |   |   |   |-- Contents.json |   |   |   |   |   |-- Icon-App-1024x1024@1x.png |   |   |   |   |   |-- Icon-App-20x20@1x.png |   |   |   |   |   |-- Icon-App-20x20@2x.png |   |   |   |   |   |-- Icon-App-20x20@3x.png |   |   |   |   |   |-- Icon-App-29x29@1x.png |   |   |   |   |   |-- Icon-App-29x29@2x.png |   |   |   |   |   |-- Icon-App-29x29@3x.png |   |   |   |   |   |-- Icon-App-40x40@1x.png |   |   |   |   |   |-- Icon-App-40x40@2x.png |   |   |   |   |   |-- Icon-App-40x40@3x.png |   |   |   |   |   |-- Icon-App-50x50@1x.png |   |   |   |   |   |-- Icon-App-50x50@2x.png |   |   |   |   |   |-- Icon-App-57x57@1x.png |   |   |   |   |   |-- Icon-App-57x57@2x.png |   |   |   |   |   |-- Icon-App-60x60@2x.png |   |   |   |   |   |-- Icon-App-60x60@3x.png |   |   |   |   |   |-- Icon-App-72x72@1x.png |   |   |   |   |   |-- Icon-App-72x72@2x.png |   |   |   |   |   |-- Icon-App-76x76@1x.png |   |   |   |   |   |-- Icon-App-76x76@2x.png |   |   |   |   |   `-- Icon-App-83.5x83.5@2x.png |   |   |   |   `-- LaunchImage.imageset |   |   |   |       |-- Contents.json |   |   |   |       |-- LaunchImage.png |   |   |   |       |-- LaunchImage@2x.png |   |   |   |       |-- LaunchImage@3x.png |   |   |   |       `-- README.md |   |   |   |-- Base.lproj |   |   |   |   |-- LaunchScreen.storyboard |   |   |   |   `-- Main.storyboard |   |   |   |-- AppDelegate.swift |   |   |   |-- GeneratedPluginRegistrant.h |   |   |   |-- GeneratedPluginRegistrant.m |   |   |   |-- Info.plist |   |   |   `-- Runner-Bridging-Header.h |   |   |-- Runner.xcodeproj |   |   |   |-- project.xcworkspace |   |   |   |   |-- xcshareddata |   |   |   |   |   |-- IDEWorkspaceChecks.plist |   |   |   |   |   `-- WorkspaceSettings.xcsettings |   |   |   |   `-- contents.xcworkspacedata |   |   |   |-- xcshareddata |   |   |   |   `-- xcschemes |   |   |   |       `-- Runner.xcscheme |   |   |   `-- project.pbxproj |   |   |-- Runner.xcworkspace |   |   |   |-- xcshareddata |   |   |   |   |-- IDEWorkspaceChecks.plist |   |   |   |   `-- WorkspaceSettings.xcsettings |   |   |   `-- contents.xcworkspacedata |   |   |-- RunnerTests |   |   |   `-- RunnerTests.swift |   |   `-- .gitignore |   |-- lib |   |   |-- api |   |   |   `-- apiService.dart |   |   |-- core |   |   |   `-- utils |   |   |       `-- validators.dart |   |   |-- data |   |   |   `-- storage |   |   |       |-- stockageConfidentiel.dart |   |   |       |-- stockageSecurise.dart |   |   |       `-- stockageToken.dart |   |   |-- domain |   |   |   `-- auth |   |   |       |-- authModele.dart |   |   |       `-- authService.dart |   |   |-- models |   |   |   |-- chat.dart |   |   |   |-- demandeAmi.dart |   |   |   |-- profileUser.dart |   |   |   `-- userSummary.dart |   |   |-- pages |   |   |   |-- accueilScreen.dart |   |   |   |-- addScreen.dart |   |   |   |-- compteScreen.dart |   |   |   |-- conversationScreen.dart |   |   |   |-- detailsUserScreen.dart |   |   |   `-- messagerieScreen.dart |   |   |-- presentation |   |   |   |-- auth |   |   |   |   |-- authController.dart |   |   |   |   `-- authPage.dart |   |   |   `-- bootstrap |   |   |       `-- startup.dart |   |   |-- styles |   |   |   |-- appTheme.dart |   |   |   `-- styles.dart |   |   |-- utils |   |   |   |-- appColors.dart |   |   |   |-- notificationFeedback.dart |   |   |   `-- utils.dart |   |   |-- widget |   |   |   |-- avatar.dart |   |   |   |-- conversationTiles.dart |   |   |   `-- messageView.dart |   |   `-- main.dart |   |-- test |   |   `-- widget_test.dart |   |-- web |   |   |-- icons |   |   |   |-- Icon-192.png |   |   |   |-- Icon-512.png |   |   |   |-- Icon-maskable-192.png |   |   |   `-- Icon-maskable-512.png |   |   |-- favicon.png |   |   |-- index.html |   |   `-- manifest.json |   |-- .env |   |-- .flutter-plugins |   |-- .flutter-plugins-dependencies |   |-- .gitignore |   |-- analysis_options.yaml |   |-- pubspec.lock |   |-- pubspec.yaml |   |-- README.md |   `-- whatsapp.iml |-- .gitignore |-- README.md |-- SOUTENANCE_QA.md `-- test_utf8.txt
```

## Backend (PHP)

### Stack et dépendances
- PHP 8+ (sans framework).
- PDO PostgreSQL.
- Auth JWT maison (`backend/src/Support/Jwt.php`).

### Entrée HTTP et routing
- Point d'entrée : `backend/public/index.php`.
- CORS activé (origine `*`).
- Routes déclarées à la main dans le routeur minimaliste (`backend/src/Core/Router.php`).
- Format de réponse standard via `backend/src/Core/Response.php`.

### Structure logique
- `backend/src/Core/*` : Request/Response/Router/Auth/Container.
- `backend/src/Controller/*` : endpoints HTTP, validation légère.
- `backend/src/Service/*` : logique métier.
- `backend/src/Repository/*` : accès DB.
- `backend/src/Support/*` : utilitaires (JWT, téléphone).
- `backend/src/autoload.php` : autoload PSR-4 minimal + chargement `.env`.

### Authentification et sécurité
- JWT signé HS256 (`sub` = user_id, `exp` = 1h).
- Le backend exige `Authorization: Bearer <token>` sur toutes les routes privées.
- Mots de passe stockés hashés via `password_hash` (bcrypt).

### Modèle de données (PostgreSQL)
Il n'y a pas de migrations dans le repo. Voici un schéma minimal cohérent avec les requêtes actuelles.

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  password TEXT NOT NULL,
  last_seen TIMESTAMP,
  appear_offline BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE friend_requests (
  id SERIAL PRIMARY KEY,
  requester_id INT NOT NULL REFERENCES users(id),
  recipient_id INT NOT NULL REFERENCES users(id),
  status VARCHAR(12) NOT NULL CHECK (status IN ('PENDING','ACCEPTED','DECLINED','CANCELED')),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE friendships (
  user_id_a INT NOT NULL REFERENCES users(id),
  user_id_b INT NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id_a, user_id_b),
  CHECK (user_id_a < user_id_b)
);

CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  sender_id INT NOT NULL REFERENCES users(id),
  receiver_id INT NOT NULL REFERENCES users(id),
  content TEXT,
  type VARCHAR(20) NOT NULL DEFAULT 'text',
  media_url TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE conversation_reads (
  user_id INT NOT NULL REFERENCES users(id),
  other_user_id INT NOT NULL REFERENCES users(id),
  last_read_message_id INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, other_user_id)
);
```

Note : `conversation_reads` est créé automatiquement par `backend/src/Repository/ConversationRepository.php`.

### Contrat API (routes)
Toutes les réponses respectent le format :

```json
{ "ok": true, "data": { }, "error": null }
```

Erreurs :

```json
{ "ok": false, "data": { }, "error": { "code": "...", "message": "...", "details": { } } }
```

Routes disponibles :

| Méthode | URL | Auth | Payload | Notes |
|---|---|---|---|---|
| POST | `/api/register` | Non | `{first_name,last_name,phone,password}` | `phone` normalisé FR (10 chiffres). |
| POST | `/api/login` | Non | `{phone,password}` | Retourne `{token}`. |
| GET | `/api/users/search` | Oui | Query `phonePrefix`, `limit` | Préfixe min 2 chiffres. |
| GET | `/api/users` | Oui | Query `limit` | Liste users (hors soi). |
| GET | `/api/users/{id}` | Oui | - | Profil + relation. |
| POST | `/api/friends/requests` | Oui | `{recipientId}` | Crée une demande. |
| POST | `/api/friends/requests/{id}/accept` | Oui | - | Accepte. |
| POST | `/api/friends/requests/{id}/decline` | Oui | - | Refuse. |
| POST | `/api/friends/requests/{id}/cancel` | Oui | - | Annule. |
| GET | `/api/friends/requests/incoming` | Oui | Query `status` | `PENDING` par défaut. |
| GET | `/api/friends` | Oui | - | Liste d'amis. |
| GET | `/api/conversations` | Oui | - | Dernier message + non lus. |
| POST | `/api/conversations/direct` | Oui | `{userId}` | Conversation directe (amis uniquement). |
| GET | `/api/messages` | Oui | Query `with`, `after` | Pagination incrémentale. |
| POST | `/api/messages` | Oui | `{receiver_id,content}` | Texte <= 200 caractères. |
| DELETE | `/api/messages/{id}` | Oui | - | Supprime si auteur. |
| POST | `/api/status` | Oui | `{appear_offline}` | Met à jour le statut. |
| GET | `/api/status/{id}` | Oui | - | Statut d'un user. |

## Frontend (Flutter)

### Stack
- Flutter 3.7+.
- `http`, `flutter_secure_storage`, `flutter_dotenv`, `permission_handler`, `audioplayers`, `vibration`, `intl`.

### Démarrage
- `frontend/.env` définit `API_BASE_URL` (ex: `http://localhost:8080`).
- `frontend/lib/main.dart` instancie `ApiService` et `AuthService`.
- `AppBootstrap` décide d'afficher Auth ou Home en fonction du token.

### Organisation du code
- `frontend/lib/api/apiService.dart` : client HTTP + gestion d'erreurs + token.
- `frontend/lib/domain/auth/*` : logique auth.
- `frontend/lib/presentation/*` : contrôleurs + bootstrap.
- `frontend/lib/pages/*` : écrans UI.
- `frontend/lib/models/*` : mappers JSON -> modèles.
- `frontend/lib/utils/*` : dates, normalisation, notifications.

### Gestion d'état
- Pas de state management externe : `StatefulWidget`, `ChangeNotifier`, `ValueNotifier`.
- `AuthScope` (InheritedNotifier) expose l'état d'auth global.

### Polling (temps réel simulé)
- Conversations : refresh toutes les 1s (`ChatsPage`).
- Messages + statut : refresh toutes les 1s (`ChatDetailPage`).
- Demandes d'amis : refresh toutes les 2s (`MainScaffold`).

### Écrans clés
- Auth (connexion / inscription) : `frontend/lib/presentation/auth/authPage.dart`.
- Accueil + bottom nav : `frontend/lib/pages/accueilScreen.dart`.
- Conversations : `frontend/lib/pages/messagerieScreen.dart`.
- Chat : `frontend/lib/pages/conversationScreen.dart`.
- Ajout d'amis : `frontend/lib/pages/addScreen.dart`.
- Profil / statut : `frontend/lib/pages/compteScreen.dart`.

## Concepts clés expliqués (pour la soutenance)
- JWT : token signé contenant `sub`, `iat`, `exp`. Permet un backend stateless.
- Hachage des mots de passe : `password_hash` + `password_verify` pour éviter le stockage en clair.
- Architecture en couches : Controller (HTTP) -> Service (métier) -> Repository (SQL).
- Normalisation du téléphone : évite les doublons (`0033`, `33`, `0...`).
- Polling vs temps réel : simple à implémenter, coûteux côté réseau/serveur.
- Non-lus : table `conversation_reads` + SQL pour compter les messages non lus.
- Gestion d'état Flutter : `ChangeNotifier` et `ValueNotifier` au lieu de BLoC/Provider.
- Erreurs API : format unique `{ok,data,error}` pour l'UX et le debug.

## Points d'attention / dette technique
- Le backend ne contient pas de migrations ni de seed : il faut créer la DB à la main.
- `backend/src/Core/Container.php` instancie `Auth` avec des paramètres qui ne correspondent pas au constructeur actuel.
- `backend/src/Auth/Jwt.php` fait doublon avec `backend/src/Support/Jwt.php` (legacy).
- `messages.type` et `messages.media_url` sont prévus mais l'API ne gère que le texte.
- `phone_masked` est renvoyé mais n'est pas réellement masqué.
- `last_seen` est mis à jour au login uniquement (pas sur chaque action).
- CORS ouvert à `*` et pas de rate limiting (OK en dev, risqué en prod).

## Lancer le projet (dev)

### Backend
1. Créer une base PostgreSQL et appliquer le schéma SQL ci-dessus.
2. Définir les variables d'environnement : `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `JWT_SECRET`.
3. Lancer un serveur PHP (exemple) :
   - `php -S localhost:8080 -t backend/public`

### Frontend
1. `cd frontend`
2. `flutter pub get`
3. Mettre `API_BASE_URL` dans `frontend/.env`.
4. `flutter run` (mobile) ou `flutter run -d chrome`.

## Checklist soutenance (tout ce qu'il faut maîtriser)
- Architecture globale et rôle de chaque couche.
- Contrat API + format des réponses.
- Modèle de données (tables + relations).
- Flux complet : inscription -> login -> token -> appels protégés.
- Gestion des demandes d'amis (cas d'auto-acceptation).
- Calcul des non-lus et logique de lecture.
- Polling et impact perf/réseau.
- Sécurité (JWT, hash mot de passe, stockage local).
- Limitations actuelles et pistes d'amélioration (WebSocket, push, groupes, fichiers, chiffrement).
