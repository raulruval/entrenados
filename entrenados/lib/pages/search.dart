import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/models/searchModel.dart';
import 'package:entrenados/pages/activity.dart';
import 'package:entrenados/pages/search_post.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search>, SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchFutureResults;
  bool searchuser = false;
  bool workouts = true;
  TabController _tabController;

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

  handleBuscar(String consulta) {
    Future<QuerySnapshot> users = usersRef
        .where("displayName", isGreaterThanOrEqualTo: consulta)
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
        onFieldSubmitted: handleBuscar,
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
        child: SearchPost(SearchModel()),
      ),
    );
  }

  _getFab() {
    return _tabController.index == 0
        ? FloatingActionButton.extended(
            onPressed: () => print("Buscar"),
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
      child: Scaffold(
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _getFab(),
      ),
    );
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
