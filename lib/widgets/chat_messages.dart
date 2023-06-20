import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedInUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (ctx, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages'),
          );
        }

        if (snapshots.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        final messages = snapshots.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = messages[index].data();
            final nextChatMessage =
                index + 1 < messages.length ? messages[index + 1].data() : null;
            final currentMessageUserId = chatMessage['user_id'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['user_id'] : null;
            final isNextUserSameAsCurrentUser =
                currentMessageUserId == nextMessageUserId;

            if (isNextUserSameAsCurrentUser) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: loggedInUser!.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['user_image'],
                username: chatMessage['user_name'],
                message: chatMessage['text'],
                isMe: loggedInUser!.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
