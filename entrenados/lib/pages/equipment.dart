import 'package:entrenados/models/item.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/griditem.dart';

class Equipment extends StatefulWidget {
  final List<Item> selectedEquipmentList;

  Equipment(this.selectedEquipmentList);

  @override
  _EquipmentState createState() => _EquipmentState();

    static List<Item> getEquipment(){
    List<Item> itemEquipmentList = List();
    itemEquipmentList.add(Item("assets/img/ball.jpg", "Balón", 1, false));
    itemEquipmentList.add(Item("assets/img/bank.jpg", "Banco", 2, false));
    itemEquipmentList
        .add(Item("assets/img/dumbell.jpg", "Mancuernas", 3, false));
    itemEquipmentList.add(Item("assets/img/rope.jpg", "Comba", 4, false));
    itemEquipmentList
        .add(Item("assets/img/sack.jpg", "Saco de boxeo", 5, false));
    itemEquipmentList
        .add(Item("assets/img/yoga.jpg", "Estera", 6, false));
    return itemEquipmentList;
  }
}

class _EquipmentState extends State<Equipment> {
  static List<Item> itemEquipmentList = List();

  @override
  void initState() {
    super.initState();
    print("Equipamiento guardado en equipamiento");
    print(widget.selectedEquipmentList);
    if (widget.selectedEquipmentList.length < 1) {
      itemEquipmentList = Equipment.getEquipment();
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
                print("$index : $isSelected");
               
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
