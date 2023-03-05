import 'package:chatting/pages/group_info.dart';
import 'package:chatting/service/database_service.dart';
import 'package:chatting/widgets/message_tile.dart';
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
  final TextEditingController _messageController = TextEditingController();
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
          elevation: 0,
          title: Text(
            widget.groupName,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
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
        body: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                color: Colors.grey[700],
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Send a message...',
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                      },
                      child: Container(
                        height: 20,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender']);
                },
              )
            : Container();
      },
    );
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        'message': _messageController.text,
        'sender': widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        _messageController.clear();
      });
    }
  }
}
