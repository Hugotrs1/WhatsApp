# Guide des fichiers et des flux de données

Ce document explique l'utilité de chaque dossier et fichier du projet, puis décrit le parcours des données pour les actions principales.

**Racine**
| Chemin | Rôle |
|---|---|
| `backend/` | Backend PHP (API REST, logique métier, accès DB). |
| `frontend/` | Frontend Flutter (UI, logique client, stockage local). |
| `.gitignore` | Exclusions Git à la racine. |
| `README.md` | Documentation générale du projet. |
| `SOUTENANCE_QA.md` | Questions/Réponses détaillées pour la soutenance. |
| `GUIDE_FICHIERS_ET_FLUX.md` | Ce guide (fichiers + parcours de données). |

**Backend - dossiers**
| Chemin | Rôle |
|---|---|
| `backend/config/` | Configuration (DB). |
| `backend/public/` | Point d'entrée HTTP (front controller). |
| `backend/src/` | Sources PHP (core, controllers, services, repositories). |
| `backend/composer.json` | Placeholder Composer (vide). |

**Backend - fichiers de configuration et entrée**
| Chemin | Rôle |
|---|---|
| `backend/config/database.php` | Lit les variables d'env DB + JWT. |
| `backend/public/index.php` | Routes API, CORS, création Request + Router. |
| `backend/src/autoload.php` | Chargement `.env` + autoload PSR-4 minimal. |

**Backend - Core**
| Chemin | Rôle |
|---|---|
| `backend/src/Core/Auth.php` | Vérifie JWT et extrait `user_id`. |
| `backend/src/Core/Container.php` | Instancie services et repositories (DI minimal). |
| `backend/src/Core/Request.php` | Parse la requête HTTP, headers, JSON, query. |
| `backend/src/Core/Response.php` | Format JSON standard `{ok,data,error}`. |
| `backend/src/Core/Router.php` | Routing regex + dispatch vers controllers. |

**Backend - Controllers**
| Chemin | Rôle |
|---|---|
| `backend/src/Controller/AuthController.php` | `/api/register`, `/api/login`. |
| `backend/src/Controller/UserController.php` | Recherche, liste, profil, statut. |
| `backend/src/Controller/FriendController.php` | Demandes d'amis + liste amis. |
| `backend/src/Controller/ConversationController.php` | Liste conversations + direct. |
| `backend/src/Controller/MessageController.php` | Envoi, liste, suppression messages. |

**Backend - Services**
| Chemin | Rôle |
|---|---|
| `backend/src/Service/AuthService.php` | Login, register, génération JWT. |
| `backend/src/Service/UserService.php` | Profil, recherche, statut. |
| `backend/src/Service/FriendService.php` | Logique demandes d'amis + amitiés. |
| `backend/src/Service/ConversationService.php` | Liste conversations + non lus. |
| `backend/src/Service/MessageService.php` | Envoi, lecture, suppression messages. |

**Backend - Repositories**
| Chemin | Rôle |
|---|---|
| `backend/src/Repository/UserRepository.php` | CRUD users + recherche + last_seen. |
| `backend/src/Repository/FriendRepository.php` | Demandes d'amis + amitiés. |
| `backend/src/Repository/MessageRepository.php` | CRUD messages + dernières conversations. |
| `backend/src/Repository/ConversationRepository.php` | Non lus + table `conversation_reads`. |

**Backend - Support**
| Chemin | Rôle |
|---|---|
| `backend/src/Support/Jwt.php` | Encode/Decode JWT HS256. |
| `backend/src/Support/Phone.php` | Normalisation et masquage téléphone. |
| `backend/src/Auth/Jwt.php` | Ancien helper JWT (doublon legacy). |

**Backend - Database**
| Chemin | Rôle |
|---|---|
| `backend/src/Database/Connection.php` | Connexion PDO PostgreSQL via env. |

**Frontend - dossiers**
| Chemin | Rôle |
|---|---|
| `frontend/lib/` | Code Flutter (UI, logique, modèles). |
| `frontend/assets/` | Ressources (sons, icônes). |
| `frontend/android/` | Projet Android (Gradle, manifests). |
| `frontend/ios/` | Projet iOS (Xcode, assets). |
| `frontend/web/` | Build web (manifest, index). |
| `frontend/test/` | Tests Flutter. |

