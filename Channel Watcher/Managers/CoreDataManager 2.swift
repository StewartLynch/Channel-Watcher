//
//  CoreDataManager.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation
import CoreData
import SwiftUI

class CoreDataManager {
    
    let persistentContainer: NSPersistentContainer
    static let shared = CoreDataManager()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "YouTube")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to initialize Core Data \(error)")
            }
        }
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print(directories[0])
    }
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext 
    }

    func save(completion: (Bool) -> Void) {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
                completion(true)
            } catch {
                completion(false)
            }
            
        }
    }
}

