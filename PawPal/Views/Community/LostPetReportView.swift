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
    @State private var primaryBreed: String = ""
    @State private var breeds: [String] = []
    @State private var secondaryBreed = ""
    @State private var secondaryBreeds: [String] = []
    @State private var isWearingCollar: String = ""
    @State private var petDescription = ""
    @State private var petPrimaryColor = ""
    @State private var petSecondaryColor = ""
    let petPrimaryColorDropDown: [String] = ["black", "white", "brown"]
    let petSecondaryColorDropDown: [String] = ["none", "black", "white", "brown"]
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
                        
                        // Primary Breed Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Breed")
                                .font(.headline)

                            Picker(
                                selection: $primaryBreed,
                                label: Text(primaryBreed.isEmpty ? "Select a breed" : primaryBreed.capitalized)
                            ) {
                                Text("Select a breed").tag("")

                                ForEach(breeds, id: \.self) { breed in
                                    Text(breed.capitalized)
                                        .tag(breed)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(primaryBreed.isEmpty ? .gray : .primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2)
                        }
                        
                        // Secondary Breed Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Secondary Breed (optional mix)")
                                .font(.headline)

                            Picker(
                                selection: $secondaryBreed,
                                label: Text(secondaryBreed.isEmpty ? "No mix" : secondaryBreed.capitalized)
                            ) {
                                Text("No mix").tag("")

                                ForEach(breeds, id: \.self) { breed in
                                    Text(breed.capitalized)
                                        .tag(breed)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(primaryBreed.isEmpty ? .gray : .primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2)
                        }
                        
                        // Pet Primary Color Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Primary Color")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker(selection: $petPrimaryColor) {
                                Text("Select a color")
                                    .tag("")

                                    ForEach(petPrimaryColorDropDown, id: \.self) { color in
                                    Text(color.capitalized)
                                        .tag(color)
                                    }
                            }   label: {
                                    Text(petPrimaryColor.isEmpty ? "Select a color" : petPrimaryColor.capitalized)
                                }
                                .pickerStyle(.menu)
                                .tint(petPrimaryColor.isEmpty ? .gray : .primary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        // Pet Secondary Color Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Secondary Color")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker(selection: $petSecondaryColor) {
                                Text("Select a color")
                                    .tag("")

                                    ForEach(petSecondaryColorDropDown, id: \.self) { color in
                                    Text(color.capitalized)
                                        .tag(color)
                                    }
                            }   label: {
                                    Text(petSecondaryColor.isEmpty ? "Select a color" : petSecondaryColor.capitalized)
                                }
                                .pickerStyle(.menu)
                                .tint(petSecondaryColor.isEmpty ? .gray : .primary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        //Has Collar Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Is the pet wearing a collar?")
                                .font(.headline)

                            Picker(
                                selection: $isWearingCollar,
                                label: Text(isWearingCollar.isEmpty ? "Select Yes or No" : isWearingCollar)
                            ) {
                                Text("Select Yes or No").tag("")

                                Text("Yes").tag("Yes")
                                Text("No").tag("No")
                            }
                            .pickerStyle(.menu)
                            .tint(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2)
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
            .onAppear {
                fetchBreeds()
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
            "primaryColor": petPrimaryColor,
            "secondaryColor": petSecondaryColor,
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
                    petPrimaryColor = ""
                    petSecondaryColor = ""
                    petDescription = ""
                    hasManuallySelectedLocation = false
                }
            }
        }
    }
    
    func fetchBreeds() {
        guard let url = URL(string: "https://dog.ceo/api/breeds/list/all") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Network error:", error)
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(BreedsResponse.self, from: data)

                var list: [String] = []

                for (breed, subBreeds) in decoded.message {
                    if subBreeds.isEmpty {
                        list.append(breed)
                    } else {
                        for sub in subBreeds {
                            list.append("\(sub) \(breed)")
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.breeds = list.sorted()
                    print("Loaded breeds:", self.breeds.count)
                }

            } catch {
                print("Decode error:", error)
            }
        }.resume()
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
