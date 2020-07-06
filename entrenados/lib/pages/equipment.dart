import 'package:entrenados/models/item.dart';
import 'package:entrenados/models/searchModel.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/griditem.dart';

class Equipment extends StatefulWidget {
  final List<Item> selectedEquipmentList;
  final SearchModel searchModel;

  Equipment(this.selectedEquipmentList, this.searchModel);

  @override
  _EquipmentState createState() => _EquipmentState();
}

class _EquipmentState extends State<Equipment> {
  static List<Item> itemEquipmentList = List();

  @override
  void initState() {
    super.initState();
    if (widget.selectedEquipmentList.length < 1) {
      itemEquipmentList = widget.searchModel.equipment;
      for (var i = 0; i < itemEquipmentList.length; i++)
        itemEquipmentList[i].isSelected = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: GridView.builder(
          itemCount: itemEquipmentList.length,
          padding: const EdgeInsets.all(30),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 1,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            return GridItem(
              item: itemEquipmentList[index],
              isSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    if (widget.selectedEquipmentList.length > 1) {
                      for (var i = 0;
                          i < widget.selectedEquipmentList.length;
                          i++) {
                        if (itemEquipmentList[index].isSelected ==
                            widget.selectedEquipmentList[i].isSelected) {
                        } else {
                          itemEquipmentList[index].isSelected = true;
                          widget.selectedEquipmentList
                              .add(itemEquipmentList[index]);
                        }
                      }
                    } else {
                      itemEquipmentList[index].isSelected = true;

                      widget.selectedEquipmentList
                          .add(itemEquipmentList[index]);
                    }
                    for (var i = 0;
                        i < widget.selectedEquipmentList.length;
                        i++) widget.selectedEquipmentList[i].isSelected = true;
                  } else {
                    itemEquipmentList[index].isSelected = false;
                    widget.selectedEquipmentList
                        .remove(itemEquipmentList[index]);
                  }
                });
              },
              key: Key(
                itemEquipmentList[index].index.toString(),
              ),
            );
          }),
    );
  }

  getAppBar() {
    return AppBar(
      title: Text(widget.selectedEquipmentList.length < 1
          ? "Selecciona los elementos"
          : "${widget.selectedEquipmentList.length} elementos seleccionados"),
      actions: <Widget>[
        widget.selectedEquipmentList.length < 1
            ? Container()
            : InkWell(
                onTap: () {
                  Navigator.pop(context, widget.selectedEquipmentList);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.check),
                ))
      ],
    );
  }
}
