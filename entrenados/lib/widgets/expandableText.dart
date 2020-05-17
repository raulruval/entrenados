import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  ExpandableText(this.text);

  final String text;
  @override
  _ExpandableTextState createState() => new _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with TickerProviderStateMixin<ExpandableText> {
  bool expanded = false;
  @override
  void initState() {
    if (widget.text.length < 200) {
      expanded = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(children: <Widget>[
      new AnimatedSize(
          vsync: this,
          duration: const Duration(milliseconds: 500),
          child: new ConstrainedBox(
              constraints: expanded
                  ? new BoxConstraints()
                  : new BoxConstraints(maxHeight: 50.0),
              child: new Text(
                widget.text,
                softWrap: true,
                overflow: TextOverflow.fade,
              ))),
      expanded
          ? new ConstrainedBox(constraints: new BoxConstraints())
          : new FlatButton(
              child: const Text('Ver más'),
              onPressed: () => setState(() => expanded = true))
    ]);
  }
}
