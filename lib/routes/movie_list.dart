import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xlo_auction_app/authentication/authentication.dart';
import 'package:xlo_auction_app/model/movie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:xlo_auction_app/routes/add_movie.dart';

class MovieList extends StatefulWidget {
  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  TextEditingController titleSearch = TextEditingController();
  var isDoneToggleSearch = false;
  var _tapPosition;
  List<Movie> filteredMovies = [];

  @override
  void dispose() {
    titleSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<AuthenticationService>(context).getCurrentUserId();

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0.0),
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.dark,
        title: TextField(
          cursorColor: Colors.black,
          controller: titleSearch,
          // style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            labelText: 'search',
            filled: true,
            fillColor: Colors.white,
            focusColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          ),
        ),
        actions: [
          Row(
            children: [
              Text(
                'Watched:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: isDoneToggleSearch,
                onChanged: (bool newValue) {
                  setState(() {
                    isDoneToggleSearch = newValue;
                  });
                },
              ),
            ],
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser)
                    .collection('movies')
                    .where('isDone')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  List<Movie> movies = snapshot.data.docs
                      .map<Movie>((movie) => Movie(
                          movie['title'],
                          movie['year'],
                          movie['poster'],
                          movie['isDone'],
                          movie.id))
                      .toList();

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      filteredMovies = filterMovieList(movies);
                    });
                  });

                  return ListView.builder(
                    itemExtent: 250,
                    itemCount: filteredMovies.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemBuilder: (context, index) {
                      // DocumentSnapshot documentSnapshot =
                      //     snapshot.data.docs[index];
                      final movie = filteredMovies[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4.0,
                        child: InkWell(
                          child: movie,
                          onTap: () {
                            movie.isDone = !movie.isDone;
                            updateMovieDoneStatus(movie.movieId, movie.isDone);
                          },
                          onLongPress: () {
                            showMovieOptions(movie, movie.poster);
                          },
                          onTapDown: _storePosition,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Future<void> updateMovieDoneStatus(String documentId, bool isDone) async {
    final _auth = context.read<AuthenticationService>();
    final _firestore = context.read<FirebaseFirestore>();

    DocumentReference _movieReference = _firestore
        .collection('users')
        .doc(_auth.getCurrentUserId())
        .collection('movies')
        .doc(documentId);

    await _movieReference
        .update({'isDone': isDone})
        .then((value) => print('isDone changed'))
        .catchError((error) => print('failed to change isDone $error'));
  }

  Future<void> showMovieOptions(Movie movie, String url) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition & const Size(20, 20), Offset.zero & overlay.size),
      items: [
        PopupMenuItem(
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              editMovie(movie);
            },
            child: Row(
              children: [Icon(Icons.edit), SizedBox(width: 10), Text('Edit')],
            ),
          ),
        ),
        PopupMenuItem(
          child: InkWell(
            onTap: () async {
              Navigator.pop(context);
              await deleteMovieFromFirebase(movie.movieId, url);
            },
            child: Row(
              children: [
                Icon(Icons.delete),
                SizedBox(width: 10),
                Text('Delete')
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> deleteMovieFromFirebase(String documentId, String url) async {
    final _auth = context.read<AuthenticationService>();
    final _storage = context.read<FirebaseStorage>();
    final _firestore = context.read<FirebaseFirestore>();

    final _movieReference = _firestore
        .collection('users')
        .doc(_auth.getCurrentUserId())
        .collection('movies')
        .doc(documentId);

    var _posterReference;
    if (url != '') {
      _posterReference = _storage.refFromURL(url);

      _firestore.runTransaction((transaction) async {
        await _movieReference.delete();
        await _posterReference.delete();
      }).then((value) => showSnackBar('Movie deleted'));
    } else {
      await _movieReference
          .delete()
          .then((value) => showSnackBar('Movie deleted'));
    }
  }

  void editMovie(Movie movie) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => AddMovie(editedMovie: movie)));
  }

  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ));
    }
  }

  List<Movie> filterMovieList(List<Movie> movies) {
    return movies
        .where((movie) =>
            movie.isDone == isDoneToggleSearch &&
            movie.title.toLowerCase().contains(titleSearch.text))
        .toList();
  }

  Future<void> logout() async {
    final _auth = context.read<AuthenticationService>();
    _auth.logout();
  }
}
