//
//  PillStore.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 29.04.2025.
//

import CoreData
import UIKit

final class PillStore: NSObject {
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
            print("Лекарство '\(pill.name)' успешно сохранено.")
        } catch {
            print("Oшибка при сохранении лекарства: \(error.localizedDescription)")
        }
    }
    
    func fetchPills() -> [Pill] {
        guard let pills = fetchedResultsController.fetchedObjects else {
            print("Таблетки не найдены.")
            return [] }
        
        print("Таблетки успешно загружены: \(pills.map { $0.name ?? "неизвестная таблетка" })")
        
        return pills.map { PillCoreData in
            Pill(
                id: PillCoreData.id ?? UUID(),
                icon: PillCoreData.icon != nil ? UIImage(data: PillCoreData.icon!) : nil,
                name: PillCoreData.name ?? "",
                dosage: PillCoreData.dosage,
                unit: PillCoreData.unit ?? "",
                howToTake: PillCoreData.howToTake ?? "",
                times: timesTransformer.reverseTransformedValue(PillCoreData.times) as? [(hour: String, minute: String)] ?? [],
                selectedDays: selectedDaysTransformer.reverseTransformedValue(PillCoreData.selectedDays) as? Set<Int> ?? Set(),
                selectedStartDate: PillCoreData.selectedStartDate ?? Date(),
                selectedEndDate: PillCoreData.selectedEndDate ?? Date()
            )
        }
    }
}

extension PillStore: NSFetchedResultsControllerDelegate {
}