**Frontend - fichiers racine**
| Chemin | Rôle |
|---|---|
| `frontend/.env` | Variable `API_BASE_URL`. |
| `frontend/.flutter-plugins` | Liste des plugins Flutter. |
| `frontend/.flutter-plugins-dependencies` | Dépendances plugins. |
| `frontend/.gitignore` | Exclusions Git frontend. |
| `frontend/analysis_options.yaml` | Lints Flutter. |
| `frontend/pubspec.yaml` | Dépendances + assets. |
| `frontend/pubspec.lock` | Versions lockées. |
| `frontend/README.md` | README Flutter par défaut. |
| `frontend/whatsapp.iml` | Config IDE (IntelliJ). |

**Frontend - lib (fichiers)**
| Chemin | Rôle |
|---|---|
| `frontend/lib/main.dart` | Point d'entrée Flutter + bootstrap. |
| `frontend/lib/api/apiService.dart` | Client HTTP + gestion d'erreurs + token. |
| `frontend/lib/core/utils/validators.dart` | Validation des formulaires. |
| `frontend/lib/data/storage/stockageSecurise.dart` | Wrapper `flutter_secure_storage`. |
| `frontend/lib/data/storage/stockageToken.dart` | Lecture/écriture token + décodage JWT. |
| `frontend/lib/data/storage/stockageConfidentiel.dart` | Stockage "se souvenir de moi". |
| `frontend/lib/domain/auth/authModele.dart` | Modèles auth (status, résultats). |
| `frontend/lib/domain/auth/authService.dart` | Use cases auth (login/register/logout). |
| `frontend/lib/presentation/bootstrap/startup.dart` | Bootstrap app + AuthScope. |
| `frontend/lib/presentation/auth/authController.dart` | Contrôleur auth (ChangeNotifier). |
| `frontend/lib/presentation/auth/authPage.dart` | UI login/inscription. |
| `frontend/lib/pages/accueilScreen.dart` | Scaffold principal + bottom nav. |
| `frontend/lib/pages/messagerieScreen.dart` | Liste conversations + recherche. |
| `frontend/lib/pages/conversationScreen.dart` | Chat + messages. |
| `frontend/lib/pages/addScreen.dart` | Recherche utilisateurs / ajout amis. |
| `frontend/lib/pages/detailsUserScreen.dart` | Profil utilisateur + actions amis. |
| `frontend/lib/pages/compteScreen.dart` | Compte + statut en ligne. |
| `frontend/lib/models/chat.dart` | Modèles Chat/Message + mapping API. |
| `frontend/lib/models/demandeAmi.dart` | Modèle demande d'ami. |
| `frontend/lib/models/profileUser.dart` | Modèle profil + relation. |
| `frontend/lib/models/userSummary.dart` | Résumé utilisateur. |
| `frontend/lib/utils/utils.dart` | Helpers (dates, format, parsing). |
| `frontend/lib/utils/appColors.dart` | Couleurs centralisées. |
| `frontend/lib/utils/notificationFeedback.dart` | Son + vibration. |
| `frontend/lib/styles/appTheme.dart` | Thème global Material. |
| `frontend/lib/styles/styles.dart` | Styles UI réutilisables. |
| `frontend/lib/widget/avatar.dart` | Widget avatar. |
| `frontend/lib/widget/conversationTiles.dart` | Tile conversation. |
| `frontend/lib/widget/messageView.dart` | Bulle de message. |

**Frontend - assets**
| Chemin | Rôle |
|---|---|
| `frontend/assets/icon.png` | Icône principale. |
| `frontend/assets/audio/sound.mp3` | Son de notification. |

**Frontend - tests**
| Chemin | Rôle |
|---|---|
| `frontend/test/widget_test.dart` | Test Flutter (vide par défaut). |

**Frontend - web**
| Chemin | Rôle |
|---|---|
| `frontend/web/index.html` | Entrée app web. |
| `frontend/web/manifest.json` | Manifest PWA. |
| `frontend/web/favicon.png` | Favicon. |
| `frontend/web/icons/Icon-192.png` | Icône PWA 192. |
| `frontend/web/icons/Icon-512.png` | Icône PWA 512. |
| `frontend/web/icons/Icon-maskable-192.png` | Icône maskable 192. |
| `frontend/web/icons/Icon-maskable-512.png` | Icône maskable 512. |

