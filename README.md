# WhatsApp (clone)

Messagerie mobile inspirée de WhatsApp, réalisée en formation : une application Flutter et une API REST en PHP, écrite sans framework.

## Fonctionnalités

- Inscription et connexion par numéro de téléphone (JWT)
- Recherche d'utilisateurs et demandes d'amis
- Conversations et messages texte
- Statut en ligne et « vu à »
- Notification (son et vibration) à chaque nouveau message

## Stack

- `frontend/` : Flutter, Dart
- `backend/` : PHP 8 sans framework, PostgreSQL

## Lancer

```bash
# Backend : créer la base avec schema.sql, renseigner DB_HOST, DB_PORT, DB_NAME,
# DB_USER, DB_PASSWORD et JWT_SECRET, puis :
php -S localhost:8080 -t backend/public

# Frontend : renseigner API_BASE_URL dans frontend/.env, puis :
cd frontend
flutter pub get
flutter run
```
