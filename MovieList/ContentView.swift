//
//  ContentView.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 2/24/24.

import SwiftUI
import Firebase

struct ContentView: View {
    @StateObject private var authState = AuthenticationState()

    var body: some View {
        Group {
            if authState.isLoggedIn {
                HomeViewPage()
                .environmentObject(authState)
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}

