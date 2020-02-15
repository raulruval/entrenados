import 'package:flutter/material.dart';
import 'package:entrenados/widgets/griditem.dart';

class Musclesinvolved extends StatefulWidget {
  @override
  _MusclesinvolvedState createState() => _MusclesinvolvedState();
}

class _MusclesinvolvedState extends State<Musclesinvolved> {
  List<ItemMuscles> itemMusclesList;
  List<ItemMuscles> selectedMuscles;

  @override
  void initState() {
    loadListMuscles();
    super.initState();
  }

  loadListMuscles() {
    itemMusclesList = List();
    selectedMuscles = List();
    itemMusclesList.add(ItemMuscles("assets/img/arm.jpg", "Brazos", 1));
    itemMusclesList.add(ItemMuscles("assets/img/leg.jpg", "Piernas", 2));
    itemMusclesList.add(ItemMuscles("assets/img/espalda.jpg", "Espalda", 3));
    itemMusclesList.add(ItemMuscles("assets/img/abs.jpg", "Abdominales", 4));
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
            mainAxisSpacing: 25,
            
          ),
          

          itemBuilder: (context, index) {
            return GridItem(
                
                item: itemMusclesList[index],
                 
                isSelected: (bool value) {
                  setState(() {
                    if (value) {
                      selectedMuscles.add(itemMusclesList[index]);
                    } else {
                      selectedMuscles.remove(itemMusclesList[index]);
                    }
                  });
                  print("$index : $value");
                },
                key: Key(itemMusclesList[index].musclenumber.toString()));
          }),
    );
  }

  getAppBar() {
    return AppBar(
      title: Text(selectedMuscles.length < 1
          ? "Selecciona los elementos"
          : "${selectedMuscles.length} elementos seleccionados"),
      actions: <Widget>[
        selectedMuscles.length < 1
            ? Container()
            : InkWell(
                onTap: () {
                  setState(() {
                    for (int i = 0; i < selectedMuscles.length; i++) {
                      itemMusclesList.remove(selectedMuscles[i]);
                    }
                    selectedMuscles = List();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.check),
                ))
      ],
    );
  }
}

class ItemMuscles {
  String imgURL;
  String muscleName;
  int musclenumber;

  ItemMuscles(this.imgURL, this.muscleName, this.musclenumber);
}
