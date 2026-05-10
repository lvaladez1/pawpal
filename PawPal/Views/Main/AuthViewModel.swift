//
//  AuthViewModel.swift
//  PawPal
//
//  Created by Kevin Crapo on 11/26/25.
//  Updated to support global proximity alert monitoring.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import CoreLocation
import UserNotifications
import Combine

// Manages the user's authentication state for the entire app.
// This ViewModel ensures SwiftUI reacts to login/logout events
// and restores the Firebase session on app launch.
class AuthViewModel: ObservableObject {
    
    // The currently logged-in Firebase user. `nil` when logged out.
    @Published var user: User?
    
    // Whether the app is still checking Firebase for an existing session.
    @Published var isLoading = true
    
    // Latest device location (updated live from LocationManager).
    @Published var userLocation: CLLocation?
    
    // Lost pets streamed from Firestore (used for proximity monitoring).
    @Published private(set) var lostPets: [LostPet] = []
    
    // Firebase listener handle for auth changes (kept so we can detach if needed).
    private var authListener: AuthStateDidChangeListenerHandle?
    
    // Firestore listener for lost pet reports (global proximity feed)
    private var proximityListener: ListenerRegistration?
    
    // Subscription to location updates from LocationManager
    private var locationCancellable: AnyCancellable?
    
    // Prevent duplicate alerts for the same report
    private var notifiedPetIds: Set<String> = []
    
    // Distance threshold for firing alerts (in miles)
    private let alertRadiusMiles: Double = 5.0
    
    init() {
        observeAuthChanges()
    }
    
    
    // ----------------------------------------------------------------------
    // AUTH STATE LISTENING
    // ----------------------------------------------------------------------
    
    // Subscribes to Firebase authentication updates.
    // Called on:
    // - login
    // - logout
    // - app launch (restoring existing session)
    // - token refresh
    private func observeAuthChanges() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isLoading = false
                
                if user != nil {
                    // Start Firestore monitoring after login
                    self?.beginProximityMonitoring()
                } else {
                    // Clean up everything when logged out
                    self?.stopProximityMonitoring()
                }
            }
        }
    }
    
    
    //Signs out the user safely.
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            print("Sign-out failed:", error.localizedDescription)
        }
    }
    
    
    // ----------------------------------------------------------------------
    // LOCATION UPDATING from LocationManager
    // ----------------------------------------------------------------------
    
    // Called from PawPalApp to attach the global LocationManager stream.
    @MainActor func attachLocationUpdates(from manager: LocationManager) {
        locationCancellable = manager.$location.sink { [weak self] loc in
            self?.userLocation = loc
            
            // Once we have a location, re-check proximity for any existing pets.
            if let pets = self?.lostPets,
               let userLoc = loc {
                self?.checkProximity(pets: pets, userLocation: userLoc)
            }
        }
    }
    
    
    // ----------------------------------------------------------------------
    // GLOBAL FIRESTORE MONITORING FOR PROXIMITY ALERTS
    // ----------------------------------------------------------------------
    
    private func beginProximityMonitoring() {
        guard proximityListener == nil else { return }
        
        print("Starting global proximity listener...")
        
        proximityListener = Firestore.firestore()
            .collection(FS.LostPets.collection)
            .addSnapshotListener { [weak self] snapshot, error in
                
                if let error = error {
                    print("Firestore proximity listener error:", error.localizedDescription)
                    return
                }
                
                guard let self = self else { return }
                guard let documents = snapshot?.documents else {
                    self.lostPets = []
                    return
                }
                
                // Store the previous list so we can detect new reports
                let previousPets = self.lostPets
                let previousIds = Set(previousPets.map { $0.id })
                
                // Convert Firestore docs into model objects
                self.lostPets = documents.compactMap { doc in
                    let data = doc.data()
                    
                    guard
                        let name = data[FS.LostPets.petName] as? String,
                        let desc = data[FS.LostPets.description] as? String,
                        let lat  = data[FS.LostPets.lat] as? Double,
                        let lng  = data[FS.LostPets.lng] as? Double
                    else { return nil }
                    
                    let timestamp = (data[FS.LostPets.timestamp] as? Timestamp)?.dateValue()
                    
                    return LostPet(
                        id: doc.documentID,
                        petName: name,
                        description: desc,
                        latitude: lat,
                        longitude: lng,
                        timestamp: timestamp,
                        userId: data["userId"] as? String
                    )
                }
                
                // Identify newly added pets
                let newlyAdded = self.lostPets.filter { !previousIds.contains($0.id) }
                
                // Debug logging for new items
                for pet in newlyAdded {
                    print(" [Global Listener] New pet report added:", pet.petName)
                }
                
                // Perform proximity checks ONLY if we have a location
                if let userLoc = self.userLocation {
                    self.checkProximity(pets: newlyAdded, userLocation: userLoc)
                }
            }
    }
    
    
    private func stopProximityMonitoring() {
        print("Stopping global proximity listener.")
        
        proximityListener?.remove()
        proximityListener = nil
        lostPets = []
        notifiedPetIds = []
    }
    
    
    // ----------------------------------------------------------------------
    // PROXIMITY DETECTION + ALERTING
    // ----------------------------------------------------------------------
    
    private func checkProximity(pets: [LostPet], userLocation: CLLocation) {
        
//        print("[Global] User location updated:", userLocation.coordinate)
        
        for pet in pets {
            
            // Skip pets we've already notified about
            if notifiedPetIds.contains(pet.id) {
                continue
            }
            
            guard let timestamp = pet.timestamp else { continue }
            
            // Only consider reports within the last 3 minutes. Might be redundant
            let freshnessWindow: TimeInterval = 180
            let cutoff = Date().addingTimeInterval(-freshnessWindow)
            if timestamp < cutoff { continue }
            
            let petCoord = CLLocation(latitude: pet.latitude, longitude: pet.longitude)
            let distanceMiles = petCoord.distance(from: userLocation) / 1609.34
            
            if distanceMiles <= alertRadiusMiles {
                print("ALERT fired for:", pet.petName)
                sendProximityAlert(for: pet)
                notifiedPetIds.insert(pet.id)
            }
        }
    }
    
    
    private func sendProximityAlert(for pet: LostPet) {
        let content = UNMutableNotificationContent()
        content.title = "Nearby Lost Pet"
        content.body = "\(pet.petName) was reported within \(Int(alertRadiusMiles)) miles of your location."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    
    deinit {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
        
        proximityListener?.remove()
        locationCancellable?.cancel()
    }
}
