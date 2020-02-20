import 'package:entrenados/models/item.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/griditem.dart';

class Musclesinvolved extends StatefulWidget {
  final List<Item> selectedMuscles;

  Musclesinvolved(this.selectedMuscles);

  @override
  _MusclesinvolvedState createState() => _MusclesinvolvedState();
}

class _MusclesinvolvedState extends State<Musclesinvolved> {
  static List<Item> itemMusclesList = List();
  @override
  void initState() {
    super.initState();
    print("Musculos involucrados guardados en equipamiento");
    print(widget.selectedMuscles);
    if (widget.selectedMuscles.length < 1) {
      loadListMuscles();
    }
  }

  loadListMuscles() {
    itemMusclesList = List();
    itemMusclesList.add(Item("assets/img/arm.jpg", "Bíceps", 1, false));
    itemMusclesList.add(Item("assets/img/leg.jpg", "Gemelos", 2, false));
    itemMusclesList.add(Item("assets/img/espalda.jpg", "Espalda", 3, false));
    itemMusclesList.add(Item("assets/img/abs.jpg", "Abdominales", 4, false));
    itemMusclesList.add(Item("assets/img/triceps.jpg", "Tríceps", 5, false));
    itemMusclesList.add(Item("assets/img/shoulder.jpg", "Hombros", 6, false));
    itemMusclesList
        .add(Item("assets/img/quadriceps.jpg", "Cuádriceps", 7, false));
    itemMusclesList.add(Item("assets/img/forearm.jpg", "Antebrazo", 8, false));
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
              isSelected: (value) {
                setState(() {
                  if (value) {
                    print("En el bucle");
                    if (widget.selectedMuscles.length > 1) {
                      for (var i = 0; i < widget.selectedMuscles.length; i++) {
                        if (itemMusclesList[index].value ==
                            widget.selectedMuscles[i].value) {
                        } else {
                          itemMusclesList[index].value = true;
                          widget.selectedMuscles.add(itemMusclesList[index]);
                          print("hola");
                        }
                      }
                    } else {
                      itemMusclesList[index].value = true;
                      widget.selectedMuscles.add(itemMusclesList[index]);
                    }
                    for (var i = 0; i < widget.selectedMuscles.length; i++)
                      widget.selectedMuscles[i].value = true;
                  } else {
                    itemMusclesList[index].value = false;
                    widget.selectedMuscles.remove(itemMusclesList[index]);
                  }
                });
                print("$index : $value");
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
      title: Text(widget.selectedMuscles.length < 1
          ? "Selecciona los elementos"
          : "${widget.selectedMuscles.length} elementos seleccionados"),
      actions: <Widget>[
        widget.selectedMuscles.length < 1
            ? Container()
            : InkWell(
                onTap: () {
                  Navigator.pop(context, widget.selectedMuscles);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.check),
                ))
      ],
    );
  }
}
