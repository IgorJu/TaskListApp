//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Igor on 19.05.2023.
//

import Foundation
import CoreData


final class StorageManager {
    static let shared = StorageManager()
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK: - Delete Data
    func delete(task: Task) {
        viewContext.delete(task)
        saveContext()
    }
    //MARK: - Edit Data
    func edit(task: Task, to newValue: String) {
        task.title = newValue
        saveContext()
    }
    //MARK: - Save data
    func save(taskName: String, completion: @escaping (Task) -> Void) {
        let task = Task(context: viewContext)
        task.title = taskName
        completion(task)
        saveContext()
    }
    
    //MARK: - Fetch method
    func fetchData(completion: (Result<[Task], Error>) -> Void) {
       let fetchRequest = Task.fetchRequest()
        
        do {
            let tasks = try viewContext.fetch(fetchRequest)
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
