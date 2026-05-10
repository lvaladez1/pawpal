//
//  EnterProfileView.swift
//  PawPal
//
//  Created by Hieu Hoang on 12/15/24.
//  Modified by Moe Karaki on 7/15/25.
//

/*
 * Note, the enterProfileView for a pet with an image as this does could be used if plan is upgraded on firebase.
 * Will be kept for possible further use. 
 */

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct EnterProfileView: View {
    @State private var petImage: UIImage?
    @State private var showImagePicker = false

    @State private var petName = ""
    @State private var petType = ""
    @State private var petAge = ""
    @State private var petCharacteristics = ""
    @State private var petDescription = ""

    @State private var errorMessage: String?
    @State private var navigateToMainApp = false
    @State private var showContent = false
    @State private var isUploading = false

    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    
                    // Header with icon
                    VStack(spacing: 12) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color.theme.babyBlue)
                            .scaleEffect(showContent ? 1.0 : 0.8)
                            .opacity(showContent ? 1.0 : 0.0)
                        
                        Text("Create Pet Profile")
                            .font(.title2)
                            .fontWeight(.bold)
                            .opacity(showContent ? 1.0 : 0.0)
                        
                        Text("Tell us about your furry companion")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1.0 : 0.0)
                    }
                    .padding(.top, 20)
                    
                    // Image Picker Card
                    VStack(spacing: 16) {
                        Button(action: { showImagePicker = true }) {
                            ZStack {
                                if let image = petImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 140, height: 140)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.theme.babyBlue, Color.theme.babyBlue.opacity(0.6)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 4
                                                )
                                        )
                                        .shadow(color: Color.theme.babyBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 140, height: 140)
                                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                        
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.circle.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(Color.theme.babyBlue)
                                            Text("Add Photo")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Text(petImage == nil ? "Tap to add a photo" : "Tap to change photo")
                            .font(.caption)
                            .foregroundColor(Color.theme.babyBlue)
                    }
                    .opacity(showContent ? 1.0 : 0.0)

                    // Form Fields
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pet Name")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            TextField("e.g., Buddy", text: $petName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Type")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                                
                                TextField("Dog, Cat...", text: $petType)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Age")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                                
                                TextField("e.g., 3 years", text: $petAge)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Characteristics")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            TextField("Friendly, energetic, playful...", text: $petCharacteristics)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            ZStack(alignment: .topLeading) {
                                if petDescription.isEmpty {
                                    Text("Tell us more about your pet...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                }
                                TextEditor(text: $petDescription)
                                    .frame(height: 120)
                                    .padding(8)
                                    .scrollContentBackground(.hidden)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1.0 : 0.0)

                    if let error = errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }

                    Button(action: validateAndUpload) {
                        HStack {
                            if isUploading {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 8)
                            }
                            Text(isUploading ? "Saving..." : "Save Profile")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.theme.babyBlue, Color.theme.babyBlue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.theme.babyBlue.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isUploading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                    .opacity(showContent ? 1.0 : 0.0)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $petImage)
        }
        .navigationTitle("Pet Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToMainApp) {
            MainTabView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }

    private func validateAndUpload() {
        guard !petName.isEmpty, !petType.isEmpty, !petAge.isEmpty,
              !petCharacteristics.isEmpty, !petDescription.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        errorMessage = nil
        isUploading = true

        if let image = petImage {
            uploadImage(image) { imageURL in
                saveProfile(imageURL: imageURL)
            }
        } else {
            saveProfile(imageURL: nil)
        }
    }

    private func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            completion(nil)
            return
        }

        let imageRef = Storage.storage().reference().child("users/\(uid)/pet_image.jpg")
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Could not compress image"
            completion(nil)
            return
        }

        imageRef.putData(data, metadata: nil) { _, error in
            if let error = error {
                errorMessage = "Image upload failed: \(error.localizedDescription)"
                completion(nil)
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    errorMessage = "Failed to get image URL: \(error.localizedDescription)"
                    completion(nil)
                    return
                }

                completion(url?.absoluteString)
            }
        }
    }

    private func saveProfile(imageURL: String?) {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }

        var profile: [String: Any] = [
            "name": petName,
            "type": petType,
            "age": petAge,
            "characteristics": petCharacteristics.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "description": petDescription
        ]

        if let imageURL = imageURL {
            profile["imageURL"] = imageURL
        }

        Firestore.firestore().collection("users").document(uid).setData(profile) { error in
            if let error = error {
                errorMessage = "Failed to save profile: \(error.localizedDescription)"
                return
            }

            navigateToMainApp = true
        }
    }
}
