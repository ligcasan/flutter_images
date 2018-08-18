import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'card_body.dart';

class DecisionEngine extends ChangeNotifier {
  final List<Decision> _decisions;
  int _currentIndex;
  int _nextIndex;

  DecisionEngine({
    List<Decision> decisions
  }): _decisions = decisions {
    _currentIndex = 0;
    _nextIndex = 1;
  }

  Decision get currentDecision => _decisions[_currentIndex];

  Decision get nextDecision => _decisions[_nextIndex];

  List<Decision> get listDecision => _decisions;

  void engineCycle() {
    if (currentDecision._decisionStatus != DecisionStatus.undecided) {
      currentDecision.reset();

      _currentIndex = _nextIndex;
      _nextIndex = _nextIndex < _decisions.length - 1 ? _nextIndex + 1 : 0;

      notifyListeners();
    }
  }
}

class Decision extends ChangeNotifier {
  final CardBody cardBody;
  DecisionStatus _decisionStatus = DecisionStatus.undecided;
  DocumentSnapshot _documentReference;

  Decision({
    this.cardBody
  });

  void setDocumentReference(DocumentSnapshot documentReference) {
    this._documentReference = documentReference;
  }

  void like() {
    if (_decisionStatus == DecisionStatus.undecided) {
      _decisionStatus = DecisionStatus.like;
      /*Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap =
        await transaction.get(this._documentReference.reference);
        await transaction.update(freshSnap.reference, {'status': 'like'});
      });*/
    }
  }

  void disLike() {
    if (_decisionStatus == DecisionStatus.undecided) {
      _decisionStatus = DecisionStatus.disLike;
    }
  }

  void reset() {
    _decisionStatus = DecisionStatus.undecided;
  }

  void printDS() {
    print(_decisionStatus);
  }
}

enum DecisionStatus {
  undecided,
  disLike,
  like
}