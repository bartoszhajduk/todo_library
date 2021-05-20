import 'package:flutter/material.dart';

final placeholderUrl =
    'https://firebasestorage.googleapis.com/v0/b/todo-library.appspot.com/o/placeholder.png?alt=media&token=9580d9e2-7bd7-4edf-acab-cd5ca62eb3ea';

class Movie extends StatelessWidget {
  final String title;
  final String year;
  final String poster;
  bool isDone;
  final movieId;

  Movie(this.title, this.year, this.poster, this.isDone, this.movieId);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.network(
          poster != '' ? poster : placeholderUrl,
          width: 175,
          height: 250,
          fit: BoxFit.cover,
        ),
        Expanded(
          child: Container(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    child: Text(title,
                        style: new TextStyle(
                          fontSize: 26,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    alignment: Alignment.topLeft,
                  ),
                  Align(
                    child: Text(
                      year,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    alignment: Alignment.topLeft,
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Checkbox(
                        value: isDone,
                        onChanged: (bool newValue) {
                          isDone = newValue;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
