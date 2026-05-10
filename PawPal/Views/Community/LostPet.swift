//
//  LostPet.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/20/25.
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

    var timestampDate: Date? {
        return timestamp
    }
}
