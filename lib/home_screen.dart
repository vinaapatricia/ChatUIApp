import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<AnimatedListState> _listkey = GlobalKey();
  List<String> data = [];
  static const String BOT_URL = "#notfixed";
  TextEditingController queryController = TextEditingController();

  Widget buildItem(String item, Animation<double> animation, int index) {
    bool mine = item.endsWith("<bot>");
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Container(
          alignment: mine ? Alignment.topLeft : Alignment.topRight,
          child: Bubble(
            child: Text(
              item.replaceAll("<bot>", ""),
              style: TextStyle(color: mine ? Colors.white : Colors.black),
            ),
            color: mine ? Colors.blue : Colors.grey[200],
            padding: BubbleEdges.all(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text('Chat bot'),
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          AnimatedList(
            itemBuilder: (context, index, animation) {
              return buildItem(data[index], animation, index);
            },
            key: _listkey,
            initialItemCount: data.length,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ColorFiltered(
              colorFilter: ColorFilter.linearToSrgbGamma(),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.message,
                        color: Colors.amberAccent,
                      ),
                      hintText: "Hello",
                      fillColor: Colors.white12,
                    ),
                    controller: queryController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (msg) {
                      getResponse();
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

// ... Your other code ...

  void getResponse() {
    if (queryController.text.length > 0) {
      insertSingleItem(queryController.text);

      var client = getClient();
      try {
        client.post(Uri.parse(BOT_URL), // Corrected syntax for Uri.parse
            body: {"query": queryController.text}).then((response) {
          print(response.body);
          Map<String, dynamic> data = jsonDecode(response.body);
          insertSingleItem(data['response'] + "<bot>");
        });
      } finally {
        client.close();
        queryController.clear();
      }
    }
  }

  http.Client getClient() {
    // Create and return a new HTTP client instance
    return http.Client();
  }

  void insertSingleItem(String message) {
    data.add(message);
    _listkey.currentState!.insertItem(data.length - 1);
  }
}
