# WhatsApp (clone) - Flutter + PHP

Projet d-appli de messagerie type WhatsApp, avec un frontend Flutter et un backend PHP/MySQL expose via Nginx. Auth par JWT, gestion d-amis, conversations directes, envoi de messages texte ou image et statut en ligne/hors ligne.

## Stack
- Frontend : Flutter 3.7+, Material, `http`, `flutter_secure_storage`, `image_picker`, `emoji_picker_flutter`
- Backend : PHP 8.2 FPM, Nginx, MySQL 8, JWT custom, stockage d-images dans `backend/public/uploads`
- Infra dev : Docker Compose (services `nginx`, `php`, `db`, `phpmyadmin`)

## Lancement rapide (Docker)
1. Prerequis : Docker + Docker Compose installe.
2. Depuis la racine : `docker compose -f backend/docker-compose.yml up --build`
3. Services exposes :
   - API : http://localhost:8080
   - phpMyAdmin : http://localhost:8081 (user `whatsapp` / mdp `whatsapp`)
4. Les scripts SQL d-init + seed sont charges automatiquement (users/tests, messages, demandes d-amis).

## Configuration backend
- JWT : variable d-env `JWT_SECRET` (sinon valeur par defaut `changeme`). A definir dans `backend/.env` ou via `docker compose` (`php` et `nginx` doivent la voir).
- DB : creds definis dans `backend/docker-compose.yml` (host `db`, base `whatsapp`, user/mdp `whatsapp`).
- Uploads : taille max 20 Mo (`uploads.ini`), fichiers ecrits dans `backend/public/uploads`.

## API (principales routes)
- Auth : `POST /api/register`, `POST /api/login` -> JWT + mise a jour du `last_seen`
- Profil : `GET /api/users/{id}`, `GET /api/users/search?phonePrefix=...`, `POST /api/status` (toggle appear_offline), `GET /api/status/{id}`
- Amis : `POST /api/friends/requests` (cree), `GET /api/friends/requests/incoming`, `POST /api/friends/requests/{id}/{accept|decline|cancel}`, `GET /api/friends`
- Conversations : `GET /api/conversations`, `POST /api/conversations/direct`, `POST /api/conversations/{userId}/hide|unhide`
- Messages : `GET /api/messages?with={userId}&after={id}`, `POST /api/messages` (texte), `POST /api/messages` multipart (image/png/jpg/webp + caption optionnel)
- Sante : `GET /api/health`

## Donnees de demo (docker/db)
- Utilisateurs seeds : Alice Dupont (0611111111 / alice123), Bob Martin (0611111112 / bob123), Charlie Durand (0611111113 / charlie123)
- Messages exemples + une demande d-ami (Bob -> Charlie) + amitie Alice/Bob

## Frontend (Flutter)
1. Aller dans `frontend/`, installer les deps : `flutter pub get`
2. Lancer : `flutter run` (mobile) ou `flutter run -d chrome`
3. Base URL API : par defaut `http://10.0.2.2:8080` sur Android (emulateur) et `http://localhost:8080` ailleurs. Override possible via `--dart-define=API_BASE_URL=http://<ip>:8080` ou en passant `baseUrl` a `ApiService`.
4. Stockage local : tokens + creds memorises via `flutter_secure_storage`; statut en ligne/hors ligne synchronise via `/api/status`.

Ecrans clefs :
- Auth (login/register) avec memoire des identifiants
- Liste des conversations (hide/unhide via swipe), recherche par prefixe de numero, creation directe d-une conversation
- Detail utilisateur : envoi/acceptation/annulation de demande d-ami, demarrage de chat
- Chat : envoi texte ou image, rafraichissement des messages, affichage basique de l-historique
- Parametres : toggle apparaitre hors-ligne (appears offline)

## Structure (principaux dossiers)
- `backend/public/index.php` : point d-entree Nginx/PHP, routing minimaliste
- `backend/src` : Core (Router/Request/Response/Auth), Services/Repositories (users, friends, conversations, messages), Support (JWT, phone)
- `backend/docker/*` : images PHP/Nginx + scripts DB init/seed
- `frontend/lib` : `api/` (client HTTP), `domain/` (auth), `presentation/` (pages, controllers), `pages/` (UI), `styles/`, `widget/`

## Commandes utiles
- Flutter : `flutter pub get`, `flutter run`, `flutter test`

## Notes
- Si vous changez le port/API, mettez a jour la base URL dans le frontend.
- Les tokens expirent au bout d-1h (`exp` dans JWT).
- Les conversations cachees restent en base (`conversation_user.hidden_at`) mais sont filtrees cote service.
