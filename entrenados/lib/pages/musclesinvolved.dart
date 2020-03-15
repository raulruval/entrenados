import 'package:entrenados/models/item.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/griditem.dart';

class Musclesinvolved extends StatefulWidget {
  final List<Item> selectedMusclesList;

  Musclesinvolved(this.selectedMusclesList);

  @override
  _MusclesinvolvedState createState() => _MusclesinvolvedState();

  static List<Item> getMuscles() {
    List<Item> itemMusclesList = List();
    itemMusclesList.add(Item("assets/img/arm.jpg", "Bíceps", 1,false));
    itemMusclesList.add(Item("assets/img/leg.jpg", "Gemelos", 2,false));
    itemMusclesList.add(Item("assets/img/espalda.jpg", "Espalda", 3,false));
    itemMusclesList.add(Item("assets/img/abs.jpg", "Abdominales", 4,false));
    itemMusclesList.add(Item("assets/img/triceps.jpg", "Tríceps", 5,false));
    itemMusclesList.add(Item("assets/img/shoulder.jpg", "Hombros", 6,false));
    itemMusclesList
        .add(Item("assets/img/quadriceps.jpg", "Cuádriceps", 7,false));
    itemMusclesList.add(Item("assets/img/forearm.jpg", "Antebrazo", 8,false));

    return itemMusclesList;
  }
}

class _MusclesinvolvedState extends State<Musclesinvolved> {
  static List<Item> itemMusclesList = List();
  @override
  void initState() {
    super.initState();
    print("Musculos involucrados guardados en equipamiento");
    print(widget.selectedMusclesList);
    if (widget.selectedMusclesList.length < 1) {
      itemMusclesList = Musclesinvolved.getMuscles();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: GridView.builder(
          itemCount: itemMusclesList.length,
          padding: const EdgeInsets.all(30),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 1,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            return GridItem(
              item: itemMusclesList[index],
              isSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    print("En el bucle");
                    if (widget.selectedMusclesList.length > 1) {
                      for (var i = 0; i < widget.selectedMusclesList.length; i++) {
                        if (itemMusclesList[index].isSelected ==
                            widget.selectedMusclesList[i].isSelected) {
                        } else {
                          itemMusclesList[index].isSelected = true;
                          widget.selectedMusclesList.add(itemMusclesList[index]);
                          print("hola");
                        }
                      }
                    } else {
                      itemMusclesList[index].isSelected = true;
                      widget.selectedMusclesList.add(itemMusclesList[index]);
                    }
                    for (var i = 0; i < widget.selectedMusclesList.length; i++)
                      widget.selectedMusclesList[i].isSelected = true;
                  } else {
                    itemMusclesList[index].isSelected = false;
                    widget.selectedMusclesList.remove(itemMusclesList[index]);
                  }
                });
                print("$index : $isSelected");
              },
              key: Key(
                itemMusclesList[index].index.toString(),
              ),
            );
          }),
    );
  }

  getAppBar() {
    return AppBar(
      title: Text(widget.selectedMusclesList.length < 1
          ? "Selecciona los elementos"
          : "${widget.selectedMusclesList.length} elementos seleccionados"),
      actions: <Widget>[
        widget.selectedMusclesList.length < 1
            ? Container()
            : InkWell(
                onTap: () {
                  Navigator.pop(context, widget.selectedMusclesList);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.check),
                ))
      ],
    );
  }
}
