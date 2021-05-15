//
//  BaseModel.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation
import CoreData

// These functions will be available to any CoreData model that conforms to that protocol.  You do that by creating an extension to the entity

protocol BaseModel: NSManagedObject {
    func save() throws
    func delete() throws
    static func byId<T: NSManagedObject>(id: NSManagedObjectID) -> T?
    static func all<T: NSManagedObject>() -> [T]
}

extension BaseModel {
    static var viewContext: NSManagedObjectContext {
        return CoreDataManager.shared.viewContext
    }
    
    func save() throws {
        do {
            try Self.viewContext.save()
        } catch {
            Self.viewContext.rollback()
            throw error
        }
    }
    
    func delete() throws {
        Self.viewContext.delete(self)
        try save() 
    }

    
    static func all<T>() -> [T] where T: NSManagedObject {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: T.self))
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    static func deleteAll() {
//        print("Deleting all Data")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Self.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch {
            print(error)
        }
    }
    
    
    static func byId<T>(id: NSManagedObjectID) -> T? where T: NSManagedObject {
        do {
            return try viewContext.existingObject(with: id) as? T
        } catch {
            print(error)
            return nil
        }
    }
    
}
