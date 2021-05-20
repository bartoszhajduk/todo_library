import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:xlo_auction_app/authentication/authentication.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:xlo_auction_app/model/movie.dart';
import 'package:xlo_auction_app/model/movie_suggestion.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

var uuid = Uuid();
final placeholderUrl =
    'https://firebasestorage.googleapis.com/v0/b/todo-library.appspot.com/o/placeholder.png?alt=media&token=f7318b2c-d40e-4133-98d1-ce11fed53595';

class AddMovie extends StatefulWidget {
  Movie editedMovie;
  AddMovie({this.editedMovie});

  @override
  _AddMovieState createState() => _AddMovieState();
}

class _AddMovieState extends State<AddMovie> {
  final TextEditingController titleController = TextEditingController();
  final picker = ImagePicker();
  var image;
  var selectedYear = (DateTime.now().year).toString();
  var isDone = false;

  @override
  void initState() {
    super.initState();
    if (widget.editedMovie != null) {
      loadEditedMovie(widget.editedMovie);
    } else {
      urlToFile(placeholderUrl);
    }
  }

  void loadEditedMovie(Movie movie) {
    setState(() {
      titleController.text = movie.title;
      selectedYear = movie.year;
      isDone = movie.isDone;
      urlToFile(movie.poster);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.purple[900], //or set color with: Color(0xFF0000FF)
    ));
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    width: MediaQuery.of(context).size.width,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: (image != null)
                          ? Image.file(image)
                          : Image.asset('assets/images/placeholder.png'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_a_photo,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () => pickImage(),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 35),
                child: TypeAheadField<MovieSuggestion>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: titleController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      labelText: 'search',
                    ),
                  ),
                  suggestionsCallback: getMoviesByTitle,
                  itemBuilder: (context, MovieSuggestion movie) {
                    return ListTile(
                      title: Text('${movie.year}: ${movie.title}'),
                    );
                  },
                  onSuggestionSelected: (movie) {
                    titleController.text = movie.title;
                    setState(() {
                      selectedYear = movie.year.split('–')[0];
                    });
                    urlToFile(movie.poster);
                  },
                  noItemsFoundBuilder: (context) => Text('Nothing found'),
                  errorBuilder: (BuildContext context, Object error) => Text(
                    "No internet connection",
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                contentPadding: EdgeInsets.symmetric(horizontal: 35),
                title: Text(selectedYear),
                onTap: () => pickYear(context),
              ),
              CheckboxListTile(
                title: Text('Watched'),
                contentPadding: EdgeInsets.symmetric(horizontal: 35),
                secondary: Icon(Icons.check),
                value: isDone,
                onChanged: (value) {
                  setState(() {
                    isDone = value;
                  });
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: FloatingActionButton(
                    onPressed: () {
                      if (widget.editedMovie != null) {
                        updateMovie(context);
                      } else {
                        addMovie(context);
                      }
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void pickYear(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Year"),
          content: Container(
            width: 300,
            height: 300,
            child: Theme(
              data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light().copyWith(
                primary: Colors.deepPurple,
              )),
              child: YearPicker(
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                initialDate: DateTime.now(),
                selectedDate: DateTime(int.parse(selectedYear)),
                onChanged: (dateTime) {
                  setState(() {
                    selectedYear = dateTime.year.toString();
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<MovieSuggestion>> getMoviesByTitle(String query) async {
    final url = Uri.parse('http://www.omdbapi.com/?apikey=2aa734b4&s=$query)');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      Iterable list = result['Search'];
      return list != null
          ? list.map((movie) => MovieSuggestion.fromJson(movie)).toList()
          : List.empty();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('no image selected');
      }
    });
  }

  Future<void> urlToFile(String imageUrl) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' + (uuid.v4()).toString() + '.png');
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);

    if (this.mounted) {
      setState(() {
        image = file;
      });
    }
  }

  Future<void> addMovie(BuildContext context) async {
    final _auth = context.read<AuthenticationService>();
    final _firestore = context.read<FirebaseFirestore>();

    CollectionReference _moviesReference = _firestore
        .collection('users')
        .doc(_auth.getCurrentUserId())
        .collection('movies');

    final url = await uploadImageToFirebase(context);
    try {
      await _moviesReference.add({
        'title': titleController.text,
        'year': selectedYear,
        'poster': url,
        'isDone': isDone,
      }).then((value) => showSnackBar('Movie added'));
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> updateMovie(BuildContext context) async {
    final _auth = context.read<AuthenticationService>();
    final _storage = context.read<FirebaseStorage>();
    final _firestore = context.read<FirebaseFirestore>();

    final _movieReference = _firestore
        .collection('users')
        .doc(_auth.getCurrentUserId())
        .collection('movies')
        .doc(widget.editedMovie.movieId);

    final url = await uploadImageToFirebase(context);
    final _posterReference = _storage.refFromURL(widget.editedMovie.poster);

    try {
      _firestore.runTransaction((transaction) async {
        await _posterReference.delete();
        await _movieReference.update({
          'title': titleController.text,
          'year': selectedYear,
          'poster': url,
          'isDone': isDone,
        });
      }).then((value) => showSnackBar('Movie updated'));
    } on FirebaseException catch (e) {
      print('update error: ' + e.message);
    }

    Navigator.pop(context);
    showSnackBar('Movie updated');
  }

  Future<String> uploadImageToFirebase(BuildContext context) async {
    final _auth = context.read<AuthenticationService>();
    final _storage = context.read<FirebaseStorage>();
    final loggedUser = _auth.getCurrentUserId();

    final fileName = uuid.v4();
    final taskSnapshot =
        await _storage.ref('$loggedUser/$fileName').putFile(image);

    return await taskSnapshot.ref.getDownloadURL();
  }

  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
