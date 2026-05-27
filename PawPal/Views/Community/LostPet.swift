//
//  LostPet.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/20/25.
//
//  Contributors:
//  Luis Valadez last updated on 5/26/26.
//

import Foundation
import SwiftUI

enum FS {
    enum Users {
        static let collection = "users"
    }
    enum LostPets {
        static let collection = "lost_pets"
        static let petName = "petName"
        static let description = "description"
        static let lat = "lat"
        static let lng = "lng"
        static let timestamp = "timestamp"
        
        // Pet identifier fields used for preview tags
        static let petGender = "petGender"
        static let primaryColor = "primaryColor"
        static let secondaryColor = "secondaryColor"
        static let hasMicrochip = "hasMicrochip"
        static let userId = "userId"
    }
}

struct LostPet: Identifiable, Codable {
    var id: String
    var petName: String
    var description: String
    var latitude: Double
    var longitude: Double
    var timestamp: Date? = nil
    var userId: String? = nil
    
    // Optional fields shown as tags in LostPetRow
    var petGender: String? = nil
    var breed: String? = nil
    var primaryColor: String? = nil
    var secondaryColor: String? = nil
    var hasMicrochip: String? = nil

    var timestampDate: Date? {
        return timestamp
    }
}
