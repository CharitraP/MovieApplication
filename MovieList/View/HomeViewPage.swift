
//
//  HomeViewPage.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 2/24/24.
//

import SwiftUI

struct HomeViewPage: View {
    @ObservedObject var viewModel = MovieListViewModel()
    @State var isMovieRowActive = false
    @State var movieId:Int = 0
    @State private var selectedTab = "Top Rated"
    
    var body: some View {
        NavigationStack {
            VStack {
                
          //Picker to pick which movies list to watch
        Picker("", selection: $selectedTab) {
            Text("Top Rated").tag("Top Rated")
            Text("Now Playing").tag("Now Playing")
            Text("Most Popular").tag("Most Popular")
            Text("User Favorite").tag("User Favorite")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color(#colorLiteral(red: 0.05, green: 0.2, blue: 0.3, alpha: 2)))
            .onChange(of: selectedTab) { newValue in
            if newValue == "User Favorite" {
                viewModel.fetchUserFavouriteMovieList()
            }
        }
                // List of movies
                List {
                    ForEach(filteredMovies) { movie in
                        NavigationLink(destination: MovieDetailView(movieList: $viewModel.userFavoriteMovieList,movieId: movie.id)) {
                            MovieRowView(movieList: $viewModel.userFavoriteMovieList, movie: movie)
                        }
                    }
                    .onDelete(perform: viewModel.deleteItem)
                }.background(Color(#colorLiteral(red: 0.05, green: 0.2, blue: 0.3, alpha: 2)))
                .listStyle(PlainListStyle())
                .navigationDestination(isPresented: self.$isMovieRowActive){
                    MovieDetailView(movieList: $viewModel.userFavoriteMovieList, movieId: self.movieId)
                }
            }
            .navigationBarTitle("Movies")
            .navigationBarItems(trailing: NavigationLink(destination: ProfileView().environmentObject(AuthenticationState())) {
                Image(systemName: "person.circle")
            })
        }
      .onAppear(){
        viewModel.fetchUserFavouriteMovieList()
        if(viewModel.nowPlayingMovies.isEmpty) {
            viewModel.fetchMovies()
        }
          self.isMovieRowActive = UserDefaults.standard.bool(forKey: "isMovieRowActive")
          self.movieId = UserDefaults.standard.integer(forKey: "MovieId")
    }

}
    var filteredMovies: [Movie] {
            switch selectedTab {
            case "Top Rated":
                return viewModel.topRatedMovies
            case "Now Playing":
                return viewModel.nowPlayingMovies
            case "Most Popular":
                return viewModel.mostPopularMovies
            case "User Favorite":
                return viewModel.userFavoriteMovieList.compactMap { (key, value) -> Movie? in
                    return value as? Movie
                }
            default:
                return viewModel.topRatedMovies
            }
        }
}


struct HomeViewPage_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewPage()
    }
}
