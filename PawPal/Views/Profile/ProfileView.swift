//
//  ProfileViewController.swift
//  PawPal
//
//  Created by Hieu Hoang on 12/15/24.
//  Modified by Moe Karaki on 7/18/25.
//  Modified by Juan Zavala on 8/03/25

/*
 * Note, the profile View with an image as this does could be used if plan is upgraded on firebase
 */

import SwiftUI

struct PetProfile {
    var image: UIImage?
    var name: String
    var type: String
    var age: String
    var characteristics: [String]
    var description: String
}

struct ProfileView: View {
    let petProfile: PetProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let image = petProfile.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill() // Ensure image fills the circle
                        .clipShape(Circle())
                        .frame(width: 150, height: 150)
                        .overlay(Circle().stroke(Color(red: 0.53, green: 0.81, blue: 0.92), lineWidth: 4)) // Baby blue border
                        .shadow(radius: 5)
                } else {
                    // Fallback if no image
                    Circle()
                        .fill(Color.white)
                        .frame(width: 150, height: 150)
                        .overlay(Circle().stroke(Color(red: 0.53, green: 0.81, blue: 0.92), lineWidth: 4))
                        .shadow(radius: 5)
                        .overlay(
                            Image(systemName: "pawprint.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.92).opacity(0.5))
                        )
                }

                Text(petProfile.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Type: \(petProfile.type)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Age: \(petProfile.age)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Characteristics
                if !petProfile.characteristics.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Characteristics")
                            .font(.headline)
                            .foregroundColor(.primary)

                        FlowLayout(alignment: .leading, spacing: 8) {
                            ForEach(petProfile.characteristics, id: \.self) { trait in
                                Text(trait)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(red: 0.53, green: 0.81, blue: 0.92).opacity(0.15)) // Light baby blue bg
                                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.8)) // Darker blue text
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.top, 8)
                }

                if !petProfile.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(petProfile.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
        }
        .background(Color(red: 0.95, green: 0.98, blue: 1.0).ignoresSafeArea()) // Baby blue background
        .navigationTitle("Pet Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}


