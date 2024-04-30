//
//  ProfileView.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 4/20/24.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @State private var isShowingLogoutAlert = false
    @EnvironmentObject var authState: AuthenticationState
    @State private var userEmail: String = ""
    @State private var userName: String = ""
    @State private var userAge: String = ""
    @State private var userBio: String = ""
    @State private var profileImage: UIImage?
    @State private var isEditing = false
    @State private var isPickerShowing = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            isShowingLogoutAlert = true
                        }) {
                            Image(systemName: "power")
                                .foregroundColor(.red)
                        }
                        .alert(isPresented: $isShowingLogoutAlert) {
                            Alert(
                                title: Text("Logout"),
                                message: Text("Are you sure you want to log out?"),
                                primaryButton: .destructive(Text("Logout")) {
                                    logoutUser()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        .padding()
                        Spacer()
                        
                        Text("Profile")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button("Edit") {
                            isEditing.toggle()
                        }
                    }
                    
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    }
                    if isEditing {
                        Button(action: {
                            isPickerShowing = true
                        }) {
                            Text("Select Profile Image")
                        }
                        .sheet(isPresented: $isPickerShowing) {
                            ImagePickerDelegate(selectedImage: $profileImage, isPickerShowing: $isPickerShowing)
                        }
                    }
                    
                    TextField("Email", text: $userEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(true)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    TextField("Name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    TextField("Age", text: $userAge)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    TextField("Bio", text: $userBio)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    Button("Save") {
                        isEditing = false
                        updateUserData()
                    }
                    .disabled(!isEditing)
                    .padding()
                }
                .background(Color(#colorLiteral(red: 0.05, green: 0.2, blue: 0.3, alpha: 2)))
                .padding()
                .onAppear(perform: fetchUserData)
            }
        }
    }

    func logoutUser() {
        do {
             try Auth.auth().signOut()
            authState.isLoggedIn = false
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
    }

    func fetchUserData() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        // Fetch user document from Firestore
        db.collection("users").document(user.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                userEmail = user.email ?? ""
                userName = data?["name"] as? String ?? ""
                userAge = data?["age"] as? String ?? ""
                userBio = data?["bio"] as? String ?? ""
                
                // Fetch profile image URL from Firestore and load the image
                let profileImageURL = data?["profileImageURL"] as? String ?? ""
                if let url = URL(string: profileImageURL) {
                    DispatchQueue.global().async {
                        if let imageData = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                self.profileImage = UIImage(data: imageData)
                            }
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    func updateUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let storage = Storage.storage().reference()

        if let profileImage = profileImage {
            let imageData = profileImage.jpegData(compressionQuality: 0.8)
            let imageRef = storage.child("profile_images/\(user.uid).jpg")

            imageRef.putData(imageData!, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading profile image: \(error.localizedDescription)")
                    return
                }

                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting profile image URL: \(error.localizedDescription)")
                        return
                    }

                    guard let imageURL = url?.absoluteString else {
                        return
                    }

                    let userData: [String: Any] = [
                        "name": userName,
                        "email": userEmail,
                        "age": userAge,
                        "bio": userBio,
                        "profileImageURL": imageURL
                    ]

                    db.collection("users").document(user.uid).setData(userData, merge: true) { error in
                        if let error = error {
                            print("Error updating user data: \(error.localizedDescription)")
                        } else {
                            print("User data and profile image updated successfully")
                        }
                    }
                }
            }
        } else {
            let userData: [String: Any] = [
                "name": userName,
                "email": userEmail,
                "age": userAge,
                "bio": userBio
            ]

            db.collection("users").document(user.uid).setData(userData, merge: true) { error in
                if let error = error {
                    print("Error updating user data: \(error.localizedDescription)")
                } else {
                    print("User data updated successfully")
                }
            }
        }
    }

}

struct ProfileViewPage_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
