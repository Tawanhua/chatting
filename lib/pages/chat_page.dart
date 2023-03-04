import 'package:chatting/pages/group_info.dart';
import 'package:chatting/service/database_service.dart';
import 'package:chatting/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  String admin = '';

  @override
  void initState() {
    getChatAndAdmin();
    super.initState();
  }

  void getChatAndAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.groupName),
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                  context,
                  GroupInfo(
                    adminName: admin,
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                  ),
                );
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: const Center(
        child: Text('ChatPage'),
      ),
    );
  }
}
