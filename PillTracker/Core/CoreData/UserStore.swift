//
//  UserStore.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 29.04.2025.
//

import CoreData
import UIKit

final class UserStore: NSObject {
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<UserCoreData> = {
        let fetchRequest = UserCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \UserCoreData.name, ascending: true)]
        
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Ошибка при выполнении fetch: \(error.localizedDescription)")
        }
        
        return fetchedResultController
    }()
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("Невозможно привести UIApplication.shared.delegate к AppDelegate")}
        
        self.init(context: appDelegate.persistentContainer.viewContext)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func saveUser (name: String) {
        if let existingUser  = fetchUserByName(name) {
            print("Пользователь '\(existingUser .name ?? "неизвестный")' уже существует.")
            return
        }
        
        let user = UserCoreData(context: context)
        user.name = name
        
        do {
            try context.save()
            print("Пользователь '\(name)' успешно сохранен.")
        } catch {
            print("Ошибка при сохранении пользователя: \(error.localizedDescription)")
        }
    }
    
    func fetchUser () -> UserCoreData? {
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first 
        } catch {
            print("Ошибка при выполнении fetch: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchUserByName(_ name: String) -> UserCoreData? {
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Ошибка при выполнении fetch: \(error.localizedDescription)")
            return nil
        }
    }
}

extension UserStore: NSFetchedResultsControllerDelegate {
}
