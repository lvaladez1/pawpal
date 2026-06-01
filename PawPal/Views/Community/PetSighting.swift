//
//  PetSighting.swift
//  PawPal
//
//  Created by Luis V on 5/26/26.
//

import Foundation

struct PossiblePetSighting: Identifiable {

    let id: String
    let lostPetId: String

    let locationNotes: String

    let latitude: Double
    let longitude: Double

    let directionTraveled: String
    let behavior: String
    let petCondition: String

    let gender: String
    let tailShape: String
    let earsPosition: String
    let collarSeen: String

    let contactInfo: String

    let createdAt: Date?

    let matchScore: Int?
    let matchLevel: String?
    let distanceMiles: Double?
}
