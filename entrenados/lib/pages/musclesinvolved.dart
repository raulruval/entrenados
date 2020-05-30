import 'package:entrenados/models/item.dart';
import 'package:entrenados/models/searchModel.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/griditem.dart';

class Musclesinvolved extends StatefulWidget {
  final List<Item> selectedMusclesList;
    final SearchModel searchModel;

  Musclesinvolved(this.selectedMusclesList,this.searchModel);

  @override
  _MusclesinvolvedState createState() => _MusclesinvolvedState();

}

class _MusclesinvolvedState extends State<Musclesinvolved> {
  static List<Item> itemMusclesList = List();
  @override
  void initState() {
    super.initState();
    if (widget.selectedMusclesList.length < 1) {
      itemMusclesList = widget.searchModel.muscles;
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
        
                if (widget.selectedMusclesList.length > 1) {
                  for (var i = 0; i < widget.selectedMusclesList.length; i++) {
                    if (itemMusclesList[index].isSelected ==
                        widget.selectedMusclesList[i].isSelected) {
                    } else {
                      itemMusclesList[index].isSelected = true;
                      widget.selectedMusclesList.add(itemMusclesList[index]);
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
