import 'package:flutter/material.dart';
import 'package:entrenados/pages/musclesinvolved.dart';

class GridItem extends StatefulWidget {
  final Key key;
  final ItemMuscles item;
  final ValueChanged<bool> isSelected;

  GridItem({this.item, this.isSelected, this.key});

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
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
            margin: EdgeInsets.only(left: 10, right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Image.asset(
                widget.item.imgURL,
                color: Colors.black.withOpacity(isSelected ? 0.9 : 0),
                colorBlendMode: BlendMode.color,
                fit: BoxFit.cover,
                semanticLabel: "hola",
              ),
            ),
          ),
          Center(
            child: Text(
              widget.item.muscleName,
              style: TextStyle(color: Colors.white, fontSize: 15,fontWeight: FontWeight.bold),
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
