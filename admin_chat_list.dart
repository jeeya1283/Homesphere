import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homesphere/chat_page.dart';

class AdminList extends StatefulWidget {
  final User user;

  // final String recipientId;

  AdminList({
    super.key,
    required this.user,
  });

  @override
  _AdminListState createState() => _AdminListState();
}

class _AdminListState extends State<AdminList> {
  final TextEditingController _messageController = TextEditingController();
  final CollectionReference _messagesCollection = FirebaseFirestore.instance.collection('messages');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final userDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              final userDoc = userDocs[index];
              return ListTile(
                title: Text(userDoc['firstname']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(userId: userDoc.id, recipientId: widget.user.uid,),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class UserChatPage extends StatelessWidget {
  final String userId;

  const UserChatPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with User'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('messages')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final messageDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: messageDocs.length,
            itemBuilder: (context, index) {
              final messageDoc = messageDocs[index];
              return ListTile(
                title: Text(messageDoc['message']),
                // subtitle: Text(messageDoc['timestamp']),
              );
            },
          );
        },
      ),
    );
  }
}