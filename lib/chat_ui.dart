import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'Fonction.dart';
class Chatpage extends StatefulWidget {
  const Chatpage({super.key});

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  int? _selectedConversationId;

  late Future<List<Map<String, dynamic>>> _messages;
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatgpt like'),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white24,
        child: _buildSidebar(),
      ),
      backgroundColor: Colors.black12,
      body:  _selectedConversationId != null
          ? FutureBuilder<List<Map<String, dynamic>>>(
            future: _messages,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Map<String, dynamic>>? messages = snapshot.data;
    
                return SingleChildScrollView(
                  reverse: true,
                  child: Column(
                      children: [
                        // Display conversation messages here using the 'messages' list
                        for (var i = 0; i < messages!.length; i++)
                        messages[i]['qui_parle'] == 0
                            ? Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Expanded(
                                  child: SingleChildScrollView(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width / 1.5,
                                      decoration: const BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          messages[i]['message'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            : Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Expanded(
                                  child: SingleChildScrollView(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width / 1.5,
                                      decoration: BoxDecoration(
                                        color: Colors.white70,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: i == messages.length - 1
                                            ? messages[i]['message'].startsWith('https')
                                            ? Column(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      dbHelper.launchURL(messages[i]['message']);
                                                    },
                                                    child: Image.network(messages[i]['message'])
                                                ),
                                              ],
                                            )
                                            : AnimatedTextKit(
                                              animatedTexts: [
                                                TypewriterAnimatedText(
                                                  messages[i]['message'],
                                                  textStyle: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 16.0,
                                                  ),
                                                  speed: Duration(milliseconds: 100),
                                                ),
                                              ],
                                              totalRepeatCount: 1,
                                              pause: Duration(milliseconds: 1000),
                                            )
                                            : messages[i]['message'].startsWith('https')
                                            ? Image.network(messages[i]['message'])
                                            : Text(
                                              messages[i]['message'],
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                  ),
                );
            }
            },
          )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: 80,
                      decoration: const BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10))),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Salut à vous, comment puis-je vous aider?',
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                              speed: Duration(milliseconds: 100),
                            ),
                          ],
                          totalRepeatCount: 1, // Définir le nombre total de répétitions à 1
                          pause: Duration(milliseconds: 1000), // Temps d'attente avant la répétition (facultatif)
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white12,
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width/1.308,
              height: MediaQuery.of(context).size.height/5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10)
                ),
                border: Border.all(
                  color: Colors.white
                )
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: Colors.white
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Saisir votre demande...',
                    hintStyle: TextStyle(
                      color: Colors.white
                    )
                  ),
                ),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10)
                ),
              ),
              child: InkWell(
                onTap: () async {
                  if (_selectedConversationId == null) {
                    // Call the method to create a conversation
                    if (_searchController.text.isEmpty) {
                      final snackBar = SnackBar(
                        backgroundColor: Colors.grey,
                        content: Text(
                          'Saisir votre texte',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      _selectedConversationId = await DatabaseHelper().createConversation(_searchController.text);
                      _messages = DatabaseHelper().getMessagesForConversation(_selectedConversationId!);
                    }
                  } else {
                    // Call the method to add content to the existing conversation
                    if (_searchController.text.isNotEmpty) {
                      await DatabaseHelper().addContentToConversation(_selectedConversationId!, _searchController.text);
                      _messages = DatabaseHelper().getMessagesForConversation(_selectedConversationId!);
                    } else {
                      const snackBar = SnackBar(
                        backgroundColor: Colors.grey,
                        content: Text(
                          'Saisir votre texte',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                  _searchController.clear();
                  setState(() {});
                },
                child: Icon(Icons.send),
              ),

            )
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    var size = MediaQuery.of(context).size;
    final dbHelper = DatabaseHelper();
    return Drawer(
      child: Container(
        color: Color.fromRGBO(35, 36, 39, 1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Chatgpt like', style: TextStyle(color: CupertinoColors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                  IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.menu,color: CupertinoColors.white,)
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10)
                  ),
                ),
                child: InkWell(
                  onTap: () async{
                    setState(() {
                      _selectedConversationId = null;
                      Navigator.pop(context);
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nouvelle conversation', style: TextStyle(
                        color: Colors.black,
                        fontSize: 16
                      ),),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.message, size: 18,)
                    ],
                  ),
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: dbHelper.getConversations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}', style: TextStyle(
                    color: Colors.white
                  ),);
                } else {
                  final historiqueList = snapshot.data ?? [];

                  if (historiqueList.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 150,),
                        Lottie.asset(
                          'assets/lottie/robot0.json',
                          width: 150,
                          height: 150,
                          // Adjust width and height according to your logo size
                        ),
                        SizedBox(height: 10,),
                        Container(
                          width: 200,
                          child: Text('Aucune conversation pour le moment', textAlign: TextAlign.center, style: TextStyle(
                              color: Colors.white,
                              fontSize: 12
                          ),),
                        ),
                      ],
                    );
                  }
                  return Container(
                    height: size.height/1.4, // Ajustez la hauteur selon vos besoins
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: historiqueList.length,
                      itemBuilder: (context, index) {
                        // If the future is complete, display the data
                        final conversations = snapshot.data;
                        return Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 70,
                                width: size.width/1.2,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                ),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      _selectedConversationId = conversations[index]['id'];
                                      _messages = DatabaseHelper().getMessagesForConversation(_selectedConversationId!);
                                      Navigator.pop(context);
                                    });
                                  },
                                  title: Text(conversations![index]['title'], overflow: TextOverflow.ellipsis, style: TextStyle(
                                    color: Colors.white60
                                  ),),
                                  subtitle: Text('conversation N°${conversations[index]['code']}', style: TextStyle(
                                    color: Colors.white12,
                                  ),),
                                  trailing: PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert_rounded, color: Colors.white60),
                                    onSelected: (value) {
                                      if (value == 'archive') {
                                        // Logique pour archiver le message
                                        print('Message archivé');
                                      } else if (value == 'delete') {
                                        // Logique pour supprimer la conversation
                                        print('Conversation supprimée');
                                        DatabaseHelper().deleteConversation(conversations[index]['id']);
                                        setState(() {
                                          // Mettez à jour l'affichage après la suppression de la conversation
                                          _selectedConversationId = null;
                                        });
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      PopupMenuItem<String>(
                                        value: 'archive',
                                        child: Row(
                                          children: [
                                            Icon(Icons.archive),
                                            SizedBox(width: 10,),
                                            Text('Archiver'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete),
                                            SizedBox(width: 10,),
                                            Text('Supprimer'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Add other details as needed
                                ),
                              ),
                              const Divider()
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
