//
//  MovieViewModel.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 2/24/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var topRatedMovies: [Movie] = []
    @Published var nowPlayingMovies: [Movie] = []
    @Published var mostPopularMovies: [Movie] = []
    @Published var userFavoriteMovies: [Movie] = []
    @Published var userFavoriteMovieList: [String:Any] = [String:Any]()
    
    private let movieStore = "MovieStored"
    
    func fetchMovies() {
        // Construct the URLs with the API key
        let bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3NWZjMGU5YjBiNWQ3YmIyN2Q1ZjRhMzYzOTQ5YjZiMyIsInN1YiI6IjY1ZDkyZmZjMGYwZGE1MDE2MjMyMmNjMyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SKA1aWfUuedyy8jl0u2cpNhFMsYSU397sgsup64Rn7k"
        let nowPlayingUrl = "https://api.themoviedb.org/3/movie/now_playing?language=en-US&page=1"
        let mostPopularUrl = "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1"
        let topRatedUrl = "https://api.themoviedb.org/3/movie/top_rated?language=en-US&page=1"
        
        // Fetch data for each category
        fetchUserFavouriteMovieList()
        
        fetchMoviesForCategory(bearerToken:bearerToken,url: nowPlayingUrl) { movies in
            self.nowPlayingMovies = movies
        }
        fetchMoviesForCategory(bearerToken:bearerToken,url: mostPopularUrl) { movies in
            self.mostPopularMovies = movies
        }
        fetchMoviesForCategory(bearerToken:bearerToken,url: topRatedUrl) { movies in
            self.topRatedMovies = movies
        }
    }
    
    private func fetchMoviesForCategory(bearerToken: String, url: String, completion: @escaping ([Movie]) -> Void) {
        guard let url = URL(string: url) else {
            print("Invalid URL: \(url)")
            return
        }
        print("Checking URL: \(url)")
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //         Use the correct key for the "Authorization" header
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("data ", data)
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                
                DispatchQueue.main.async {
                    print("Entering dispatcher Queue")
                    completion(movieResponse.results)
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    
    private func saveMoviesToUserDefaults() {
        do {
            let encodedData = try JSONEncoder().encode(movies)
            UserDefaults.standard.set(encodedData, forKey: movieStore)
        } catch {
            print("Error encoding movies:", error)
        }
    }
    
    
    func loadMoviesFromUserDefaults() {
        if let encodedData = UserDefaults.standard.data(forKey: movieStore) {
            do {
                let decodedMovies = try JSONDecoder().decode([Movie].self, from: encodedData)
                self.movies = decodedMovies
            } catch {
                print("Error decoding movies:", error)
            }
        }
    }
    
    func deleteItem(at offsets: IndexSet) {
        movies.remove(atOffsets: offsets)
        self.saveMoviesToUserDefaults()
    }
    
    
    func fetchUserFavouriteMovieList(){
        guard var user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).getDocument() { snapshot, err in
            guard let data = snapshot?.data() else {
                return
            }
            
            guard let movieIds = data["movieIds"] as? [String: [String: Any]] else {
                return
            }
            
            for (key, movieData) in movieIds {
                if let movie = self.createMovie(from: movieData) {
                    self.userFavoriteMovieList[key] = movie
                }
            }
            
            print(self.userFavoriteMovieList)
        }

        
    }
    
    func createMovie(from movieData: [String: Any]) -> Movie? {
        do {
            var decodedMovie = movieData
            
            // Convert genres array of strings back to an array of dictionaries
            if let genres = decodedMovie["genres"] as? [String] {
                decodedMovie["genres"] = genres.map { genreName in
                    ["name": genreName] // Convert each genre name to a dictionary with a "name" key
                }
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: decodedMovie, options: [])
            let movie = try JSONDecoder().decode(Movie.self, from: jsonData)
            return movie
        } catch {
            print("Error decoding movie data: \(error)")
            return nil
        }
    }


}
