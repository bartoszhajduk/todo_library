import 'package:flutter/material.dart';

class MovieSuggestion {
  final String title;
  final String year;
  final String poster;

  MovieSuggestion(
      {@required this.title, @required this.year, @required this.poster});

  factory MovieSuggestion.fromJson(Map<String, dynamic> json) {
    return MovieSuggestion(
      title: json['Title'],
      year: json['Year'],
      poster: json['Poster'],
    );
  }
}
