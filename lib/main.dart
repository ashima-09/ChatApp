import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: ChatPage()));
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageControl = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void onSendMessage() async {
    if (messageControl.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendBy": _auth.currentUser!.uid,
        "message": messageControl.text,
        "time": FieldValue.serverTimestamp(),
      };
      
      print(messageControl);
      messageControl.clear();
      await _firestore.collection('chats').add(messages);
    } else {
      print("Enter Some Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        actions: [
          IconButton(
              onPressed: () async {
                await signInWithGoogle();
                setState(() {
                  print(_auth.currentUser?.uid);
                });
              },
              icon: const Icon(Icons.login_outlined))
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('chats').snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data != null) {
                      return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          // return Text(snapshot.data?.docs[index]['message']);
                          final map = snapshot.data?.docs[index].data();
                          return messageDisplay(size, map);
                        },
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: SizedBox(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size.height / 17,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: messageControl,
                        decoration: InputDecoration(
                            hintText: "Send Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.send), onPressed: onSendMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // body: Container(
      //   padding: const EdgeInsets.all(10.0),
      //   margin: const EdgeInsets.all(10.0),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     children: [
      //       SizedBox(
      //         // height: 50.0,
      //         child: Row(
      //           children: [
      //             Expanded(
      //               child: TextField(
      //                 controller: messageControl,
      //                 keyboardType: TextInputType.name,
      //                 decoration: const InputDecoration(
      //                     border: OutlineInputBorder(
      //                         borderRadius:
      //                             BorderRadius.all(Radius.circular(20.0))),
      //                     hintText: 'Enter message'),
      //               ),
      //             ),
      //             // const SizedBox(
      //             //   width: 200.0,
      //             //   child: TextField(
      //             //     keyboardType: TextInputType.name,
      //             //     decoration: InputDecoration(
      //             //         border: OutlineInputBorder(),
      //             //         hintText: 'Enter message'
      //             //     ),
      //             //   ),
      //             // ),
      //             // Padding(padding: EdgeInsets.all(10.0)),
      //             IconButton(
      //               onPressed: () {
      //                 // showDialog(
      //                 //   context: context,
      //                 //   builder: (context) {
      //                 //     return AlertDialog(
      //                 //       // Retrieve the text the that user has entered by using the
      //                 //       // TextEditingController.
      //                 //       content: Text(
      //                 //         messageControl.text,
      //                 //         style: const TextStyle(color: Colors.black),
      //                 //         ),
      //                 //     );
      //                 //   },
      //                 // );
      //                 Row(
      //                   children: [
      //                     Container(
      //                       alignment: Alignment.center,
      //                       color: Colors.yellow,
      //                       // child: Text(messageControl.text),
      //                     )
      //                   ],
      //                 );

      //                 // ignore: avoid_print
      //                 print(messageControl.text);
      //                 // setState(() {
      //                 //   messageControl.clear();
      //                 // });

      //               },
      //               icon: const Icon(Icons.send_rounded),
      //             )
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  Widget messageDisplay(Size size, final map) {
    return Container(
      width: size.width,
      alignment: Alignment.centerRight,
      //  map['sendby'] == _auth.currentUser!.uid
      //     ? Alignment.centerRight
      //     : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.blue,
        ),
        child: Text(
          map['message'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
