import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/models/item.dart';
import 'package:entrenados/models/searchModel.dart';
import 'package:entrenados/pages/activity.dart';
import 'package:entrenados/pages/searchPostsResponse.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/progress.dart';

class Search extends StatefulWidget {
  final SearchModel searchModel;

  Search({this.searchModel});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search>, SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchFutureResults;
  bool searchuser = false;
  bool workouts = true;
  TabController _tabController;
  String _durationDigits = "";
  String _musclesParsed = "";
  String _equipmentParsed = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  handleSearchUser(String consulta) {
    Future<QuerySnapshot> users = usersRef
        .where("displayName", isGreaterThanOrEqualTo: consulta.toUpperCase())
        .getDocuments();

    setState(() {
      searchFutureResults = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  buildSearch() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.teal[900],
        ),
      ),
      child: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Buscar un instructor...",
          prefixIcon: Icon(
            Icons.people,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => clearSearch(),
          ),
        ),
        onChanged: handleSearchUser,
      ),
    );
  }

  buildNoContent() {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 75.0),
            child: AutoSizeText(
              "Encontrar usuarios",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchFutureResults,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<UserResult> searchResults = [];
          snapshot.data.documents.forEach((doc) {
            User user = User.fromDocument(doc);
            UserResult searchResult = UserResult(user);
            searchResults.add(searchResult);
          });
          return Expanded(
            child: ListView(
              children: searchResults,
            ),
          );
        }
      },
    );
  }

  _getTrainers() {
    return Center(
      child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey[200],
                Colors.grey[350],
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                buildSearch(),
                searchFutureResults == null
                    ? buildNoContent()
                    : buildSearchResults(),
              ],
            ),
          )),
    );
  }

  Widget buildSearchPost(BuildContext context) {
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
                      spacing: 10.0,
                      children: [
                        for (var difficulty in widget.searchModel.difficulty)
                          ChoiceChip(
                              selected: widget.searchModel.selectedDifficulty ==
                                  difficulty,
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
                      spacing: 20.0,
                      children: [
                        for (var duration in widget.searchModel.durationWorkout)
                          ChoiceChip(
                              selected: widget.searchModel.selectedDuration ==
                                  duration,
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
                      spacing: 20.0,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text("Músculos involucrados",
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Wrap(
                      spacing: 20.0,
                      children: [
                        for (var muscle in widget.searchModel.muscles)
                          ChoiceChip(
                              selected: widget.searchModel.selectedMuscles
                                  .contains(muscle),
                              selectedColor: Colors.teal[900],
                              backgroundColor: Colors.teal[100],
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              labelStyle: widget.searchModel.selectedMuscles
                                      .contains(muscle)
                                  ? TextStyle(color: Colors.white)
                                  : TextStyle(color: Colors.black),
                              label: Text(muscle.name),
                              onSelected: (isSelected) {
                                setState(() {
                                  _onMusclesSelected(isSelected, muscle);
                                });
                              }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text("Material necesario",
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Wrap(
                      spacing: 20.0,
                      children: [
                        for (var equipment in widget.searchModel.equipment)
                          ChoiceChip(
                              selected: widget.searchModel.selectedEquipment
                                  .contains(equipment),
                              selectedColor: Colors.teal[900],
                              backgroundColor: Colors.teal[100],
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              labelStyle: widget.searchModel.selectedEquipment
                                      .contains(equipment)
                                  ? TextStyle(color: Colors.white)
                                  : TextStyle(color: Colors.black),
                              label: Text(equipment.name),
                              onSelected: (isSelected) {
                                setState(() {
                                  _onEquipmentSelected(isSelected, equipment);
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

  _getWorkouts() {
    return Center(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey[200],
              Colors.grey[350],
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: buildSearchPost(context),
      ),
    );
  }

  handleSearchPostTiles() {
    if (widget.searchModel.selectedDuration == "" ||
        widget.searchModel.selectedDifficulty == "" ||
        widget.searchModel.group == null) {
      SnackBar snackbar = SnackBar(
        content: AutoSizeText(
          "Debes seleccionar al menos una dificultad, duración y grupo.",
          maxLines: 1,
        ),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
    } else {
      _durationDigits = (widget.searchModel.selectedDuration)
          .replaceAll(RegExp('[A-Za-z]'), "")
          .substring(2);

      _musclesParsed = buildItemSequence(widget.searchModel.selectedMuscles);
      _equipmentParsed =
          buildItemSequence(widget.searchModel.selectedEquipment);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchPostsResponse(
                widget.searchModel.selectedDifficulty,
                int.parse(_durationDigits.replaceAll(" ", "")),
                widget.searchModel.selectedGroup,
                _musclesParsed,
                _equipmentParsed)),
      );
    }
  }

  buildItemSequence(List<Item> itemList) {
    List<int> sequence = [];
    itemList.forEach((item) => {sequence.add(item.index)});

    sequence.sort();
    String sortSequence = "";
    sequence.forEach((sequence) => {sortSequence += sequence.toString() + "-"});

    return sortSequence;
  }

  _getFab() {
    return _tabController.index == 0
        ? FloatingActionButton.extended(
            onPressed: () => handleSearchPostTiles(),
            label: Text("Buscar"),
            icon: Icon(Icons.search),
          )
        : Container();
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.grey[200],
            title: Text(
              "Buscar",
              style: TextStyle(
                color: Colors.teal,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              unselectedLabelColor: Colors.teal,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.teal[900],
              ),
              tabs: [
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.teal[900],
                        width: 1,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Entrenamientos"),
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.teal[900],
                        width: 1,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Entrenadores"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(controller: _tabController, children: [
            _getWorkouts(),
            _getTrainers(),
          ]),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _getFab(),
        ),
      ),
    );
  }

  void _onDifficultySelected(bool isSelected, String difficulty) {
    isSelected
        ? widget.searchModel.selectedDifficulty = difficulty
        : widget.searchModel.selectedDifficulty = "";
  }

  void _onDurationSelected(bool isSelected, String duration) {
    isSelected
        ? widget.searchModel.selectedDuration = duration
        : widget.searchModel.selectedDuration = "";
  }

  void _onGroupSelected(bool isSelected, String group) {
    isSelected
        ? widget.searchModel.selectedGroup.add(group)
        : widget.searchModel.selectedGroup.remove(group);
  }

  void _onMusclesSelected(bool isSelected, Item muscle) {
    isSelected
        ? widget.searchModel.selectedMuscles.add(muscle)
        : widget.searchModel.selectedMuscles.remove(muscle);
  }

  void _onEquipmentSelected(bool isSelected, Item equipment) {
    isSelected
        ? widget.searchModel.selectedEquipment.add(equipment)
        : widget.searchModel.selectedEquipment.remove(equipment);
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
