//
//  MovieRowView.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 2/24/24.
//


import SwiftUI
import SDWebImageSwiftUI

struct MovieRowView: View {
    
    @State var isFavorite: Bool = false
    @Binding var movieList: [String:Any]
    let movie: Movie
    
    var body: some View {
        HStack {
            if let poster_path = movie.poster_path {
                let imageURL = "https://image.tmdb.org/t/p/w154\(poster_path)"
                WebImage(url: URL(string: imageURL))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .cornerRadius(35)
                    .clipped()
            }
            
            Text(movie.title ?? "Unknown Title")
                .font(.headline)
                .padding(20)
            
            Spacer()
            
            Button(action: {
                self.isFavorite.toggle()
            }) {
                Image(systemName: (movieList["\(movie.id)"] != nil) ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
                    .font(.title)
            }
            .padding(.trailing, 20)
        }
        .contentShape(Rectangle()) // Ensure the whole row is tappable
        .onAppear(){
        }
    }
}

struct MovieRowView_Previews: PreviewProvider {
    static var previews: some View {
        MovieRowView(movieList: .constant([String:Any]()), movie: Movie(backdrop_path: "/oBIQDKcqNxKckjugtmzpIIOgoc4.jpg",id:0,title: "Land Of Bad"))
    }
}

