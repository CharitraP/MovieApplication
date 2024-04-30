//
//  LoginView.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 4/19/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var isRegistering = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showHomeView = false
    @State private var isLoginMode = true // Track if the user is in login or registration mode
    @State private var showAlert = false

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: isLoginMode ? loginUser : registerUser) {
                Text(isLoginMode ? "Login" : "Register")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isLoginMode ? Color.blue : Color.green)
                    .cornerRadius(5.0)
            }

            Button(action: {
                isLoginMode.toggle()
                clearFields()
            }) {
                Text(isLoginMode ? "Don't have a account? Register Please" : "Login")
                    .foregroundColor(.blue)
                    .padding()
            }

            if isLoggingIn || isRegistering {
                ProgressView()
            }

            NavigationLink(destination: HomeViewPage(), isActive: $showHomeView) {
                EmptyView()
            }
        }
        .padding()
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    func loginUser() {
            isLoggingIn = true
            errorMessage = ""
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                self.isLoggingIn = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    if self.errorMessage=="The supplied auth credential is malformed or has expired."{
                        self.errorMessage="Wrong Password"
                    }
                    self.showAlert = true
                    return
                }
                showHomeView = true
            }
        }
    
    func registerUser() {
        isRegistering = true
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            isRegistering = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
                return
            }

            // Registration successful, save user details to Firestore
            let db = Firestore.firestore()
            let user = Auth.auth().currentUser

            if let user = user {
                let userData: [String: Any] = [
                    "email": user.email ?? ""
                    // Add other user details here if needed
                ]

                db.collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        print("Error saving user data: \(error.localizedDescription)")
                        self.errorMessage = "Error saving user data. Please try again."
                        showErrorAlert = true
                    } else {
                        // Successfully saved user data
                        print("User data saved successfully")
                        // Navigate to ProfileView
                        let profileEditView = UserProfileEditView(email: $email, password: $password)
                        let hostingController = UIHostingController(rootView: profileEditView)
                        UIApplication.shared.windows.first?.rootViewController?.present(hostingController, animated: true)
                    }
                }
            }
        }
    }

    func clearFields() {
        email = ""
        password = ""
        errorMessage = ""
    }
}
