import 'package:flutter/material.dart';
import 'card_container.dart';
import 'decision.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'card_body.dart';
import 'card_list.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp (
      title: 'Reddit Images',
      theme: ThemeData(primarySwatch: Colors.lightGreen),
      home: DisplayPage(),
    );
  }
}

class DisplayPage extends StatefulWidget {
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  Decision decision = new Decision();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance.collection('users').document('oWK76vgiXSmzUvvm2Hqk').collection('images').snapshots(),
        builder: (context, snapshot) {
          return PageView.builder(
            itemCount: 1,
            itemBuilder: (context, index){
              if (!snapshot.hasData) return const Text('Loading...');
              CardList cardList = new CardList();
              cardList.createCardList(snapshot);
              DecisionEngine decisionEngine = new DecisionEngine(
                decisions: cardList.getCardList().map((CardBody cardBody) {
                  return new Decision(cardBody: cardBody);
                }).toList()
              );
              return Scaffold(
                body: CardStack(decisionEngine: decisionEngine));
            }
          );
        },
      )
    );
  }
}