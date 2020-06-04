import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
// you need to create a cloud firestore database in https://console.firebase.google.com/project/fastchat-xxxx/database/firestore/data~2Fmessages~2FGl4R4QqqBy5vip1dzGup
import 'package:cloud_firestore/cloud_firestore.dart';

final _database = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;

  String messageText;
  TextEditingController _textController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        //enable signin method use in https://console.firebase.google.com/project/fastchat-xxxx/authentication/providers
        print(loggedInUser.email);
        //then, when registered, user appears in https://console.firebase.google.com/project/fastchat-xxxx/authentication/users
      }
    } catch (e) {
      print(e);
    }
  }
//
//  void getMessages() async {
//    try {
//      final messages = await _database.collection('messages').getDocuments();
//      for (var message in messages.documents) {
//        print(message.data);
//      }
//    } catch (e) {
//      print(e);
//    }
//  }
//
//  // stream of messages from firebase
//  void getMessagesStream() async {
//    //keeps listening to changes in messages collection from snapshots
//    await for (var snapshot in _database.collection('messages').snapshots()) {
//      for (var message in snapshot.documents) {
//        print(message.data);
//      }
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      child: TextField(
                          style: TextStyle(fontSize: 18),
                          controller: _textController,
                          onChanged: (value) {
                            //Do something with the user input.
                            messageText = value;
                          },
                          decoration: InputDecoration.collapsed(
                            hintText: "Enter your message",
                            border: InputBorder.none,
                          ),
                          maxLines: 1,
                          autofocus: true),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      print('pressed');
                      _database.collection('messages').add(
                          {'text': messageText, 'sender': loggedInUser.email});
                      print('clearing');
                      _textController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _database.collection('messages').snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return Expanded(
                child: Center(child: Text('Check your connection')));
          }
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Expanded(child: Center(child: Text('Loading connection')));
          }

          if (asyncSnapshot.hasData) {
            // we need to reverse the messages so they don´t go to the top,
            // but go to the bottom
            final messages = asyncSnapshot.data.documents.reversed;
            List<MessageBubble> messageWidgets = [];
            for (var message in messages) {
              final messageText = message.data['text'];
              final messageSender = message.data['sender'];
              final currentUser = loggedInUser.email;

              messageWidgets.add(MessageBubble(
                  messageSender: messageSender,
                  messageText: messageText,
                  isMe: currentUser == messageSender));
            }
            //expanded takes as much space available
            //listview provides a way to scroll messages
            return Expanded(
                child: ListView(
                    reverse: true,
                    children: messageWidgets,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 20)));
          } else {
            return Expanded(
                child: Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlue)));
          }
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String messageSender;
  final String messageText;
  final bool isMe;

  MessageBubble({this.messageSender, this.messageText, this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        //move column elements to right
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            child: Text(
              messageSender,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))
                : BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white70,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                messageText,
                style: TextStyle(
                    fontSize: 18, color: isMe ? Colors.white : Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
