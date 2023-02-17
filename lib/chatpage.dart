import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key, required this.userMap, required this.chatPageId});
  final Map<String,dynamic> userMap;
  final TextEditingController messageControl = TextEditingController();
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final String chatPageId;
  // String chatPageId (String user1,String user2){
  //   if(user1[0].toLowerCase().codeUnits[0]>user2[0].toLowerCase().codeUnits[0]){
  //     return "$user1$user2";
  //   }
  //   else{
  //     return "$user2$user1";
  //   }
  // }

  void onSendMessage() async {
    if (messageControl.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "message": messageControl.text,
        "type": "text",
      };

      messageControl.clear();
      await _firestore
          .collection('chatroom')
          .doc(chatPageId)
          .collection('chats')
          .add(messages);
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
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if(snapshot.data!=null){
                    return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        return Text(snapshot.data?.docs[index]['message']);
                      },
                    );
                  }
                  else{
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
}