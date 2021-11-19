class Movie {
  String title;
  String imdbID;
  String image;
  String year;
  String type;

  Movie({this.title, this.image, this.year, this.imdbID, this.type});

  factory Movie.fromJson(dynamic json) {
    return Movie(
        title: json['Title'],
        image: json['Poster'],
        year: json['Year'],
        type: json['Type'],
        imdbID: json['imdbID']
    );
  }
}