**Frontend - Android**
| Chemin | Rôle |
|---|---|
| `frontend/android/app/src/debug/AndroidManifest.xml` | Manifest debug. |
| `frontend/android/app/src/main/AndroidManifest.xml` | Manifest principal. |
| `frontend/android/app/src/profile/AndroidManifest.xml` | Manifest profile. |
| `frontend/android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java` | Enregistrement plugins. |
| `frontend/android/app/src/main/kotlin/com/whatsapp/whatsapp/MainActivity.kt` | Activity principale. |
| `frontend/android/app/src/main/res/drawable/launch_background.xml` | Splash. |
| `frontend/android/app/src/main/res/drawable-v21/launch_background.xml` | Splash v21+. |
| `frontend/android/app/src/main/res/mipmap-hdpi/ic_launcher.png` | Icône hdpi. |
| `frontend/android/app/src/main/res/mipmap-mdpi/ic_launcher.png` | Icône mdpi. |
| `frontend/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` | Icône xhdpi. |
| `frontend/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` | Icône xxhdpi. |
| `frontend/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` | Icône xxxhdpi. |
| `frontend/android/app/src/main/res/values/styles.xml` | Styles Android. |
| `frontend/android/app/src/main/res/values-night/styles.xml` | Styles nuit. |
| `frontend/android/app/build.gradle.kts` | Build module app. |
| `frontend/android/build.gradle.kts` | Build racine Android. |
| `frontend/android/settings.gradle.kts` | Settings Gradle. |
| `frontend/android/gradle.properties` | Propriétés Gradle. |
| `frontend/android/gradlew` | Script Gradle Unix. |
| `frontend/android/gradlew.bat` | Script Gradle Windows. |
| `frontend/android/local.properties` | SDK local (non portable). |
| `frontend/android/gradle/wrapper/gradle-wrapper.jar` | Wrapper Gradle. |
| `frontend/android/gradle/wrapper/gradle-wrapper.properties` | Version Gradle. |
| `frontend/android/.gitignore` | Exclusions Android. |
| `frontend/android/whatsapp_android.iml` | Config IDE Android. |

