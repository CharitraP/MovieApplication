//
//  AuthenticationState.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 4/20/24.
//

import SwiftUI
import Firebase

class AuthenticationState: ObservableObject {
    @Published var isLoggedIn = false

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.isLoggedIn = user != nil
            print("current user")
            print(user)
        }
    }
}
