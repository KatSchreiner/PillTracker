//
//  TakenPillsStore.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 12.06.2025.
//

import CoreData
import UIKit

final class TakenPillsStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private let timesTransformer = TimesTransformer()
    
    var takenPills: [TakenPills] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TakenPillsCoreData> = {
        let fetchRequest = TakenPillsCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TakenPillsCoreData.id, ascending: true)]
        
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print("❌ Ошибка при выполнении fetch: \(error.localizedDescription)")
        }
        
        return fetchedResultController
    }()
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("❌ Невозможно привести UIApplication.shared.delegate к AppDelegate")
        }
        self.init(context: appDelegate.persistentContainer.viewContext)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func addTakenPill(pill: Pill, pillId: UUID, time: (hour: String, minute: String), date: Date) {
        guard let existingPill = fetchPillById(pillId) else {
            print("❌ Лекарство с ID '\(pillId)' не найдено.")
            return
        }
        
        let takenPill = TakenPillsCoreData(context: context)
        takenPill.pillId = pillId
        takenPill.date = date
        
        guard let transformedTime = timesTransformer.transformedValue([(time.hour, time.minute)]) as? [[String: String]] else {
            print("❌ Ошибка при преобразовании времени.")
            return
        }
        takenPill.time = transformedTime as NSObject
        
        do {
            try context.save()
        } catch {
            print("❌ Ошибка при сохранении контекста: \(error.localizedDescription)")
        }
        
        print("✅ Лекарство '\(existingPill.name)' c ID '\(pillId)' добавлено в список принятых.")
    }
    
    func removeTakenPill(pillId: UUID, pill: Pill, time: (hour: String, minute: String), date: Date) {
        guard let existingPill = fetchPillById(pillId) else {
            print("❌ Лекарство '\(pill.name)' с ID '\(pillId)' не найдено.")
            return
        }
        
        let fetchRequest: NSFetchRequest<TakenPillsCoreData> = TakenPillsCoreData.fetchRequest()
        
        guard let transformedTime = timesTransformer.transformedValue([(time.hour, time.minute)]) as? [[String: String]] else {
            print("❌ Ошибка при преобразовании времени.")
            return
        }
        
        fetchRequest.predicate = NSPredicate(format: "date == %@ AND pillId == %@ AND time == %@", date as NSDate, pillId as CVarArg, transformedTime as NSObject)
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                context.delete(result)
            }
            
            try context.save()
            
            takenPills.removeAll { $0.pillId == pillId }
            print("✅ Лекарство '\(existingPill.name)' с ID '\(pillId)' удалено из списка принятых.")
        } catch {
            print("❌ Ошибка при удалении: \(error.localizedDescription)")
        }
    }
    
    func fetchPillById(_ pillId: UUID) -> Pill? {
        let pillStore = PillStore()
        return pillStore.fetchPillById(pillId)
    }
    
    func fetchTakenPills() -> [TakenPills] {
        let fetchRequest: NSFetchRequest<TakenPillsCoreData> = TakenPillsCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            takenPills = results.compactMap { result in
                guard let pill = fetchPillById(result.pillId ?? UUID()),
                      let timeArray = result.time as? [[String: String]],
                      let firstTime = timeArray.first,
                      let hour = firstTime["hour"],
                      let minute = firstTime["minute"] else {
                    return nil
                }
                return TakenPills(pillId: result.pillId ?? UUID(), pill: pill, time: (hour: hour, minute: minute), date: result.date ?? Date())
            }
            let takenPillsInfo = takenPills.map { "Название: \($0.pill.name), ID: \($0.pillId)" }
            print("✅ Выпитые лекарства успешно загружены: \(takenPillsInfo)")
        } catch {
            print("❌ Ошибка при загрузке принятых лекарств: \(error.localizedDescription)")
        }
        return takenPills
    }
}
