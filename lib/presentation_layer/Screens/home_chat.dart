import 'package:bloc_test/controllers/data_controller.dart';
import 'package:bloc_test/data/models/ChatModel.dart';
import 'package:bloc_test/data/models/user.dart';
import 'package:bloc_test/presentation_layer/Screens/chat_one.dart';
import 'package:bloc_test/presentation_layer/Screens/chat_two.dart';
import 'package:bloc_test/presentation_layer/Screens/group%20chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeChat extends StatefulWidget {
  const HomeChat({super.key});

  @override
  State<HomeChat> createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {
  Data_controller controller = Get.put(Data_controller());
  double radius = 0.0;
  List chats = [];

  @override
  void initState() {
   
    super.initState();
    get_data();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              All_users(context);
            }),
        appBar: AppBar(
          leading: Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: GetBuilder<drawer_controller>(
              init: drawer_controller(),
              builder: (controller) => IconButton(
                icon: Icon(
                  Icons.view_headline_sharp,
                  color: Colors.black87,
                ),
                onPressed: () {
                  controller.change();
                  setState(() {
                    radius = controller.is_open ? 50 : 0;
                  });
                },
              ),
            ),
          ),
          backgroundColor: Colors.black87,
          elevation: 0,
          title: GetBuilder<Data_controller>(
            init: Data_controller(),
            builder: (controller) => Text(
              'Chat, ${controller.Current_User == null ? '' : controller.Current_User}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
       actions: [
        IconButton(onPressed: (){group(context);}, icon: CircleAvatar(backgroundColor: Colors.black87,child: Icon(Icons.group)))
       ],
       
        ),
        body: Container(
            decoration: BoxDecoration(color: Colors.black),
            child: Column(
              children: [
chats.map((e) => e['users_id'].length > 2 
    ? Group_item(group_model.fromJson(e)) 
    : Chat_item(chat_model.fromJson(e))
).toList(),
              ],
            )),
      ),
    );
  }

Widget Chat_item(ModelChat chat) {
    User user =
        chat.users[chat.users.indexWhere((e) => e.id != auth.currentUser!.uid)];
    return Column(
      children: [
        ListTile(
          onTap:(){
            Navigator.push(context, MaterialPageRoute(builder: (c)=> ChatOne(chat)));
          } ,
          leading: user.imagePath == ''
              ? CircleAvatar(
                  backgroundColor: Colors.white,
                )
              : CircleAvatar(
                  backgroundImage: NetworkImage(user.imagePath),
                ),
          title: Text(
            user.name.toString(),
            style: TextStyle(color: Colors.white),
          ),
          // subtitle => nist7a9ha barcha 5ater 3andi kifha bidhabt fil figma
          subtitle:chat.chat.isNotEmpty?Text(chat.chat.last['text'],style: TextStyle(color: Colors.white),):Text('data') ,
        ),
        Divider(
          color: Colors.white,
        )
      ],
    );
  }
