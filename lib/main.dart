import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: MovieListPage(),
  ));
}

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  late Future<List<Map<String, dynamic>>> _movies;

  @override
  void initState() {
    super.initState();
    _movies = fetchMovies();
  }

  Future<List<Map<String, dynamic>>> fetchMovies() async {
    const String apiKey = "bc63863a33654057a2d1def8e547206d";
    const String language = "pt-BR";
    const String url = "https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=$language&page=1";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body)["results"];
      return responseData.map((movie) => Map<String, dynamic>.from(movie)).toList();
    } else {
      throw Exception('Falha ao carregar os filmes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Últimos Lançamentos'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _movies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else {
            final movies = snapshot.data!;
            return ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 300,
                              child: movie['poster_path'] != null
                                ? Image.network('https://image.tmdb.org/t/p/w300${movie['poster_path']}', fit: BoxFit.cover)
                                : const Icon(Icons.movie, size: 100),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(movie['title'] ?? '', style: Theme.of(context).textTheme.headlineMedium),
                                const SizedBox(height: 8),
                                Text(movie['overview'] ?? ''),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
