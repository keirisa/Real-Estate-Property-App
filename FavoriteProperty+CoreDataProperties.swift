//
//  FavoriteProperty+CoreDataProperties.swift
//  Real Estate Property App
//
//  Created by Kate Alyssa Joanna L. de Leon on 4/1/25.
//
//

import Foundation
import CoreData


extension FavoriteProperty {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteProperty> {
        return NSFetchRequest<FavoriteProperty>(entityName: "FavoriteProperty")
    }

    @NSManaged public var imageURL: String?
    @NSManaged public var address: String?
    @NSManaged public var propertyID: String?
    @NSManaged public var price: Double
    @NSManaged public var bedrooms: Int16
    @NSManaged public var isFavorited: Bool
    @NSManaged public var appUser: AppUser?

}

extension FavoriteProperty : Identifiable {

}
