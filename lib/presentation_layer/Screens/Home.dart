// import 'package:bloc_test/presentation_layer/Screens/Chat1.dart';
// import 'package:bloc_test/presentation_layer/Screens/chattwo.dart';
// import 'package:flutter/material.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black87,
//         elevation: 0,
//         title: Text('Home'),
//       ),
//       body: Container(
//         color: Colors.black,
//         child: ListView(
//           children: [
//             InkWell(
//               onTap: () {
//                 Navigator.of(context)
//                     .push(MaterialPageRoute(builder: (context) => Chat1()));
//               },
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         radius: 30,
//                         backgroundColor: Colors.blue,
//                       ),
//                       title: Text(
//                         'chat one',
//                         style: TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   Divider(
//                     color: Colors.white,
//                   ),
//                 ],
//               ),
//             ),
//             InkWell(
//               onTap: () {
//                 Navigator.of(context)
//                     .push(MaterialPageRoute(builder: (context) => Chattwo()));
//               },
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         radius: 30,
//                         backgroundColor: Colors.amber,
//                       ),
//                       title: Text(
//                         'chat two',
//                         style: TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   Divider(
//                     color: Colors.white,
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
