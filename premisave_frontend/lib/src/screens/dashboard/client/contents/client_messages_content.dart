import 'package:flutter/material.dart';

class ClientMessagesContent extends StatefulWidget {
  const ClientMessagesContent({super.key});

  @override
  State<ClientMessagesContent> createState() => _ClientMessagesContentState();
}

class _ClientMessagesContentState extends State<ClientMessagesContent> {
  Map<String, dynamic>? _selectedChat;

  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'John Mwangi',
      'role': 'Host - Sky Gardens',
      'lastMessage': 'Check-in time is 2 PM. Looking forward!',
      'time': '10:30 AM',
      'unread': 2,
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
    },
    {
      'id': '2',
      'name': 'Premisave Support',
      'role': 'Customer Support',
      'lastMessage': 'Your payment has been confirmed',
      'time': 'Yesterday',
      'unread': 0,
      'avatar': 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=100',
    },
    {
      'id': '3',
      'name': 'Sarah Kimani',
      'role': 'Property Owner - Villa',
      'lastMessage': 'WiFi password: Premisave2024',
      'time': '2 days ago',
      'unread': 1,
      'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _chatMessages = {
    '1': [
      {'sender': 'host', 'message': 'Hello! Welcome to Sky Gardens', 'time': '9:00 AM'},
      {'sender': 'me', 'message': 'Hi! Thanks, excited to check in', 'time': '9:05 AM'},
      {'sender': 'host', 'message': 'Check-in time is 2 PM. Looking forward!', 'time': '10:30 AM'},
    ],
    '2': [
      {'sender': 'support', 'message': 'Your payment of KES 42,500 has been confirmed', 'time': 'Yesterday'},
      {'sender': 'me', 'message': 'Great, thanks for the update', 'time': 'Yesterday'},
    ],
    '3': [
      {'sender': 'owner', 'message': 'Hi! WiFi password: Premisave2024', 'time': '2 days ago'},
      {'sender': 'me', 'message': 'Got it, thank you!', 'time': '2 days ago'},
    ],
  };

  void _openChat(Map<String, dynamic> chat) {
    setState(() {
      _selectedChat = chat;
    });
  }

  void _closeChat() {
    setState(() {
      _selectedChat = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 768;

    if (_selectedChat != null) {
      return _buildChatScreen(_selectedChat!);
    }

    return _buildConversationsList(isSmall);
  }

  Widget _buildConversationsList(bool isSmall) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(),
          const SizedBox(height: 24),
          _MessageSearch(),
          const SizedBox(height: 24),
          _RecentConversations(
            conversations: _conversations,
            onChatTap: _openChat,
          ),
        ],
      ),
    );
  }

  Widget _buildChatScreen(Map<String, dynamic> chat) {
    final messages = _chatMessages[chat['id']] ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _closeChat,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chat['name'], style: const TextStyle(fontSize: 16)),
            Text(chat['role'], style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['sender'] == 'me';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(chat['avatar']),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['message'],
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['time'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isMe) const SizedBox(width: 8),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chat with hosts and support',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.message, color: Colors.blue, size: 30),
          ),
        ],
      ),
    );
  }
}

class _MessageSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

class _RecentConversations extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;
  final Function(Map<String, dynamic>) onChatTap;

  const _RecentConversations({
    required this.conversations,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Conversations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...conversations.map((chat) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => onChatTap(chat),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.grey[50]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(chat['avatar']),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat['name'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat['role'],
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat['lastMessage'],
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chat['time'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      if (chat['unread'] > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chat['unread'].toString(),
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }
}