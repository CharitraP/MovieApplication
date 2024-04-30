//
//  MovieDetailViewModel.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 2/28/24.
//

import Foundation
import SwiftUI

class MovieDetailViewModel: ObservableObject {
    @Published var movie: Movie?

    func fetchMovie(id: Int) {
        let bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3NWZjMGU5YjBiNWQ3YmIyN2Q1ZjRhMzYzOTQ5YjZiMyIsInN1YiI6IjY1ZDkyZmZjMGYwZGE1MDE2MjMyMmNjMyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SKA1aWfUuedyy8jl0u2cpNhFMsYSU397sgsup64Rn7k"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let result: Movie = try JSONDecoder().decode(Movie.self, from: data)
                DispatchQueue.main.async {
                    self.movie = result
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
