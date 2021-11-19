import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app_listview_builder/movie.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: GoogleFonts.raleway().fontFamily,
      ),
      title: 'Movies App',
      initialRoute: '/',
      routes: {
        '/': (context) => SearchPage(),
      },
    );
  }
}
class SearchPage extends StatefulWidget{
  @override
  _SearchPageState createState() {
    return _SearchPageState();
  }

}

class _SearchPageState extends State<SearchPage>{

  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6C0303),
        title: const Text('Movies App'),
      ),
      body: Container(
        height:  MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 100, 15, 15),
          child: TextField(
            style: TextStyle(
              fontSize: 25,
            ),
            cursorColor: Color(0xFF6C0303),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              suffixIcon: Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6C0303),
                ),
                child: IconButton(
                  icon: Icon(Icons.search, color: Colors.white, size: 30,),
                  splashColor: Colors.grey,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MoviesList(query: myController.text.trim(),)),
                    );
                  },
                ),
              ),
              helperText: 'Enter at least 3 letters to display results',
              hintText: 'Search for a movie',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1.0),
              ),
            ),
            textAlign: TextAlign.center,
            controller: myController,
          ),
        ),

      ),
    );
  }

}
class MoviesList extends StatelessWidget{
  final String query;

  const MoviesList({Key key, this.query}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text('Search results'),
      ),
      body: ListDisplay(query: this.query),
    );
  }

}

class ListDisplay extends StatefulWidget{
  final String query;

  const ListDisplay({Key key, this.query}) : super(key: key);

  @override
  _ListDisplayState createState() {
    return _ListDisplayState();
  }
}

class _ListDisplayState extends State<ListDisplay>{

  Future<List<Movie>> futureMovies;
  Future<List<Movie>> fetchMovies() async {

    final http.Response response = await http.get("https://www.omdbapi.com/?s=${widget.query}&apikey=bb716acc");
    if (jsonDecode(response.body)['Response'] == 'False'){
      if(jsonDecode(response.body)['Error'] == 'Too many results.' || jsonDecode(response.body)['Error'] == 'Incorrect IMDb ID.')
        throw ("Please enter at least 3 letters!");
      else
        throw(jsonDecode(response.body)['Error']);
    }
    else if (response.statusCode == 200) {
      // success, parse json data
      List jsonArray = jsonDecode(response.body)['Search'];
      List<Movie> movies = jsonArray.map((x)=> Movie.fromJson(x)).toList();
      return movies;
    }
    else{
      throw ("Failed to load data");
    }
  }

  @override
  void initState() {
    super.initState();
    this.futureMovies = fetchMovies();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<Movie>>(
        future: this.futureMovies,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Movie> movies = snapshot.data;
            return ListView.builder(
              itemCount: movies.length,
              itemBuilder: (BuildContext context, int index){
                return MovieItem(movie: movies[index]);
              },
            );
          }
          else if (snapshot.hasError) {
            return
              Center(child: Text(snapshot.error, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),));
          }
          return Center(
              child:CircularProgressIndicator()
          );
        }
    );
  }
}

class MovieItem extends StatelessWidget {

  final Movie movie;

  MovieItem({@required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      height: 120,
      child: Card(
        child: Row(
          children: [
            Image.network(this.movie.image),
            Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 5, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        this.movie.title, style: TextStyle(fontWeight: FontWeight.bold),),
                      Text(this.movie.type),
                      Row(
                        children:[
                          Expanded(
                            child:  Container(
                              alignment: Alignment.centerRight,
                              child: Text(this.movie.year),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}