Widget Group_item(group_model chat) {
    return Column(
      children: [
        ListTile(
          onTap:(){
            Navigator.push(context, MaterialPageRoute(builder: (c)=> Group_chat(chat)));
          } ,
          leading: chat.image == ''
              ? CircleAvatar(
                  backgroundColor: Colors.white,
                )
              : CircleAvatar(
                  backgroundImage: NetworkImage(chat.image),
                ),
          title: Text(
            chat.group_name.toString(),
            style: TextStyle(color: Colors.white),
          ),
          // subtitle => nist7a9ha barcha 5ater 3andi kifha bidhabt fil figma
          subtitle:chat.chat.isNotEmpty?Text(chat.chat.last['text'],style: TextStyle(color: Colors.white),):Text('data') ,
        ),
        Divider(
          color: Colors.white,
        )
      ],
    );
  }

  All_users(context) {
    showModalBottomSheet(
        context: context,
        builder: (b) => IntrinsicHeight(
              child: Container(
                color: Colors.black87,
                child: SingleChildScrollView(
                  child: GetBuilder<Data_controller>(
                      builder: (c) => Column(
                            children: [
                              c.users.map((e) => Column(
                                    children: [
                                      ListTile(
                                        onTap: () async {
                                          await add_new_chat(
                                              [c.Current_User, e]);
                                          setState(() {
                                            Navigator.pop(context);
                                          });
                                        },
                                        leading: e.image!=''?CircleAvatar(backgroundImage: NetworkImage(e.image),
                                        :CircleAvatar(backgroundColor: Colors.white,),
                                        
                                        ),
                                        title: Text(e.name,
                                        style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      Divider(),

                                    ],
                                  )).toList(),
                            ],
                          ),
                          ),
                ),
              ),
            ));
  }
  group(context) {
    showModalBottomSheet(
        context: context,
        builder: (b) => IntrinsicHeight(
              child: Container(
                color: Colors.black87,
                child: Group()
              ),
            ));
  }

  add_new_chat(List<User> users) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('chats');
    await ref.add(ModelChat(
      unread:[],
            id: 'id',
            users: users,
            chat: [],
            users_id: users.map((e) => e.id).toList())
        .toJson()).then((value)async{
            value.update({'id':value.id});
        });
    setState((){});
  }
 

  get_data() async {
    await FirebaseFirestore.instance.collection('chats').where('users_id',arrayContains: auth.currentUser!.uid).snapshots().listen((event){
      chats  =event.docs.toList();
setState((){});
    });
  }
}



class Group extends StatefulWidget {
  const Group({super.key});

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  Data_controller control = Get.put(Data_controller());

  List<bool> check=[];
    List <User> users_select=[];

  @override
  void initState() {
    
    super.initState();
    users_select.add(control.Current_User);
    check= List.generate(control.users.length, (index)=>false);
  }
  TextEditingController name = TextEditingController(); 
  TextEditingController image = TextEditingController(); 
  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        SingleChildScrollView(
          child: GetBuilder<Data_controller>(
             builder: (c) => Column(
              children: c.users.asMap().map((index,value) => MapEntry(index,Column(
                children: [
                  ListTile(
                    leading: c.users[index].image!=''?CircleAvatar(backgroundImage: NetworkImage(c.users[index].image))
                    :CircleAvatar(backgroundColor: Colors.white),
                    title: Text(c.users[index].name,style: TextStyle(color: Colors.white),
                                            ),
                                            trailing: Checkbox(value: check[index], onChanged: (value){
                                              setState(() {
                                                check[index]=value!;
                                                if (value) {
                                                  users_select.add(c.users[index]);
        
                                                  
                                                }else{
                                                 users_select.remove(c.users[index]);
        
                                                }
                                              });
                                              print(users_select.length);// pour afficher dans le terminal combien de user on a selectionnne
                                            }),
                                          ),
                                          Divider(),
        
                                        ],
                                      ))).values.toList(),
                                
                              ),
                              ),
                    ),
     Positioned(
      bottom: 40,right: 30
      ,child: FloatingActionButton(onPressed: (){
Navigator.pop(context);
Show_dialog();
     },child: Text('done'),))
     
      ],
    );
  }
 
//  methode pour 
 Show_dialog(){
  showDialog(context: context, builder: (context)=> AlertDialog(
    content: IntrinsicHeight(
      child: Container(
        height: MediaQuery.of(context).size.height/2,
        width: MediaQuery.of(context).size.width-50,
      child: Column(
        children: [
      TextFormField(controller: name),
      TextFormField(controller: image),
      ElevatedButton(onPressed: (){add_new_group(users_select);}, child: Text('make group'))
        ],
      ),
      
      ),
    ),
  ));
 }

 add_new_group(List<User> users) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('chats');
    await ref.add(group_model(
      image: image.text,group_name:name.text ,
      unread:[],
            id: 'id',
            users: users,
            chat: [],
            users_id: users.map((e) => e.id).toList())
        .toJson()).then((value)async{
            await value.update({'id':value.id});
        });
    setState((){});
  }

}