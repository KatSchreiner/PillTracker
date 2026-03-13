//
//  PillStore.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 29.04.2025.
//

import CoreData
import UIKit

class PillStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private let selectedDaysTransformer = SelectedDaysTransformer()
    private let timesTransformer = TimesTransformer()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<PillCoreData> = {
        let fetchRequest = PillCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PillCoreData.id, ascending: true)]
        
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
    
    func savePill(pill: Pill) {
        let myPill = PillCoreData(context: context)
        myPill.id = pill.id
        myPill.name = pill.name
        myPill.dosage = pill.dosage
        myPill.unit = pill.unit
        myPill.howToTake = pill.howToTake
        myPill.icon = pill.icon?.pngData()
        myPill.selectedDays = selectedDaysTransformer.transformedValue(pill.selectedDays) as? NSObject
        myPill.selectedInterval = Int32(pill.selectedInterval ?? 0)
        myPill.times = timesTransformer.transformedValue(pill.times) as? NSObject
        myPill.selectedStartDate = pill.selectedStartDate
        myPill.selectedEndDate = pill.selectedEndDate
        
        do {
            try context.save()
        } catch {
            print("❌ Ошибка при сохранении контекста: \(error.localizedDescription)")
        }
        
        print("✅ Лекарство '\(pill.name)' успешно сохранено.")
    }
    
    func updatePill(_ pill: Pill) {
        let fetchRequest: NSFetchRequest<PillCoreData> = PillCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", pill.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let pillCoreData = results.first {

                pillCoreData.name = pill.name
                pillCoreData.dosage = pill.dosage
                pillCoreData.unit = pill.unit
                pillCoreData.howToTake = pill.howToTake
                pillCoreData.icon = pill.icon?.pngData()
                pillCoreData.selectedDays = selectedDaysTransformer.transformedValue(pill.selectedDays) as? NSObject
                pillCoreData.selectedInterval = Int32(pill.selectedInterval ?? 0)
                pillCoreData.times = timesTransformer.transformedValue(pill.times) as? NSObject
                pillCoreData.selectedStartDate = pill.selectedStartDate
                pillCoreData.selectedEndDate = pill.selectedEndDate
                
                try context.save()
                print("✅ Лекарство '\(pill.name)' успешно обновлено.")
            } else {
                print("❌ Лекарство с ID '\(pill.id)' не найдено.")
            }
        } catch {
            print("❌ Ошибка при обновлении лекарства: \(error.localizedDescription)")
        }
    }
    
    func deletePill(_ pillId: UUID) {
        let fetchRequest: NSFetchRequest<PillCoreData> = PillCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", pillId as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let pillToDelete = results.first {
                deleteTakenPills(for: pillId)
                
                context.delete(pillToDelete)
                try context.save()
                
                let verifyRequest: NSFetchRequest<PillCoreData> = PillCoreData.fetchRequest()
                verifyRequest.predicate = NSPredicate(format: "id == %@", pillId as CVarArg)
                let verifyResults = try context.fetch(verifyRequest)
                print("🔍 Post-deletion verification: \(verifyResults.count) pills found")
                
                NSFetchedResultsController<PillCoreData>.deleteCache(withName: nil)
                try fetchedResultsController.performFetch()
                
                print("✅ Лекарство с ID '\(pillId)' успешно удалено.")
            } else {
                print("❌ Лекарство с ID '\(pillId)' не найдено для удаления.")
            }
        } catch {
            print("❌ Ошибка при удалении лекарства: \(error.localizedDescription)")
            context.rollback()
        }
    }
    
    private func deleteTakenPills(for pillId: UUID) {
        let fetchRequest: NSFetchRequest<TakenPillsCoreData> = TakenPillsCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pillId == %@", pillId as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            for takenPill in results {
                context.delete(takenPill)
            }
            print("✅ Удалено \(results.count) записей о принятии лекарства с ID '\(pillId)'")
        } catch {
            print("❌ Ошибка при удалении записей о принятии лекарства: \(error.localizedDescription)")
        }
    }
    
    func fetchPillById(_ pillId: UUID) -> Pill? {
        let fetchRequest: NSFetchRequest<PillCoreData> = PillCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", pillId as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let pillCoreData = results.first {
                return transformToPill(pillCoreData)
            }
        } catch {
            print("❌ Ошибка при загрузке лекарства с ID '\(pillId)': \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func fetchPills() -> [Pill] {
        do {
            try fetchedResultsController.performFetch()
            
            guard let pills = fetchedResultsController.fetchedObjects else {
                print("❌ Лекарства не найдены.")
                return []
            }
            
            if pills.isEmpty {
                print("✅ Список лекарств пуст.")
                return []
            }
            
            print("✅ Лекарства успешно загружены: \(pills.compactMap { $0.name })")
            return pills.compactMap { transformToPill($0) }
        } catch {
            print("❌ Ошибка при загрузке лекарств: \(error.localizedDescription)")
            return []
        }
    }
    
    private func transformToPill(_ pillCoreData: PillCoreData) -> Pill {
        return Pill(
            id: pillCoreData.id ?? UUID(),
            icon: pillCoreData.icon != nil ? UIImage(data: pillCoreData.icon!) : nil,
            name: pillCoreData.name ?? "",
            dosage: pillCoreData.dosage,
            unit: pillCoreData.unit ?? "",
            howToTake: pillCoreData.howToTake ?? "",
            times: timesTransformer.reverseTransformedValue(pillCoreData.times) as? [(hour: String, minute: String)] ?? [],
            selectedDays: selectedDaysTransformer.reverseTransformedValue(pillCoreData.selectedDays) as? [Int] ?? [],
            selectedInterval: Int(pillCoreData.selectedInterval),
            selectedStartDate: pillCoreData.selectedStartDate ?? Date(),
            selectedEndDate: pillCoreData.selectedEndDate ?? Date(),
            isReminderEnabled: pillCoreData.isReminderEnabled
        )
    }
}

extension PillStore {
    func clearCache() {
        fetchedResultsController.fetchRequest.predicate = nil
        try? fetchedResultsController.performFetch()
    }
}
