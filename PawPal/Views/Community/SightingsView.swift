//
//  SightingsView.swift
//  PawPal
//
//  Created by Luis V on 5/26/26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

struct SightingsView: View {
    
    @State private var sightings: [PetSighting] = []
    @State private var isLoading = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading sightings...")
                    .tint(Color.theme.babyBlue)
            } else if sightings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "binoculars.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color.theme.babyBlue)
                    
                    Text("No Sightings Yet")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Sightings reported for your lost pets will appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sightings) { sighting in
                            SightingRow(sighting: sighting)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    fetchSightingsForCurrentUserPets()
                }
            }
        }
        .navigationTitle("Pet Sightings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchSightingsForCurrentUserPets()
        }
        .alert("Oops", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func fetchSightingsForCurrentUserPets() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            alertMessage = "You must be signed in to view sightings."
            showAlert = true
            return
        }
        
        isLoading = true
        
        Firestore.firestore()
            .collection(FS.LostPets.collection)
            .whereField(FS.LostPets.userId, isEqualTo: currentUserId)
            .getDocuments { petSnapshot, error in
                
                if let error = error {
                    finishWithError(error.localizedDescription)
                    return
                }
                
                let petIds = petSnapshot?.documents.map { $0.documentID } ?? []
                
                guard !petIds.isEmpty else {
                    DispatchQueue.main.async {
                        self.sightings = []
                        self.isLoading = false
                    }
                    return
                }
                
                fetchSightings(for: petIds)
            }
    }
    
    private func fetchSightings(for petIds: [String]) {
        Firestore.firestore()
            .collection("sightings")
            .whereField("lostPetId", in: petIds)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    finishWithError(error.localizedDescription)
                    return
                }
                
                let fetchedSightings = snapshot?.documents.compactMap { doc -> PetSighting? in
                    let data = doc.data()
                    
                    guard
                        let lostPetId = data["lostPetId"] as? String,
                        let latitude = data["latitude"] as? Double,
                        let longitude = data["longitude"] as? Double
                    else {
                        return nil
                    }
                    
                    let match = data["match"] as? [String: Any]
                    
                    return PetSighting(
                        id: doc.documentID,
                        lostPetId: lostPetId,
                        locationNotes: data["locationNotes"] as? String ?? "",
                        latitude: latitude,
                        longitude: longitude,
                        directionTraveled: data["directionTraveled"] as? String ?? "Unknown",
                        behavior: data["behavior"] as? String ?? "Unknown",
                        petCondition: data["petCondition"] as? String ?? "Unknown",
                        gender: data["gender"] as? String ?? "Unknown",
                        tailShape: data["tailShape"] as? String ?? "Unknown",
                        earsPosition: data["earsPosition"] as? String ?? "Unknown",
                        collarSeen: data["collarSeen"] as? String ?? "Unknown",
                        contactInfo: data["contactInfo"] as? String ?? "",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                        matchScore: match?["score"] as? Int,
                        matchLevel: match?["level"] as? String,
                        distanceMiles: match?["distanceMiles"] as? Double
                    )
                } ?? []
                
                let sortedSightings = fetchedSightings.sorted {
                    ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
                }
                
                DispatchQueue.main.async {
                    self.sightings = sortedSightings
                    self.isLoading = false
                }
            }
    }
    
    private func finishWithError(_ message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
            self.isLoading = false
        }
    }
}
