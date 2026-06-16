//
//  EditLostPetView.swift
//  PawPal
//
//  Created by Mariah Stinson on 6/9/26.
//

import SwiftUI
import FirebaseFirestore
import MapKit
import CoreLocation
import UIKit

struct EditLostPetView: View {
    let pet: LostPet
    let onSave: ((LostPet) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @StateObject private var locationManager = LocationManager()
    @StateObject private var completerDelegateWrapper = CompleterDelegateWrapper()
    
    @State private var petName: String
    @State private var petNotes: String
    @State private var size: String
    @State private var markings: String
    @State private var coatLength: String
    @State private var earType: String
    @State private var tailType: String
    @State private var primaryColor: String
    @State private var secondaryColor: String
    @State private var latitude: Double
    @State private var longitude: Double
    
    @State private var searchQuery = ""
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var showLocationSuggestions = false
    @State private var hasManuallySelectedLocation = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showEarTypeHelp = false
    @State private var showTailTypeHelp = false
    
    private let sizeOptions = ["Small", "Medium", "Large"]
    private let colorOptions = ["Black", "White", "Brown", "Tan", "Black & White", "Gray", "Golden", "Other"]
    private let secondaryColorOptions = ["None", "Black", "White", "Brown", "Tan", "Black & White", "Gray", "Golden", "Other"]
    private let markingOptions = ["White chest", "White paws", "Spotted", "Black mask", "Brindle", "Merle", "Other", "Unknown"]
    private let coatOptions = ["Short", "Medium", "Long"]
    private let earOptions = ["Erect", "Semi-erect", "Floppy"]
    private let tailOptions = ["Whip tail", "Furry tail", "Curled", "No tail", "Unknown"]
    
    init(pet: LostPet, onSave: ((LostPet) -> Void)? = nil) {
        self.pet = pet
        self.onSave = onSave
        _petName = State(initialValue: pet.petName)
        _petNotes = State(initialValue: pet.description)
        _size = State(initialValue: pet.size)
        _markings = State(initialValue: pet.markings)
        _coatLength = State(initialValue: pet.coatLength)
        _earType = State(initialValue: pet.earType)
        _tailType = State(initialValue: pet.tailType)
        _primaryColor = State(initialValue: pet.primaryColor ?? "")
        _secondaryColor = State(initialValue: pet.secondaryColor ?? "")
        _latitude = State(initialValue: pet.latitude)
        _longitude = State(initialValue: pet.longitude)
    }
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    editableTextField(
                        title: "Pet Name",
                        placeholder: "Pet name",
                        text: $petName
                    )
                    
                    editableDropdown(
                        title: "Size",
                        placeholder: "Select a size",
                        selection: $size,
                        options: sizeOptions
                    )
                    
                    editableDropdown(
                        title: "Primary Color",
                        placeholder: "Select a primary color",
                        selection: $primaryColor,
                        options: colorOptions
                    )
                    
                    editableDropdown(
                        title: "Secondary Color",
                        placeholder: "Select a secondary color",
                        selection: $secondaryColor,
                        options: secondaryColorOptions
                    )
                    
                    editableDropdown(
                        title: "Markings",
                        placeholder: "Select markings",
                        selection: $markings,
                        options: markingOptions
                    )
                    
                    editableDropdown(
                        title: "Coat Length",
                        placeholder: "Select coat length",
                        selection: $coatLength,
                        options: coatOptions
                    )
                    
                    editableDropdownWithHelp(
                        title: "Ear Type",
                        placeholder: "Select ear type",
                        selection: $earType,
                        options: earOptions,
                        showHelp: $showEarTypeHelp
                    )
                    .sheet(isPresented: $showEarTypeHelp) {
                        EarTypeHelpView()
                    }
                    
                    editableDropdownWithHelp(
                        title: "Tail Type",
                        placeholder: "Select tail type",
                        selection: $tailType,
                        options: tailOptions,
                        showHelp: $showTailTypeHelp
                    )
                    .sheet(isPresented: $showTailTypeHelp) {
                        TailTypeHelpView()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        TextField("Distinct markings, personality, or other helpful notes...", text: $petNotes, axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    locationSection
                    
                    Button(action: saveChanges) {
                        Text(isSaving ? "Saving..." : "Save Changes")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.theme.babyBlue)
                            .foregroundColor(.white)
                            .cornerRadius(28)
                    }
                    .disabled(isSaving)
                }
                .padding()
            }
        }
        .navigationTitle("Edit Lost Pet")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupLocationSearch()
        }
        .alert("Update Status", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage == "Lost pet report updated successfully." {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last Seen Location")
                .font(.headline)
            
            TextField("Search for a place or address...", text: $searchQuery)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .onChange(of: searchQuery) { newValue in
                    if hasManuallySelectedLocation {
                        hasManuallySelectedLocation = false
                        return
                    }
                    
                    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    showLocationSuggestions = !trimmed.isEmpty
                    searchCompleter.queryFragment = trimmed
                }
            
            if showLocationSuggestions && !completerDelegateWrapper.results.isEmpty {
                VStack(spacing: 0) {
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
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil,
                                from: nil,
                                for: nil
                            )
                            selectSearchCompletion(result.completion)
                        }
                        
                        Divider()
                    }
                }
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
            
            Button {
                useCurrentLocation()
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
            }
            
            Map(position: $cameraPosition) {
                Marker(
                    "Last Seen Location",
                    coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                )
                .tint(.red)
            }
            .frame(height: 200)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            
            Text("Latitude: \(latitude)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Longitude: \(longitude)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.85))
        .cornerRadius(18)
    }
    
    private func editableTextField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            TextField(placeholder, text: text)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
        }
    }
    
    private func editableDropdown(title: String, placeholder: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Picker(selection: selection) {
                Text(placeholder)
                    .tag("")
                
                ForEach(options, id: \.self) { option in
                    Text(option)
                        .tag(option)
                }
            } label: {
                Text(selection.wrappedValue.isEmpty ? placeholder : selection.wrappedValue)
            }
            .pickerStyle(.menu)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    private func editableDropdownWithHelp(
        title: String,
        placeholder: String,
        selection: Binding<String>,
        options: [String],
        showHelp: Binding<Bool>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Button {
                showHelp.wrappedValue = true
            } label: {
                Label("What is this?", systemImage: "questionmark.circle")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.babyBlue)
            }
            
            Picker(selection: selection) {
                Text(placeholder)
                    .tag("")
                
                ForEach(options, id: \.self) { option in
                    Text(option)
                        .tag(option)
                }
            } label: {
                Text(selection.wrappedValue.isEmpty ? placeholder : selection.wrappedValue)
            }
            .pickerStyle(.menu)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    private func setupLocationSearch() {
        searchCompleter.delegate = completerDelegateWrapper
        searchCompleter.resultTypes = .address
        
        setMapLocation(
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        )
    }
    
    private func useCurrentLocation() {
        guard let coord = locationManager.location?.coordinate else {
            alertMessage = "Unable to get your current location. Please search for a location instead."
            showAlert = true
            return
        }
        
        hasManuallySelectedLocation = true
        searchQuery = "Current Location"
        showLocationSuggestions = false
        completerDelegateWrapper.results = []
        setMapLocation(coord)
    }
    
    private func setMapLocation(_ coord: CLLocationCoordinate2D) {
        latitude = coord.latitude
        longitude = coord.longitude
        
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
    
    private func selectSearchCompletion(_ completion: MKLocalSearchCompletion) {
        hasManuallySelectedLocation = true
        showLocationSuggestions = false
        completerDelegateWrapper.results = []
        
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            DispatchQueue.main.async {
                guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                    alertMessage = "Could not find that location. Please try another search."
                    showAlert = true
                    return
                }
                
                searchQuery = completion.title
                setMapLocation(coordinate)
            }
        }
    }
    
    private func saveChanges() {
        guard pet.userId == authVM.user?.uid else {
            alertMessage = "You can only edit lost pet reports that you created."
            showAlert = true
            return
        }
        
        let petId = pet.id
        
        isSaving = true
        
        let updatedData: [String: Any] = [
            "petName": petName,
            "description": petNotes,
            "size": size,
            "primaryColor": primaryColor,
            "secondaryColor": secondaryColor,
            "markings": markings,
            "coatLength": coatLength,
            "earType": earType,
            "tailType": tailType,
            "lat": latitude,
            "lng": longitude
        ]
        
        Firestore.firestore()
            .collection(FS.LostPets.collection)
            .document(petId)
            .updateData(updatedData) { error in
                DispatchQueue.main.async {
                    isSaving = false
                    
                    if let error = error {
                        alertMessage = "Failed to update: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }
                    
                    let updatedPet = LostPet(
                        id: pet.id,
                        petName: petName,
                        size: size,
                        markings: markings,
                        coatLength: coatLength,
                        earType: earType,
                        tailType: tailType,
                        description: petNotes,
                        latitude: latitude,
                        longitude: longitude,
                        timestamp: pet.timestampDate,
                        userId: pet.userId,
                        primaryColor: primaryColor,
                        secondaryColor: secondaryColor
                    )
                    
                    onSave?(updatedPet)
                    
                    alertMessage = "Lost pet report updated successfully."
                    showAlert = true
                }
            }
    }
}
