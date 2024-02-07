//
//  StructCity.swift
//  ProjetIOS
//
//  Created by Justin SOTTILE & Gauthier MIGUET on 07/02/2024.
//

import Foundation
import SwiftUI

struct City: Identifiable,Decodable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let elevation: Double
    let countryCode: String?
    let featureCode: String?
    let admin1Id: Int?
    let admin3Id: Int?
    let admin4Id: Int?
    let timezone: String
    let population: Int
    let postcodes: [String]
    let countryId: Int?
    let country: String
    let admin1: String?
    let admin3: String?
    let admin4: String?

    private enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, elevation, countryCode,featureCode, admin1Id, admin3Id, admin4Id, timezone, population, postcodes, countryId, country, admin1, admin3, admin4
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        featureCode = try container.decodeIfPresent(String.self, forKey: .featureCode)
        elevation = try container.decode(Double.self, forKey: .elevation)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        admin1Id = try container.decodeIfPresent(Int.self, forKey: .admin1Id)
        admin3Id = try container.decodeIfPresent(Int.self, forKey: .admin3Id)
        admin4Id = try container.decodeIfPresent(Int.self, forKey: .admin4Id)
        timezone = try container.decode(String.self, forKey: .timezone)
        population = try container.decode(Int.self, forKey: .population)
        postcodes = try container.decode([String].self, forKey: .postcodes)
        countryId = try container.decodeIfPresent(Int.self, forKey: .countryId)
        country = try container.decode(String.self, forKey: .country)
        admin1 = try container.decodeIfPresent(String.self, forKey: .admin1)
        admin3 = try container.decodeIfPresent(String.self, forKey: .admin3)
        admin4 = try container.decodeIfPresent(String.self, forKey: .admin4)
    }
}

