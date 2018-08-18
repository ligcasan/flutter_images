import 'card_body.dart';
import 'package:flutter/material.dart';

class CardList extends ChangeNotifier{
  List<CardBody> _cardBodyList = [];

  void createCardList(data) {
    for (var document in data.data.documents) {
      this._cardBodyList.add(new CardBody(image: document, title: document['title']));
    }
  }

  List<CardBody> getCardList() {
    notifyListeners();
    return this._cardBodyList;
  }
}