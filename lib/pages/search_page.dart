import 'package:chatting/helper/helper_function.dart';
import 'package:chatting/pages/chat_page.dart';
import 'package:chatting/service/database_service.dart';
import 'package:chatting/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? _searchSnapshot;
  bool _hasUserSearched = false;
  String _userName = "";
  bool _isJoined = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserNameFromSF().then(
      (value) {
        setState(
          () {
            _userName = value!;
          },
        );
      },
    );
    _user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf('_') + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Search',
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      prefixIcon: GestureDetector(
                        onTap: () {
                          initiateSearchMethod();
                        },
                        child: const Icon(Icons.search),
                      ),
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 32),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : groupList()
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService().searchByName(_searchController.text).then(
        (snapshot) {
          setState(
            () {
              _searchSnapshot = snapshot;
              _isLoading = false;
              _hasUserSearched = true;
            },
          );
        },
      );
    }
  }

  groupList() {
    return _hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: _searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                _userName,
                _searchSnapshot!.docs[index]['groupId'],
                _searchSnapshot!.docs[index]['groupName'],
                _searchSnapshot!.docs[index]['admin'],
              );
            },
          )
        : Container();
  }

  joinedOrNot(
      String userName, String groupId, String groupname, String admin) async {
    await DatabaseService(uid: _user!.uid)
        .isUserJoined(groupname, groupId, userName)
        .then(
      (value) {
        setState(
          () {
            _isJoined = value;
          },
        );
      },
    );
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    // function to check whether _user already exists in group
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title:
          Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('Admin: ${getName(admin)}'),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: _user!.uid)
              .toggleGroupJoin(groupId, userName, groupName);
          if (_isJoined) {
            setState(
              () {
                _isJoined = !_isJoined;
              },
            );
            showSnackbar(
                context, Colors.green, 'Successfully joined the group');
            Future.delayed(
              const Duration(seconds: 2),
              () {
                nextScreen(
                    context,
                    ChatPage(
                        groupId: groupId,
                        groupName: groupName,
                        userName: userName));
              },
            );
          } else {
            setState(
              () {
                _isJoined = !_isJoined;
                showSnackbar(context, Colors.red, 'Left the group $groupName');
              },
            );
          }
        },
        child: _isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  'Joined',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text('Join Now',
                    style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}
