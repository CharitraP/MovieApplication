//
//  MovieListApp.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 2/24/24.
//

import SwiftUI
import Firebase


@main
struct MovieListApp: App {
    
    init(){
        FirebaseApp.configure()
        print("firebase configured")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
