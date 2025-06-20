//
//  PillStore.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 29.04.2025.
//

import CoreData
import UIKit

final class PillStore: NSObject, NSFetchedResultsControllerDelegate {
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
        guard let pills = fetchedResultsController.fetchedObjects else {
            print("❌ Лекарства не найдены.")
            return []
        }
        
        print("✅ Лекарства успешно загружены: \(pills.map { $0.name ?? "неизвестная таблетка" })")
        
        return pills.compactMap { transformToPill($0) }
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
            selectedDays: selectedDaysTransformer.reverseTransformedValue(pillCoreData.selectedDays) as? Set<Int> ?? Set(),
            selectedStartDate: pillCoreData.selectedStartDate ?? Date(),
            selectedEndDate: pillCoreData.selectedEndDate ?? Date()
        )
    }
}
