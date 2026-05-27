//
//  AddSightingView.swift
//  PawPal
//
//  Allows a user to report a possible sighting for a lost pet.
//  The sighting includes location, travel direction, behavior,
//  condition, visual identifiers, and optional contact information.
//
//  The submitted report is saved to Firestore and includes a
//  match score compared to the pet's original lost pet report.
//
//
//  Created by Luis V on 5/19/26.
//

import SwiftUI
import FirebaseFirestore
import CoreLocation
import MapKit

struct AddSightingView: View {
    // Lost pet this sighting is being reported for.
    // Used to associate the sighting with the pet and calculate match distance.
    let pet: LostPet
    
    @Environment(\.dismiss) private var dismiss
    
    // Handles user's current GPS location.
    @StateObject private var locationManager = LocationManager()
    @StateObject private var completerDelegateWrapper = CompleterDelegateWrapper()
    
    @State private var searchQuery = ""
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var showLocationSuggestions = false
    @State private var hasManuallySelectedLocation = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    
    @State private var petCondition = "Unknown"
    @State private var directionTraveled = "Unknown"
    @State private var petGender = "Unknown"
    @State private var behavior = "Unknown"
    @State private var tailShape = "Unknown"
    @State private var earsPosition = "Unknown"
    @State private var collarSeen = "Unknown"
    @State private var contactInfo = ""
    @State private var isSubmitting = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let conditionOptions = ["Unknown", "Healthy", "Injured", "Limping", "Dirty/Wet", "Very thin"]
    let directionOptions = ["Unknown", "North", "South", "East", "West", "Stayed nearby"]
    let genderOptions = ["Unknown", "Male", "Female"]
    let behaviorOptions = ["Unknown", "Running", "Hiding", "Friendly", "Scared", "Aggressive"]
    let tailShapeOptions = ["Unknown", "Straight", "Upright", "Curled", "Curled over back", "Busy / Fluffy", "Short / Bobtail", "Tucked", "Down / Hanging"]
    let earsPositionOptions = ["Unknown", "Upright / Pointed", "Semi-erect", "Floppy", "Folded", "Pulled back", "Flattened", "Cropped"]
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
                        
                        TextField("Search for a place...", text: $searchQuery)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .onChange(of: searchQuery) { newValue in
                                if hasManuallySelectedLocation {
                                    hasManuallySelectedLocation = false
                                    return
                                }
                                
                                selectedCoordinate = nil
                                
                                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                showLocationSuggestions = !trimmed.isEmpty
                                searchCompleter.queryFragment = trimmed
                            }
                            .onAppear {
                                searchCompleter.delegate = completerDelegateWrapper
                                searchCompleter.resultTypes = .address
                            }
                        
                        if showLocationSuggestions && !completerDelegateWrapper.results.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(completerDelegateWrapper.results) { result in
                                    VStack(alignment: .leading) {
                                        Text(result.title)
                                        Text(result.subtitle)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .onTapGesture {
                                        UIApplication.shared.endEditing()
                                        selectSearchCompletion(result.completion)
                                    }
                                    
                                    if result.id != completerDelegateWrapper.results.last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .cornerRadius(12)
                        }
                        
                        Button {
                            if let coord = locationManager.location?.coordinate {
                                selectedCoordinate = coord
                                hasManuallySelectedLocation = true
                                searchQuery = "Current Location"
                                showLocationSuggestions = false
                                completerDelegateWrapper.results = []
                                UIApplication.shared.endEditing()
                            } else {
                                alertMessage = "Unable to get your current location. Please check location permissions or search for a location."
                                showAlert = true
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
                            title: "Pet Condition",
                            selection: $petCondition,
                            options: conditionOptions
                        )
                        
                        sightingPicker(
                            title: "Gender",
                            selection: $petGender,
                            options: genderOptions,
                        )
                        
                        sightingPicker(
                            title: "Tail Shape",
                            selection: $tailShape,
                            options: tailShapeOptions
                        )
                        
                        sightingPicker(
                            title: "Ears position",
                            selection: $earsPosition,
                            options: earsPositionOptions
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
                    .disabled(isSubmitting || selectedCoordinate == nil)
                    .opacity(isSubmitting || selectedCoordinate == nil ? 0.6 : 1.0)
                }
                .padding(20)
            }
        }
        .navigationTitle("Report Sighting")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Sighting Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Reusable menu picker used for all sighting attributes.
    // This keeps the form visually consistent and avoids duplicate picker styling.
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
        
        guard let coordinate = selectedCoordinate else {
            alertMessage = "Please select a valid location from the suggestions or use your current location."
            showAlert = true
            return
        }
        
        isSubmitting = true
        
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let distance = calculateDistanceMiles(
            fromLat: pet.latitude,
            fromLng: pet.longitude,
            toLat: latitude,
            toLng: longitude
        )
        
        let score = matchScore(distanceMiles: distance)
        
        let sightingData: [String: Any] = [
            "lostPetId": pet.id,
            "locationNotes": searchQuery,
            "latitude": latitude,
            "longitude": longitude,
            "directionTraveled": directionTraveled,
            "behavior": behavior,
            "petCondition": petCondition,
            "petGender": petGender,
            "tailShape": tailShape,
            "earsPosition": earsPosition,
            "collarSeen": collarSeen,
            "contactInfo": contactInfo,
            "createdAt": Timestamp(date: Date()),
            "matchStatus": "scored",
            "match": [
                "distanceMiles": distance,
                "score": score,
                "level": matchLevel(score: score)
            ]
        ]
        
        Firestore.firestore()
            .collection("sightings")
            .addDocument(data: sightingData) { error in
                
                DispatchQueue.main.async {
                    isSubmitting = false
                    
                    if let error = error {
                        alertMessage = "Error saving sighting: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }
                    
                    dismiss()
                }
            }
    }
    
    private func selectSearchCompletion(_ completion: MKLocalSearchCompletion) {
        hasManuallySelectedLocation = true
        showLocationSuggestions = false
        completerDelegateWrapper.results = []
        UIApplication.shared.endEditing()
        
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            DispatchQueue.main.async {
                if let coordinate = response?.mapItems.first?.placemark.coordinate {
                    selectedCoordinate = coordinate
                    searchQuery = completion.title
                } else {
                    alertMessage = "Could not resolve selected location. Please choose another suggestion."
                    showAlert = true
                }
            }
        }
    }
    
    // Calculates distance between the original lost-pet location and the sighting.
    private func calculateDistanceMiles(
        fromLat: Double,
        fromLng: Double,
        toLat: Double,
        toLng: Double
    ) -> Double {
        let from = CLLocation(latitude: fromLat, longitude: fromLng)
        let to = CLLocation(latitude: toLat, longitude: toLng)
        return from.distance(from: to) / 1609.34
    }
    
    // Basic distance-based confidence score.
    // Future versions could include photo matching.
    private func matchScore(distanceMiles: Double) -> Int {
        switch distanceMiles {
        case 0...0.5:
            return 100
        case 0.5...1:
            return 85
        case 1...3:
            return 65
        case 3...5:
            return 45
        default:
            return 20
        }
    }
    
    // Converts numberic score into a human-readable category confidence level.
    private func matchLevel(score: Int) -> String {
        if score >= 80 {
            return "strong"
        } else if score >= 50 {
            return "possible"
        } else {
            return "weak"
        }
    }
}
