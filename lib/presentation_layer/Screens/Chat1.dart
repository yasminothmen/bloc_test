// import 'package:bloc_test/data/models/model%20chat.dart';
// import 'package:bloc_test/presentation_layer/Screens/const.dart';
// import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
// import 'package:flutter/material.dart';

// class Chat1 extends StatefulWidget {
//   const Chat1({super.key});

//   @override
//   State<Chat1> createState() => _Chat1State();
// }

// class _Chat1State extends State<Chat1> {
//   TextEditingController text = TextEditingController();
//   String myname = 'chatone';
// final record = AudioRecorder();
//   bool is_record = false;
//    late AudioPlayer audioPlayer;
//   bool is_player = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black87,
//         elevation: 0,
//         title: const Text('Chat one '),
//       ),
//       body: Container(
//         color: Colors.grey,
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: Chat.length,
//                 itemBuilder: (_, index) => BubbleSpecialThree(
//                   isSender: Chat[index].sender_name == myname?true:false,
//                   text: Chat[index].text.toString(),
//                   color: Chat[index].sender_name == myname
//                       ? const Color(0xFF1B97F3)
//                       : Colors.green,
//                   tail: true,
//                   textStyle: const TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(15),
//               color: Colors.black87,
//               height: 100,
//               child: Row(
//                 children: [
//                   Expanded( 
//                     child: TextField(
//                       controller: text,
//                       style: const TextStyle(color: Colors.blue),
//                       decoration: const InputDecoration(
//                         hintText: 'Écrire un message...',
//                         hintStyle: TextStyle(color: Colors.white54),
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () {
//                       if (text.text.trim().isNotEmpty) {
//                         setState(() {
//                           Chat.add(model_chat(text.text, myname));
//                           text.clear();
//                         });
//                       }
//                     },
//                     icon: const Icon(
//                       Icons.send,
//                       color: Colors.blue,
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
