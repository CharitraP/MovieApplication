//
//  UserProfileEditView.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 4/20/24.
//
import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct UserProfileEditView: View {
    @Binding var email: String
    @Binding var password: String
    @State private var name = ""
    @State private var age = ""
    @State private var bio = ""
    @State var profileImage: UIImage?
    @State private var isUploading = false
    @State private var isPickerShowing = false

    @Environment(\.presentationMode) var presentationMode
    @State private var imagePickerDelegate: ImagePickerDelegate?

    var body: some View {
        ScrollView{
            VStack {
                // Profile image
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }
                
                Button(action: {
                    isPickerShowing = true
                }) {
                    Text("Select Profile Image")
                }
                .sheet(isPresented: $isPickerShowing) {
                    ImagePickerDelegate(selectedImage: $profileImage, isPickerShowing: $isPickerShowing)
                }
                
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disabled(true)
                
                TextField("Age", text: $age)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Bio", text: $bio)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: saveUserProfile) {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(5.0)
                }
                
                if isUploading {
                    ProgressView()
                }
            }
            .padding()
        }
        .background(Color(#colorLiteral(red: 0.05, green: 0.2, blue: 0.3, alpha: 2)))
    }

    func saveUserProfile() {
        isUploading = true

        guard let user = Auth.auth().currentUser else {
            isUploading = false
            return
        }

        let db = Firestore.firestore()
        let storage = Storage.storage().reference()

        if let profileImage = profileImage {
            let imageData = profileImage.jpegData(compressionQuality: 0.8)
            let imageRef = storage.child("profile_images/\(user.uid).jpg")

            imageRef.putData(imageData!, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading profile image: \(error.localizedDescription)")
                    self.isUploading = false
                    return
                }

                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting profile image URL: \(error.localizedDescription)")
                        self.isUploading = false
                        return
                    }

                    guard let imageURL = url?.absoluteString else {
                        self.isUploading = false
                        return
                    }

                    let userData: [String: Any] = [
                        "name": name,
                        "email": email,
                        "age": age,
                        "bio": bio,
                        "profileImageURL": imageURL,
                        "movieIds": [Int:Int]()
                    ]

                    db.collection("users").document(user.uid).setData(userData) { error in
                        if let error = error {
                            print("Error saving user data: \(error.localizedDescription)")
                            self.isUploading = false
                            return
                        }

                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        } else {
            let userData: [String: Any] = [
                "name": name,
                "email":email,
                "age": age,
                "bio": bio,
                "profileImageURL":""
            ]

            db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                    isUploading = false
                    return
                }

                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
