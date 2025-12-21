import '../models/chat.dart';
import '../models/status.dart';

final DateTime _now = DateTime.now();

List<Chat> chats = [
  Chat(
    id: 'lara',
    title: 'Lara Martins',
    lastMessage: 'On se voit ce soir ?',
    lastActivity: _now.subtract(const Duration(minutes: 12)),
    unreadCount: 3,
    isPinned: true,
    avatarUrl: null,
    messages: [
      ChatMessage(
        id: 'm1',
        sender: 'Lara Martins',
        content: 'On se voit ce soir ?',
        time: _now.subtract(const Duration(minutes: 12)),
      ),
      ChatMessage(
        id: 'm2',
        sender: 'Moi',
        content: 'Yes, 19h ?',
        time: _now.subtract(const Duration(minutes: 10)),
        isMine: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm3',
        sender: 'Lara Martins',
        content: 'Parfait, à toute 👌',
        time: _now.subtract(const Duration(minutes: 6)),
      ),
    ],
  ),
  Chat(
    id: 'studio',
    title: 'Studio Flutter',
    isGroup: true,
    lastMessage: 'Léo: Je push la branche UI',
    lastActivity: _now.subtract(const Duration(minutes: 24)),
    unreadCount: 8,
    avatarUrl: null,
    messages: [
      ChatMessage(
        id: 'm4',
        sender: 'Ana',
        content: 'On révise le backlog ce soir ?',
        time: _now.subtract(const Duration(hours: 2, minutes: 40)),
      ),
      ChatMessage(
        id: 'm5',
        sender: 'Moi',
        content: 'Je peux à 18h30.',
        time: _now.subtract(const Duration(hours: 2, minutes: 35)),
        isMine: true,
        status: MessageStatus.delivered,
      ),
      ChatMessage(
        id: 'm6',
        sender: 'Léo',
        content: 'Je push la branche UI',
        time: _now.subtract(const Duration(minutes: 24)),
      ),
    ],
  ),
  Chat(
    id: 'sofia',
    title: 'Sofia',
    lastMessage: 'J’ai reçu le colis 👍',
    lastActivity: _now.subtract(const Duration(hours: 3, minutes: 5)),
    unreadCount: 0,
    avatarUrl: null,
    messages: [
      ChatMessage(
        id: 'm7',
        sender: 'Sofia',
        content: 'J’ai reçu le colis 👍',
        time: _now.subtract(const Duration(hours: 3, minutes: 5)),
      ),
      ChatMessage(
        id: 'm8',
        sender: 'Moi',
        content: 'Top merci !',
        time: _now.subtract(const Duration(hours: 2, minutes: 58)),
        isMine: true,
        status: MessageStatus.read,
      ),
    ],
  ),
  Chat(
    id: 'victor',
    title: 'Victor Hugo',
    lastMessage: 'Appelle-moi quand t’es dispo.',
    lastActivity: _now.subtract(const Duration(days: 1, hours: 2)),
    unreadCount: 1,
    avatarUrl: null,
    isMuted: true,
    messages: [
      ChatMessage(
        id: 'm9',
        sender: 'Victor Hugo',
        content: 'Appelle-moi quand t’es dispo.',
        time: _now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ],
  ),
];

List<StatusUpdate> statusUpdates = [
  StatusUpdate(
    user: 'Mon statut',
    initials: 'MO',
    avatarUrl: null,
    stories: [
      StatusStory(
        id: 's1',
        time: _now.subtract(const Duration(hours: 1, minutes: 10)),
        caption: 'Pause café ☕️',
        imageUrl: null,
      ),
    ],
  ),
  StatusUpdate(
    user: 'Lara Martins',
    initials: 'LM',
    avatarUrl: null,
    stories: [
      StatusStory(
        id: 's2',
        time: _now.subtract(const Duration(hours: 2, minutes: 5)),
        caption: 'Vue imprenable aujourd’hui',
        imageUrl: null,
      ),
      StatusStory(
        id: 's3',
        time: _now.subtract(const Duration(hours: 3, minutes: 40)),
        imageUrl: null,
      ),
    ],
  ),
  StatusUpdate(
    user: 'Studio Flutter',
    initials: 'SF',
    avatarUrl: null,
    stories: [
      StatusStory(
        id: 's4',
        time: _now.subtract(const Duration(hours: 4, minutes: 12)),
        caption: 'Release 1.0 terminée 🚀',
      ),
    ],
  ),
  StatusUpdate(
    user: 'Sofia',
    initials: 'S',
    avatarUrl: null,
    isMuted: true,
    stories: [
      StatusStory(
        id: 's5',
        time: _now.subtract(const Duration(days: 1, hours: 3)),
        caption: 'Weekend déconnexion 🌿',
      ),
    ],
  ),
];
