//
//  BreedResponse.swift
//  PawPal
//
//  Created by Claudia Fierro on 5/26/26.
//

struct BreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
}