**Frontend - iOS**
| Chemin | Rôle |
|---|---|
| `frontend/ios/.gitignore` | Exclusions iOS. |
| `frontend/ios/Flutter/AppFrameworkInfo.plist` | Infos framework Flutter. |
| `frontend/ios/Flutter/Debug.xcconfig` | Config debug Xcode. |
| `frontend/ios/Flutter/Release.xcconfig` | Config release Xcode. |
| `frontend/ios/Flutter/Generated.xcconfig` | Config générée. |
| `frontend/ios/Flutter/flutter_export_environment.sh` | Export env Flutter. |
| `frontend/ios/Flutter/ephemeral/flutter_lldb_helper.py` | Helper debug LLDB. |
| `frontend/ios/Flutter/ephemeral/flutter_lldbinit` | Init LLDB. |
| `frontend/ios/Runner/AppDelegate.swift` | AppDelegate iOS. |
| `frontend/ios/Runner/Info.plist` | Plist app. |
| `frontend/ios/Runner/Runner-Bridging-Header.h` | Bridging header. |
| `frontend/ios/Runner/GeneratedPluginRegistrant.h` | Plugins iOS header. |
| `frontend/ios/Runner/GeneratedPluginRegistrant.m` | Plugins iOS impl. |
| `frontend/ios/Runner/Base.lproj/LaunchScreen.storyboard` | Splash storyboard. |
| `frontend/ios/Runner/Base.lproj/Main.storyboard` | Storyboard principal. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json` | Métadonnées icônes. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png` | Icône iOS 20x20@1x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png` | Icône iOS 20x20@2x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png` | Icône iOS 20x20@3x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png` | Icône iOS 29x29@1x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png` | Icône iOS 29x29@2x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png` | Icône iOS 29x29@3x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png` | Icône iOS 40x40@1x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png` | Icône iOS 40x40@2x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png` | Icône iOS 40x40@3x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-50x50@1x.png` | Icône iOS 50x50@1x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-50x50@2x.png` | Icône iOS 50x50@2x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-57x57@1x.png` | Icône iOS 57x57@1x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-57x57@2x.png` | Icône iOS 57x57@2x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png` | Icône iOS 60x60@2x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png` | Icône iOS 60x60@3x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-72x72@1x.png` | Icône iOS 72x72@1x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-72x72@2x.png` | Icône iOS 72x72@2x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png` | Icône iOS 76x76@1x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png` | Icône iOS 76x76@2x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png` | Icône iOS 83.5@2x. |
| `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` | Icône App Store 1024. |
| `frontend/ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json` | Métadonnées LaunchImage. |
| `frontend/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png` | LaunchImage 1x. |
| `frontend/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png` | LaunchImage 2x. |
| `frontend/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png` | LaunchImage 3x. |
| `frontend/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md` | Notes LaunchImage. |
| `frontend/ios/Runner.xcodeproj/project.pbxproj` | Projet Xcode. |
| `frontend/ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata` | Workspace data. |
| `frontend/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist` | Checks workspace. |
| `frontend/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings` | Settings workspace. |
| `frontend/ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme` | Scheme Xcode. |
| `frontend/ios/Runner.xcworkspace/contents.xcworkspacedata` | Workspace data. |
| `frontend/ios/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist` | Checks workspace. |
| `frontend/ios/Runner.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings` | Settings workspace. |
| `frontend/ios/RunnerTests/RunnerTests.swift` | Tests iOS. |

**Parcours de la donnée (actions principales)**

**Inscription**
1. UI `authPage.dart` collecte les champs.
2. `AuthController` (frontend) appelle `AuthService.register`.
3. `ApiService.register` envoie `POST /api/register`.
4. `AuthController::register` (backend) valide + normalise le téléphone.
5. `AuthService::register` hash le mot de passe.
6. `UserRepository::create` écrit en DB.
7. Réponse JSON `{ok:true}` puis message UI.

**Connexion**
1. UI `authPage.dart` -> `AuthController.login`.
2. `AuthService.login` -> `ApiService.login`.
3. Backend `AuthController::login` vérifie credentials.
4. `AuthService::login` génère JWT.
5. Frontend `TokenStorage.saveToken` persiste le token.
6. `AuthScope` passe en `authenticated`.

**Recherche d'utilisateur**
1. UI `addScreen.dart` debounce la saisie.
2. `ApiService.searchUsersByPhonePrefix` -> `GET /api/users/search`.
3. Backend `UserController::search` valide le préfixe.
4. `UserService::searchByPhonePrefix` + `UserRepository::searchByPhonePrefix`.
5. Résultats mappés en `UserSummary`.

**Demande d'ami (création)**
1. UI `detailsUserScreen.dart` -> `ApiService.createFriendRequest`.
2. Backend `FriendController::create`.
3. `FriendService::createRequest` gère PENDING/auto-accept.
4. `FriendRepository` écrit `friend_requests`.
5. Réponse avec `status` + `request_id`.

**Demande d'ami (accept/refus/annulation)**
1. UI -> `ApiService.acceptFriendRequest` ou `decline` ou `cancel`.
2. Backend `FriendController::{accept|decline|cancel}`.
3. `FriendService` vérifie l'auteur + met à jour le statut.
4. `FriendRepository::ensureFriendship` crée l'amitié (accept).

**Liste des amis**
1. UI `messagerieScreen.dart` -> `ApiService.listFriends`.
2. Backend `FriendController::list` -> `FriendService::friends`.
3. `FriendRepository::listFriends` renvoie les amis.

**Liste des conversations**
1. UI `messagerieScreen.dart` -> `ApiService.getConversations`.
2. Backend `ConversationController::list`.
3. `MessageRepository::fetchLastMessagesForUser` récupère le dernier message par contact.
4. `ConversationRepository::getUnreadCounts` calcule les non lus.
5. UI mappe en `Chat`.

**Ouvrir une conversation directe**
1. UI `detailsUserScreen.dart` -> `ApiService.createDirectConversation`.
2. Backend `ConversationController::direct` vérifie l'amitié.
3. `ConversationService::getOrCreateDirect` retourne la fiche conversation.
4. UI crée `Chat` et ouvre `ChatDetailPage`.

**Chargement des messages**
1. `ChatDetailPage._loadMessages` -> `ApiService.getMessages`.
2. Backend `MessageController::list` vérifie l'amitié.
3. `MessageService::fetch` -> `MessageRepository::fetchBetween`.
4. `ConversationRepository::markRead` met à jour `conversation_reads`.
5. UI mappe en `ChatMessage`.

**Envoi d'un message**
1. UI `ChatDetailPage._sendMessage`.
2. `ApiService.sendMessage` -> `POST /api/messages`.
3. Backend `MessageController::send` valide le payload.
4. `MessageService::sendText` -> `MessageRepository::insert`.
5. UI recharge les messages.

**Suppression d'un message**
1. UI swipe -> `ApiService.deleteMessage`.
2. Backend `MessageController::delete`.
3. `MessageService::delete` vérifie l'auteur.
4. `MessageRepository::delete` supprime en DB.

**Statut en ligne/hors ligne**
1. UI `compteScreen.dart` -> `ApiService.updateStatus`.
2. Backend `UserController::updateStatus`.
3. `UserService::updateAppearOffline` -> `UserRepository::updateAppearOffline`.
4. Pour afficher : `ApiService.getStatusForUser` -> `UserController::getStatus`.

**Notifications locales**
1. `messagerieScreen.dart` détecte nouveaux messages.
2. `notificationFeedback.dart` joue son + vibration.

**Déconnexion**
1. UI `accueilScreen.dart` -> `AuthController.logout`.
2. `AuthService.logout` -> `TokenStorage.clearToken`.
3. `AuthScope` passe en `unauthenticated`.
