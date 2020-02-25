import 'package:entrenados/models/item.dart';
import 'package:flutter/material.dart';

class GridItem extends StatefulWidget {
  final Key key;
  final Item item;
  final ValueChanged<bool> isSelected;

  GridItem({this.item, this.isSelected, this.key});

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    isSelected = widget.item.value;
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            margin: EdgeInsets.only(left: 9, right: 9),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Image.asset(
                widget.item.imgURL,
                color: Colors.black.withOpacity(isSelected ? 0.9 : 0),
                colorBlendMode: BlendMode.color,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Text(
              widget.item.name,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
          isSelected
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.teal,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
