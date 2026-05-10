//
//  LostPetReportView.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/05/25.
//

import SwiftUI
import MapKit
import Firebase
import CoreLocation
import FirebaseFirestore
import UIKit

enum Validators {
    static func isValidPetName(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.count >= 2 && t.count <= 40
    }
    static func isValidDescription(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.count >= 10 && t.count <= 500
    }
    static func isValidCoordinate(lat: Double, lon: Double) -> Bool {
        (-90.0...90.0).contains(lat) && (-180.0...180.0).contains(lon)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LostPetReportView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var completerDelegateWrapper = CompleterDelegateWrapper()
    @EnvironmentObject var authVM: AuthViewModel
    @State private var petName = ""
    @State private var petDescription = ""
    @State private var pinCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var searchQuery = ""
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var hasManuallySelectedLocation = false

    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isSubmitting: Bool = false

    var body: some View {
        ZStack {
            // Background Color
            Color.theme.babyBlueLight // Very light baby blue background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 8) {
                        Image(systemName: "square.and.pencil.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.theme.babyBlue)
                            .padding(.bottom, 4)
                        
                        Text("Help Find a Lost Pet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Fill out the details below to alert the community.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)

                    // Form Section
                    VStack(spacing: 20) {
                        // Pet Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pet Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("e.g. Bella", text: $petName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }

                        // Description Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Breed, color, collar, distinct marks...", text: $petDescription, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        // Location Search
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Seen Location")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Search for a place...", text: $searchQuery)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                .onChange(of: searchQuery) { newValue in
                                    print("🔤 User typed: \(newValue)")
                                    searchCompleter.queryFragment = newValue
                                }
                                .onAppear {
                                    print("🧩 Setting completer delegate")
                                    searchCompleter.delegate = completerDelegateWrapper
                                    searchCompleter.resultTypes = .address
                                }
                        }

                        if !completerDelegateWrapper.results.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(completerDelegateWrapper.results) { result in
                                    VStack(alignment: .leading) {
                                        Text(result.title)
                                            .font(.body)
                                            .foregroundColor(.primary)
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
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }

                        // Map View
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.red)
                                Text("Tap map to adjust pin")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Map(position: $cameraPosition) {
                                Marker(petName.isEmpty ? "Last Seen" : petName, coordinate: pinCoordinate)
                            }
                            .frame(height: 200)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .onTapGesture { location in
                                // Note: SwiftUI Map doesn't support tap-to-place directly
                                // Users must use the search field to set location
                            }
                            .onAppear {
                                if let userLocation = locationManager.location {
                                    setCameraAndPin(to: userLocation.coordinate)
                                }
                            }
                            .onReceive(locationManager.$location) { _ in
                                if !hasManuallySelectedLocation, let coord = locationManager.location?.coordinate {
                                    setCameraAndPin(to: coord)
                                }
                            }
                            
                            Text("Note: Use the search field above to set the exact location")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .italic()
                                .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)

                    // Submit Button
                    Button(action: submitLostPetReport) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 5)
                            }
                            Text(isSubmitting ? "Submitting..." : "Submit Report")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.theme.babyBlue)
                        .foregroundColor(.white)
                        .cornerRadius(28)
                        .shadow(color: Color.theme.babyBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isSubmitting)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Report Lost Pet")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Report Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func submitLostPetReport() {
        let lat = pinCoordinate.latitude
        let lon = pinCoordinate.longitude

        guard Validators.isValidPetName(petName) else {
            alertMessage = "Please enter a valid pet name (2–40 characters)."
            showAlert = true; return
        }
        guard Validators.isValidDescription(petDescription) else {
            alertMessage = "Please enter a valid description (10–500 characters)."
            showAlert = true; return
        }
        guard Validators.isValidCoordinate(lat: lat, lon: lon) else {
            alertMessage = "Please select a valid location on the map."
            showAlert = true; return
        }

        isSubmitting = true
        
        let data: [String: Any] = [
            FS.LostPets.petName: petName,
            FS.LostPets.description: petDescription,
            FS.LostPets.lat: pinCoordinate.latitude,
            FS.LostPets.lng: pinCoordinate.longitude,
            FS.LostPets.timestamp: FieldValue.serverTimestamp(),
            
            // Attempt to connect reports with user ID, Also accounts for old reports not having userId attac
            "userId": authVM.user?.uid ?? ""
        ]

        Firestore.firestore().collection(FS.LostPets.collection).addDocument(data: data) { error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    alertMessage = "Failed to submit: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    alertMessage = "Lost pet report submitted successfully."
                    showAlert = true
                    petName = ""
                    petDescription = ""
                    hasManuallySelectedLocation = false
                }
            }
        }
    }

    private func setCameraAndPin(to coord: CLLocationCoordinate2D) {
        pinCoordinate = coord
        cameraPosition = .region(
            MKCoordinateRegion(center: coord,
                               span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        )
    }
    private func selectSearchCompletion(_ completion: MKLocalSearchCompletion) {
        hasManuallySelectedLocation = true

        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        search.start { response, error in
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                setCameraAndPin(to: coordinate)
                searchQuery = completion.title

                // Delay hiding suggestions to fix render glitch
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    completerDelegateWrapper.results = []
                }
            } else {
                print("❌ Could not resolve selected location")
            }
        }
    }
}

#Preview {
    LostPetReportView()
}
