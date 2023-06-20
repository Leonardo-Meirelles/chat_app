import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../services/firebase_auth_service.dart';
import '../widgets/chat_messages.dart';
import '../widgets/new_message.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  void setUpPushNotifications() async {
    final firebaseMessaging = FirebaseMessaging.instance;

    await firebaseMessaging.requestPermission();

    // final token = await firebaseMessaging.getToken();
    firebaseMessaging.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setUpPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          TextButton.icon(
            onPressed: () => FirebaseAuthService.logOut(),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Sign Out'),
            style: TextButton.styleFrom(
              iconColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
}
