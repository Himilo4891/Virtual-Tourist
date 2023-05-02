//
//  DataController.swift
//  Virtual Tourist 12
//
//  Created by abdiqani on 21/03/23.
//

import Foundation
import CoreData


class DataController {
//    var persistentContainer: NSPersistentContainer {
    static let shared = DataController(modelName: "VirtualTourist12")
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    let backgroundContext:NSManagedObjectContext!

    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        
        backgroundContext = persistentContainer.newBackgroundContext()

    }
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    func load (completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.saveContext()
            self.configureContexts()
            completion?()
        }
    }

    func saveContext(interval:TimeInterval = 60) {
        print("autosaving")
        
        guard interval > 0 else{
            print("cannot set negative autosave interval")
            return
        }
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
        
    
}
