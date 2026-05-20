//
//  AddSightingView.swift
//  PawPal
//
//  Created by Luis V on 5/19/26.
//

import SwiftUI
import FirebaseFirestore
import CoreLocation

struct AddSightingView: View {
    let pet: LostPet

    @Environment(\.dismiss) private var dismiss

    @State private var locationNotes = ""
    @State private var petCondition = "Unknown"
    @State private var directionTraveled = "Unknown"
    @State private var behavior = "Unknown"
    @State private var collarSeen = "Unknown"
    @State private var contactInfo = ""
    @State private var isSubmitting = false
    @StateObject private var locationManager = LocationManager()

    let conditionOptions = ["Unknown", "Healthy", "Injured", "Limping", "Dirty/Wet", "Very thin"]
    let directionOptions = ["Unknown", "North", "South", "East", "West", "Stayed nearby"]
    let behaviorOptions = ["Unknown", "Running", "Hiding", "Friendly", "Scared", "Aggressive"]
    let collarOptions = ["Unknown", "Yes", "No"]

    var body: some View {
        ZStack {
            Color.theme.babyBlueLight
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text("Sighting Details")
                        .font(.title2)
                        .fontWeight(.bold)

                    // Location Section
                    VStack(alignment: .leading, spacing: 14) {

                        Text("Location")
                            .font(.headline)

                        TextField("Enter location notes or address", text: $locationNotes)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(
                                color: Color.black.opacity(0.05),
                                radius: 2,
                                x: 0,
                                y: 1
                            )

                        Button {
                            locationManager.requestLocationPermission()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                if !locationManager.addressString.isEmpty {
                                    locationNotes = locationManager.addressString
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")

                                Text("Use My Current Location")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(Color.theme.babyBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            // .frame(maxWidth: .infinity)
                            //.padding()
                            //.background(Color.theme.babyBlue.opacity(0.15))
                            //.cornerRadius(12)
                        }
                    }

                    // Pickers Section
                    VStack(alignment: .leading, spacing: 20) {

                        sightingPicker(
                            title: "Pet Condition",
                            selection: $petCondition,
                            options: conditionOptions
                        )

                        sightingPicker(
                            title: "Direction Traveling",
                            selection: $directionTraveled,
                            options: directionOptions
                        )

                        sightingPicker(
                            title: "Pet's Behavior",
                            selection: $behavior,
                            options: behaviorOptions
                        )

                        sightingPicker(
                            title: "Collar/Harness Seen?",
                            selection: $collarSeen,
                            options: collarOptions
                        )
                    }

                    // Contact Info
                    VStack(alignment: .leading, spacing: 8) {

                        Text("Contact Info")
                            .font(.headline)

                        TextField("Your contact info", text: $contactInfo)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(
                                color: Color.black.opacity(0.05),
                                radius: 2,
                                x: 0,
                                y: 1
                            )
                    }

                    // Submit Button
                    Button {
                        submitSighting()
                    } label: {
                        Text(isSubmitting ? "Submitting..." : "Submit Sighting")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.theme.babyBlue)
                            .cornerRadius(28)
                            .shadow(
                                color: Color.theme.babyBlue.opacity(0.4),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    .disabled(isSubmitting || locationNotes.isEmpty)
                    .opacity(isSubmitting || locationNotes.isEmpty ? 0.6 : 1.0)
                }
                .padding(20)
            }
        }
        
        .navigationTitle("Report Sighting")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sightingPicker(
        title: String,
        selection: Binding<String>,
        options: [String]
    ) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Picker(selection: selection) {

                ForEach(options, id: \.self) { option in
                    Text(option)
                        .tag(option)
                }

            } label: {
                Text(selection.wrappedValue)
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 2,
                x: 0,
                y: 1
            )
        }
    }

    private func submitSighting() {

        isSubmitting = true

        let sightingData: [String: Any] = [
            "lostPetId": pet.id,
            "lostPetName": pet.petName,
            "locationNotes": locationNotes,
            "petCondition": petCondition,
            "directionTraveled": directionTraveled,
            "behavior": behavior,
            "collarSeen": collarSeen,
            "contactInfo": contactInfo,
            "lostPetLatitude": pet.latitude,
            "lostPetLongitude": pet.longitude,
            "latitude": locationManager.location?.coordinate.latitude ?? 0,
            "longitude": locationManager.location?.coordinate.longitude ?? 0,
            "createdAt": Timestamp(date: Date())
        ]

        Firestore.firestore()
            .collection("sightings")
            .addDocument(data: sightingData) { error in

                isSubmitting = false

                if let error = error {
                    print("Error saving sighting: \(error.localizedDescription)")
                    return
                }

                dismiss()
            }
    }
}
