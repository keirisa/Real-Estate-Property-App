//
//  PersistenceController.swift
//  Real Estate Property App
//
//  Created by Kate Alyssa Joanna L. de Leon on 4/1/25.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    let context: NSManagedObjectContext

    private init() {
        let container = NSPersistentContainer(name: "Real_Estate_Property_App")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed: \(error)")
            }
        }
        self.context = container.viewContext
    }

    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
}
