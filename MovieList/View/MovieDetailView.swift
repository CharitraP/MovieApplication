//
//  MovieDetailView.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 2/24/24.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore

struct MovieDetailView: View {
    @Binding var movieList: [String:Any]
    @StateObject var detailViewModel: MovieDetailViewModel
    @State var isFavorite: Bool = false
    let movieId: Int

    init(movieList: Binding<[String:Any]> ,movieId: Int) {
        self._movieList = movieList
        self.movieId = movieId
        self._detailViewModel = StateObject(wrappedValue: MovieDetailViewModel())
    }

    var body: some View {
        ScrollView {
            VStack {
                if let movie = detailViewModel.movie {
                    Text(movie.title ?? "Unknown Title")
                        .font(.title)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .padding()
                        .foregroundColor(.white)
                    
                    
                    HStack {
                        if let releaseDate = movie.release_date {
                            Text(releaseDate).padding().font(.headline).foregroundColor(.white)
                        } else {
                            Text(" ")
                        }
                        if let runningTime = movie.runtime {
                            Text("\(runningTime)m").font(.headline).foregroundColor(.white)
                        } else {
                            Text(" ")
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) { // Adjust the spacing as needed
                            ForEach(0..<3) { _ in // Assuming you want to display two images horizontally
                                if let posterPath = movie.poster_path {
                                    let imageURL = "https://image.tmdb.org/t/p/w780\(posterPath)"
                                    // Use SDWebImageSwiftUI to asynchronously load and display the image
                                    WebImage(url: URL(string: imageURL))
                                        .resizable()
                                        .frame(width: 250, height: 250) // Adjust the frame size as needed
                                        .cornerRadius(35)
                                        .clipped()
                                }
                                if let backdropPath = movie.backdrop_path {
                                    let imageURL = "https://image.tmdb.org/t/p/w780\(backdropPath)"
                                    // Use SDWebImageSwiftUI to asynchronously load and display the image
                                    WebImage(url: URL(string: imageURL))
                                        .resizable()
                                        .frame(width: 250, height: 250) // Adjust the frame size as needed
                                        .cornerRadius(35)
                                        .clipped()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    // Ratings for the movie
                    VStack {
                        HStack(spacing:8) {
                            Text("   ")
                                .font(.headline)
                            
                            ForEach(movie.genres ?? [], id: \.id) { genre in
                                if let name = genre.name {
                                    Capsule()
                                        .fill(Color.white)
                                        .overlay(
                                            Text("\(name)")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                                .padding(8))
                                }
                            }
                        }
                        .padding()
                        HStack{
                            RatingStars(rating: movie.vote_average ?? 0).padding(25)
                            
                            Button(action: {
                                self.isFavorite.toggle()
                                // Add or remove the movie from the favorite list based on its state
                                movieList["\(movieId)"] = 1

                                
                                                    guard var user = Auth.auth().currentUser else { return }
                                                                let db = Firestore.firestore()
                               
                                setData(movie: movie, user: user, isFavorite: self.isFavorite){ error in
                                    if (error != nil) {
                                        print("An error occurred")
                                    }
                                    
                                }
                                
                                
                            }) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(isFavorite ? .red : .gray)
                                    .font(.title)
                            }
                            .padding(.trailing, 20)
                        }
                    }
                    Spacer()
                    Rectangle()
                        .frame(height: 0.5)
                    .foregroundColor(.white)
                    .padding(.vertical)
                    if let overview = movie.overview {
                        HStack {
                            Text("    Description")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        Text(overview)
                            .padding()
                            .foregroundColor(.white)
                    }
                } else {
                    Text("Loading...")
                }
                
                Spacer()
            }
        }.background(Color(#colorLiteral(red: 0.05, green :0.2, blue: 0.3,  alpha: 2)))
        .onAppear {
            self.isFavorite = movieList["\(movieId)"] != nil
            detailViewModel.fetchMovie(id: movieId)
            UserDefaults.standard.setValue(true, forKey: "isMovieRowActive")
            UserDefaults.standard.setValue(movieId, forKey: "MovieId")
        }
        .onDisappear{
            UserDefaults.standard.removeObject(forKey: "isMovieRowActive")
            UserDefaults.standard.removeObject(forKey: "MovieId")
        }
    }
    
    func setData(movie: Movie, user: User, isFavorite: Bool, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        // Convert Movie struct to a dictionary
        var movieData: [String: Any] = [:]
        
        movieData["backdrop_path"] = movie.backdrop_path ?? ""
        movieData["id"] = movie.id
        movieData["overview"] = movie.overview ?? ""
        movieData["poster_path"] = movie.poster_path ?? ""
        movieData["release_date"] = movie.release_date ?? ""
        movieData["runtime"] = movie.runtime ?? 0
        movieData["title"] = movie.title ?? ""
        movieData["vote_average"] = movie.vote_average ?? 0.0
        movieData["vote_count"] = movie.vote_count ?? 0
        movieData["genres"] = movie.genres?.map { $0.name } ?? [] // Assuming Genre has a 'name' property
        
        // Update movieIds field for the user
        var movieList: [String: Any] = [:]
        
        if isFavorite {
            self.movieList[String(movie.id)] = movieData
        } else {
            self.movieList.removeValue(forKey: String(movie.id))
        }
        
        // Convert the updated movieList to a new dictionary with only JSON-encodable types
        movieList = self.movieList.mapValues { value in
            if let valueDict = value as? [String: Any] {
                return valueDict
            } else {
                return nil
            }
        }.compactMapValues { $0 }
        
        db.collection("users").document(user.uid).setData(["movieIds": movieList], merge: true) { error in
            if let error = error {
                print("Error updating movie list for user: \(error)")
            } else {
                print("Movie list updated successfully!")
            }
            completion(error)
        }
    }
}

struct RatingStars: View {
    var rating: Double
    
    var body: some View {
        HStack {
            let filledStars = Int(rating / 2)
            ForEach(0..<filledStars, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            ForEach(0..<5-filledStars, id: \.self) { _ in
                Image(systemName: "star")
                    .foregroundColor(.gray)
            }
        }
    }
}


struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(movieList: .constant([String:Any]()), movieId: 123) // Pass a sample movieId here for preview
    }
}
