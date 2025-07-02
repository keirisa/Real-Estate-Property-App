
//  ZillowProperty.swift
//  Real Estate Property App
//
//  Created by Kate Alyssa Joanna L. de Leon on 4/1/25.
//

import Foundation

struct ZillowSearchResponse: Codable {
    let props: [ZillowProperty]
}

struct ZillowProperty: Codable {
    let zpid: String
    let address: String?
    let price: Double?
    let bedrooms: Double?
    let bathrooms: Double?
    let imgSrc: String?
    let propertyType: String?
    let listingStatus: String?
    let lotAreaValue: Double?
    let daysOnZillow: Int?
}
