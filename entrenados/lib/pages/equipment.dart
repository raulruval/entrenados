import 'package:entrenados/models/item.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/griditem.dart';

class Equipment extends StatefulWidget {
  final List<Item> selectedEquipment;

  Equipment(this.selectedEquipment);

  @override
  _EquipmentState createState() => _EquipmentState();
}

class _EquipmentState extends State<Equipment> {
  static List<Item> itemEquipmentList = List();
  @override
  void initState() {
    super.initState();
    print("Equipamiento guardado en equipamiento");
    print(widget.selectedEquipment);
    if (widget.selectedEquipment.length < 1) {
      loadListEquipment();
    }
  }

  loadListEquipment() {
    itemEquipmentList = List();
    itemEquipmentList.add(Item("assets/img/ball.jpg", "Balón", 1, false));
    itemEquipmentList.add(Item("assets/img/bank.jpg", "Banco", 2, false));
    itemEquipmentList.add(Item("assets/img/dumbell.jpg", "Mancuernas", 3, false));
    itemEquipmentList.add(Item("assets/img/rope.jpg", "Comba", 4, false));
    itemEquipmentList.add(Item("assets/img/sack.jpg", "Saco de boxeo", 5, false));
    itemEquipmentList.add(Item("assets/img/yoga.jpg", "Estera", 6, false));
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
              isSelected: (value) {
                setState(() {
                  if (value) {
                    print("En el bucle");
                    if (widget.selectedEquipment.length > 1) {
                      for (var i = 0;
                          i < widget.selectedEquipment.length;
                          i++) {
                        if (itemEquipmentList[index].value ==
                            widget.selectedEquipment[i].value) {
                        } else {
                          itemEquipmentList[index].value = true;
                          widget.selectedEquipment
                              .add(itemEquipmentList[index]);
                          print("hola");
                        }
                      }
                    } else {
                      itemEquipmentList[index].value = true;
                      widget.selectedEquipment.add(itemEquipmentList[index]);
                    }
                    for (var i = 0; i < widget.selectedEquipment.length; i++)
                      widget.selectedEquipment[i].value = true;
                  } else {
                    itemEquipmentList[index].value = false;
                    widget.selectedEquipment.remove(itemEquipmentList[index]);
                  }
                });
                print("$index : $value");
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
      title: Text(widget.selectedEquipment.length < 1
          ? "Selecciona los elementos"
          : "${widget.selectedEquipment.length} elementos seleccionados"),
      actions: <Widget>[
        widget.selectedEquipment.length < 1
            ? Container()
            : InkWell(
                onTap: () {
                  Navigator.pop(context, widget.selectedEquipment);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.check),
                ))
      ],
    );
  }
}
