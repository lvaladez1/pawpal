//
//  FirestoreService.swift
//  PawPal
//
//  Created by Moe Karaki on 12/7/25.
//

import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Lost Pets
    
    func fetchLostPets(completion: @escaping (Result<[LostPet], Error>) -> Void) {
        db.collection(FS.LostPets.collection)
            .order(by: FS.LostPets.timestamp, descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let pets = snapshot?.documents.compactMap { doc -> LostPet? in
                    let data = doc.data()
                    guard
                        let name = data[FS.LostPets.petName] as? String,
                        let desc = data[FS.LostPets.description] as? String,
                        let lat = data[FS.LostPets.lat] as? Double,
                        let lng = data[FS.LostPets.lng] as? Double
                    else { return nil }
                    
                    let timestamp = (data[FS.LostPets.timestamp] as? Timestamp)?.dateValue()
                    let userId = data["userId"] as? String
                    
                    return LostPet(
                        id: doc.documentID,
                        petName: name,
                        description: desc,
                        latitude: lat,
                        longitude: lng,
                        timestamp: timestamp,
                        userId: userId
                    )
                } ?? []
                
                completion(.success(pets))
            }
    }
    
    func fetchUserLostPets(userId: String, completion: @escaping (Result<[LostPet], Error>) -> Void) {
        db.collection(FS.LostPets.collection)
            .whereField("userId", isEqualTo: userId)
            .order(by: FS.LostPets.timestamp, descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let pets = snapshot?.documents.compactMap { doc -> LostPet? in
                    let data = doc.data()
                    return LostPet(
                        id: doc.documentID,
                        petName: data[FS.LostPets.petName] as? String ?? "",
                        description: data[FS.LostPets.description] as? String ?? "",
                        latitude: data[FS.LostPets.lat] as? Double ?? 0,
                        longitude: data[FS.LostPets.lng] as? Double ?? 0,
                        timestamp: (data[FS.LostPets.timestamp] as? Timestamp)?.dateValue(),
                        userId: data["userId"] as? String
                    )
                } ?? []
                
                completion(.success(pets))
            }
    }
    
    func createLostPetReport(petName: String, description: String, latitude: Double, longitude: Double, userId: String, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            FS.LostPets.petName: petName,
            FS.LostPets.description: description,
            FS.LostPets.lat: latitude,
            FS.LostPets.lng: longitude,
            FS.LostPets.timestamp: FieldValue.serverTimestamp(),
            "userId": userId
        ]
        
        db.collection(FS.LostPets.collection).addDocument(data: data) { error in
            completion(error)
        }
    }
    
    func deleteLostPetReport(petId: String, completion: @escaping (Error?) -> Void) {
        db.collection(FS.LostPets.collection)
            .document(petId)
            .delete { error in
                completion(error)
            }
    }
    
    // MARK: - User Profile
    
    func saveUserProfile(userId: String, profile: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection(FS.Users.collection)
            .document(userId)
            .setData(profile) { error in
                completion(error)
            }
    }
    
    func fetchUserProfile(userId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        db.collection(FS.Users.collection)
            .document(userId)
            .getDocument { document, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let document = document, document.exists, let data = document.data() {
                    completion(.success(data))
                } else {
                    let error = NSError(domain: "FirestoreService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found"])
                    completion(.failure(error))
                }
            }
    }
    
    func userProfileExists(userId: String, completion: @escaping (Bool, Error?) -> Void) {
        db.collection(FS.Users.collection)
            .document(userId)
            .getDocument { document, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                completion(document?.exists ?? false, nil)
            }
    }
}
