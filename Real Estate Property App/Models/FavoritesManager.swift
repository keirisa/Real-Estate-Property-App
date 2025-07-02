//
//  FavoritesManager.swift
//  Real Estate Property App
//
//  Created by Kate Alyssa Joanna L. de Leon on 4/3/25.
//

import CoreData

class FavoritesManager {
    static let shared = FavoritesManager()
    
    private init() {}
    
    func addToFavorites(property: ZillowProperty, for user: AppUser) {
        let context = PersistenceController.shared.context
        
        // first check if this favorite already exists for this user
        let fetchRequest: NSFetchRequest<FavoriteProperty> = FavoriteProperty.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "zpid == %@ AND appUser == %@", property.zpid, user)
        
        do {
            let existingFavorites = try context.fetch(fetchRequest)
            if !existingFavorites.isEmpty {
                print("DEBUG: Favorite already exists for this user")
                return
            }
        } catch {
            print("DEBUG: Error checking existing favorites: \(error)")
        }
        
        // Create new favorite
        let favorite = FavoriteProperty(context: context)
        favorite.zpid = property.zpid
        favorite.propertyID = property.zpid
        favorite.address = property.address
        favorite.price = property.price ?? 0
        favorite.bedrooms = Double(property.bedrooms ?? 0)
        favorite.bathrooms = Double(property.bathrooms ?? 0)
        favorite.imageURL = property.imgSrc
        favorite.dateAdded = Date()
        favorite.isFavorited = true
        favorite.propertyType = property.propertyType
        favorite.listingType = property.listingStatus
        favorite.lotArea = property.lotAreaValue ?? 0
        favorite.daysOnZillow = Int16(property.daysOnZillow ?? 0)
        
        // CRUCIAL: Set the relationship
        favorite.appUser = user
        
        do {
            try context.save()
            print("DEBUG: Successfully saved favorite for user \(user.username ?? "nil")")
        } catch {
            print("DEBUG: Error saving favorite: \(error)")
            context.rollback()
        }
    }
    
    func getFavorites(for user: AppUser) -> [FavoriteProperty] {
        let request: NSFetchRequest<FavoriteProperty> = FavoriteProperty.fetchRequest()
        request.predicate = NSPredicate(format: "appUser == %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let results = try PersistenceController.shared.context.fetch(request)
            print("Found \(results.count) favorites") // Debug
            return results
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }
    
    func removeFromFavorites(zpid: String, for user: AppUser?) {
        guard let user = user else { return }
        
        let context = PersistenceController.shared.context
        let request: NSFetchRequest<FavoriteProperty> = FavoriteProperty.fetchRequest()
        request.predicate = NSPredicate(format: "zpid == %@ AND appUser == %@", zpid, user)
        
        do {
            let results = try context.fetch(request)
            results.forEach { context.delete($0) }
            try context.save()
            print("Successfully removed favorite: \(zpid)")
        } catch {
            print("Error removing favorite: \(error)")
            context.rollback()
        }
    }
    
    func isFavorite(property: ZillowProperty, for user: AppUser?) -> Bool {
        guard let user = user else { return false }
        
        let request: NSFetchRequest<FavoriteProperty> = FavoriteProperty.fetchRequest()
        request.predicate = NSPredicate(format: "zpid == %@ AND appUser == %@", property.zpid, user)
        
        do {
            let count = try PersistenceController.shared.context.count(for: request)
            return count > 0
        } catch {
            print("Error checking favorite: \(error)")
            return false
        }
    }
    
    func debugPrintAllFavorites() {
        let request: NSFetchRequest<FavoriteProperty> = FavoriteProperty.fetchRequest()
        do {
            let all = try PersistenceController.shared.context.fetch(request)
            print("=== ALL MY FAVORITES SAVED IN DATABASE ===")
            all.forEach { fav in
                print("""
                - Address: \(fav.address ?? "nil")
                - Price: \(fav.price)
                - Lot Area: \(fav.lotArea) sqft
                - Days On Zillow: \(fav.daysOnZillow)
                - User: \(fav.appUser?.username ?? "nil")
                - Date: \(fav.dateAdded ?? Date())
                """)
            }
        } catch {
            print("Error fetching all favorites: \(error)")
        }
    }
    
    func debugPrintAllUsers() {
        let request: NSFetchRequest<AppUser> = AppUser.fetchRequest()
        do {
            let users = try PersistenceController.shared.context.fetch(request)
            print("=== ALL USERS ===")
            for user in users {
                print("- \(user.username ?? "nil") (\(user.objectID))")
            }
        } catch {
            print("Error fetching users: \(error)")
        }
    }
}
