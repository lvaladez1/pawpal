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
        static let size = "size"
        static let markings = "markings"
        static let coatLength = "coatLength"
        static let earType = "earType"
        static let tailType = "tailType"
        static let description = "description"
        static let lat = "lat"
        static let lng = "lng"
        static let timestamp = "timestamp"
        
        // Pet identifier fields used for preview tags
        static let primaryColor = "primaryColor"
        static let secondaryColor = "secondaryColor"
        static let userId = "userId"
    }
}

struct LostPet: Identifiable, Codable {
    var id: String
    var petName: String
    var size: String
    var markings: String
    var coatLength: String
    var earType: String
    var tailType: String
    var description: String
    var latitude: Double
    var longitude: Double
    var timestamp: Date? = nil
    var userId: String? = nil
    
    // Optional fields shown as tags in LostPetRow
    var primaryColor: String? = nil
    var secondaryColor: String? = nil

    var timestampDate: Date? {
        return timestamp
    }
}
