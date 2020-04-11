import 'package:entrenados/models/searchModel.dart';
import 'package:flutter/material.dart';

class SearchPost extends StatefulWidget {
  final SearchModel searchModel;

  SearchPost(this.searchModel);
  @override
  _SearchPostState createState() => _SearchPostState();
}

class _SearchPostState extends State<SearchPost> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Center(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text("Dificultad",
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Wrap(
                      spacing: MediaQuery.of(context).size.width * 0.0465,
                      children: [
                        for (var difficulty in widget.searchModel.difficulty)
                          ChoiceChip(
                              selected: widget.searchModel.selectedDifficulty
                                  .contains(difficulty),
                              selectedColor: Colors.teal[900],
                              backgroundColor: Colors.teal[100],
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              labelStyle: widget.searchModel.selectedDifficulty
                                      .contains(difficulty)
                                  ? TextStyle(color: Colors.white)
                                  : TextStyle(color: Colors.black),
                              label: Text(difficulty),
                              onSelected: (isSelected) {
                                setState(() {
                                  _onDifficultySelected(isSelected, difficulty);
                                });
                              }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text("Duración aproximada",
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Wrap(
                      spacing: MediaQuery.of(context).size.width * 0.098,
                      children: [
                        for (var duration in widget.searchModel.duration)
                          ChoiceChip(
                              selected: widget.searchModel.selectedDuration
                                  .contains(duration),
                              selectedColor: Colors.teal[900],
                              backgroundColor: Colors.teal[100],
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              labelStyle: widget.searchModel.selectedDuration
                                      .contains(duration)
                                  ? TextStyle(color: Colors.white)
                                  : TextStyle(color: Colors.black),
                              label: Text(duration),
                              onSelected: (isSelected) {
                                setState(() {
                                  _onDurationSelected(isSelected, duration);
                                });
                              }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text("Grupo",
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Wrap(
                      spacing: MediaQuery.of(context).size.width * 0.08,
                      children: [
                        for (var group in widget.searchModel.group)
                          ChoiceChip(
                              selected: widget.searchModel.selectedGroup
                                  .contains(group),
                              selectedColor: Colors.teal[900],
                              backgroundColor: Colors.teal[100],
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              labelStyle: widget.searchModel.selectedGroup
                                      .contains(group)
                                  ? TextStyle(color: Colors.white)
                                  : TextStyle(color: Colors.black),
                              label: Text(group),
                              onSelected: (isSelected) {
                                setState(() {
                                  _onGroupSelected(isSelected, group);
                                });
                              }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      
      ],
    );
  }

  void _onDifficultySelected(bool isSelected, String difficulty) {
    isSelected
        ? widget.searchModel.selectedDifficulty.add(difficulty)
        : widget.searchModel.selectedDifficulty.remove(difficulty);
    print(widget.searchModel.selectedDifficulty);
  }

  void _onDurationSelected(bool isSelected, String duration) {
    isSelected
        ? widget.searchModel.selectedDuration.add(duration)
        : widget.searchModel.selectedDuration.remove(duration);
    print(widget.searchModel.selectedDuration);
  }

  void _onGroupSelected(bool isSelected, String group) {
    isSelected
        ? widget.searchModel.selectedGroup.add(group)
        : widget.searchModel.selectedGroup.remove(group);
    print(widget.searchModel.selectedGroup);
  }
}
