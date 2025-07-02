//
//  AppUser+CoreDataProperties.swift
//  Real Estate Property App
//
//  Created by Kate Alyssa Joanna L. de Leon on 4/1/25.
//
//

import Foundation
import CoreData


extension AppUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppUser> {
        return NSFetchRequest<AppUser>(entityName: "AppUser")
    }

    @NSManaged public var username: String?
    @NSManaged public var password: String?
    @NSManaged public var favorites: NSSet?

}

// MARK: Generated accessors for favorites
extension AppUser {

    @objc(addFavoritesObject:)
    @NSManaged public func addToFavorites(_ value: FavoriteProperty)

    @objc(removeFavoritesObject:)
    @NSManaged public func removeFromFavorites(_ value: FavoriteProperty)

    @objc(addFavorites:)
    @NSManaged public func addToFavorites(_ values: NSSet)

    @objc(removeFavorites:)
    @NSManaged public func removeFromFavorites(_ values: NSSet)

}

extension AppUser : Identifiable {

}
