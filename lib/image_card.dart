import 'package:flutter/material.dart';
import 'card_body.dart';
import 'decision.dart';

class ImageCard extends StatefulWidget {
  final CardBody cardBody;

  ImageCard({
    Key key,
    this.cardBody
  }) : super(key: key);
  @override
  _ImageCardState createState ()=> new _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.network(
                widget.cardBody.image['url'],
                fit: BoxFit.cover)
          ],
        ),
      ),
    );
  }

}

/*Widget _generateImage(AsyncSnapshot documents) {
  return new ImageGenerator(documentIndex: 0, documents: documents);

}*/

class ImageGenerator extends StatefulWidget {
  final AsyncSnapshot documents;
  final int documentIndex;
  final Decision decision;

  ImageGenerator({
    this.documentIndex,
    this.documents,
    this.decision
  });

  @override
  _ImageGeneratorState createState() => _ImageGeneratorState();
}

class _ImageGeneratorState extends State<ImageGenerator> {
  int imageIndex;

  @override
  void initState() {
    super.initState();
    imageIndex = widget.documentIndex;
  }

  void _prevImage(){
    setState(() {
      imageIndex = imageIndex > 0 ? imageIndex - 1 : 0;
    });
  }

  void _nextImage(){
    setState(() {
      widget.decision.setDocumentReference(widget.documents.data.documents[imageIndex]);
      imageIndex = imageIndex < widget.documents.data.documents.length - 1 ?
        imageIndex + 1
        : imageIndex;
    });
  }

  Widget _directionController() {
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new GestureDetector(
          onTap: _prevImage,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1.0,
            alignment: Alignment.topLeft,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.yellow)),
            ),
          ),  
        ),
        new GestureDetector(
          onTap: _nextImage,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1.0,
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.pink)),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.decision.setDocumentReference(widget.documents.data.documents[imageIndex]);
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.network(
          widget.documents.data.documents[imageIndex]['url'],
          fit: BoxFit.cover),
        _directionController()
      ],
    );
  }
}
