import 'package:cloud_firestore/cloud_firestore.dart';

class CardBody {
  final DocumentSnapshot image;
  final String title;

  CardBody({
    this.image,
    this.title
  });
}