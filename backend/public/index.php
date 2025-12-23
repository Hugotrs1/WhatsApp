<?php

use App\Controller\AuthController;
use App\Controller\ConversationController;
use App\Controller\FriendController;
use App\Controller\HealthController;
use App\Controller\MessageController;
use App\Controller\UserController;
use App\Core\Auth;
use App\Core\Request;
use App\Core\Response;
use App\Core\Router;
use App\Database\Connection;
use App\Repository\ConversationRepository;
use App\Repository\FriendRepository;
use App\Repository\MessageRepository;
use App\Repository\UserRepository;
use App\Service\AuthService;
use App\Service\ConversationService;
use App\Service\FriendService;
use App\Service\MessageService;
use App\Service\UserService;

require __DIR__ . '/../src/autoload.php';

$request = new Request();
$router = new Router();
$pdo = Connection::get();
$auth = new Auth(getenv('JWT_SECRET') ?: 'changeme');

$userRepo = new UserRepository($pdo);
$friendRepo = new FriendRepository($pdo);
$messageRepo = new MessageRepository($pdo);
$conversationRepo = new ConversationRepository($pdo);

$authService = new AuthService($userRepo, getenv('JWT_SECRET') ?: 'changeme');
$userService = new UserService($userRepo, $friendRepo);
$friendService = new FriendService($friendRepo, $userRepo);
$conversationService = new ConversationService($messageRepo, $conversationRepo, $userRepo);
$messageService = new MessageService($messageRepo, $userRepo, $conversationRepo);

$healthController = new HealthController();
$authController = new AuthController($authService);
$userController = new UserController($userService, $auth);
$friendController = new FriendController($friendService, $userService, $auth);
$conversationController = new ConversationController($conversationService, $auth);
$messageController = new MessageController($messageService, $messageRepo, $auth);

$router->add('GET', '/api/health', fn() => $healthController->health());
$router->add('POST', '/api/register', fn() => $authController->register($request));
$router->add('POST', '/api/login', fn() => $authController->login($request));

$router->add('GET', '/api/users/search', fn() => $userController->search($request));
$router->add('GET', '/api/users/([0-9]+)', fn($id) => $userController->profile($request, $id));
$router->add('POST', '/api/status', fn() => $userController->updateStatus($request));
$router->add('GET', '/api/status/([0-9]+)', fn($id) => $userController->getStatus($request, $id));

$router->add('POST', '/api/friends/requests', fn() => $friendController->create($request));
$router->add('GET', '/api/friends/requests/incoming', fn() => $friendController->incoming($request));
$router->add('POST', '/api/friends/requests/([0-9]+)/accept', fn($id) => $friendController->accept($request, $id));
$router->add('POST', '/api/friends/requests/([0-9]+)/decline', fn($id) => $friendController->decline($request, $id));
$router->add('POST', '/api/friends/requests/([0-9]+)/cancel', fn($id) => $friendController->cancel($request, $id));
$router->add('GET', '/api/friends', fn() => $friendController->listFriends($request));

$router->add('GET', '/api/conversations', fn() => $conversationController->list($request));
$router->add('POST', '/api/conversations/direct', fn() => $conversationController->direct($request));
$router->add('POST', '/api/conversations/([0-9]+)/hide', fn($otherId) => $conversationController->hide($request, $otherId));
$router->add('POST', '/api/conversations/([0-9]+)/unhide', fn($otherId) => $conversationController->unhide($request, $otherId));

$router->add('GET', '/api/messages', fn() => $messageController->list($request));
$router->add('POST', '/api/messages', fn() => $messageController->send($request));

try {
    $router->dispatch($request);
} catch (Throwable $e) {
    Response::error(500, 'Server error', 'server_error', ['message' => $e->getMessage()]);
}
