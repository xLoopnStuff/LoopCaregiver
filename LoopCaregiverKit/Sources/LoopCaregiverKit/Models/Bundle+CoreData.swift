import Foundation
import CoreData

public extension Bundle {

    // --- BAKOVERKOMPATIBELT: brukes fortsatt fra CoreDataAccountService.swift ---
    static var coreDataModelURL: URL {
        #if SWIFT_PACKAGE
        if let url = Bundle.module.url(forResource: "LoopCaregiver", withExtension: "momd") {
            return url
        }
        #endif

        // SPM legger modellen i denne resource-bundlen inne i appen
        if let resURL = Bundle(for: LooperCD.self)
            .url(forResource: "LoopCaregiverKit_LoopCaregiverKit", withExtension: "bundle"),
           let resBundle = Bundle(url: resURL),
           let url = resBundle.url(forResource: "LoopCaregiver", withExtension: "momd") {
            return url
        }

        // Fallbacks
        if let url = Bundle.main.url(forResource: "LoopCaregiver", withExtension: "momd") {
            return url
        }
        for b in Bundle.allFrameworks {
            if let url = b.url(forResource: "LoopCaregiver", withExtension: "momd") {
                return url
            }
        }
        fatalError("Could not find LoopCaregiver.momd")
    }

    // --- Ny robust variant (kan tas i bruk senere) ---
    static var caregiverManagedObjectModel: NSManagedObjectModel = {
        #if SWIFT_PACKAGE
        if let m = NSManagedObjectModel.mergedModel(from: [Bundle.module]) {
            return m
        }
        #endif

        if let resURL = Bundle(for: LooperCD.self)
            .url(forResource: "LoopCaregiverKit_LoopCaregiverKit", withExtension: "bundle"),
           let resBundle = Bundle(url: resURL),
           let m = NSManagedObjectModel.mergedModel(from: [resBundle]) {
            return m
        }

        let candidates: [Bundle] = [Bundle.main, Bundle(for: LooperCD.self)] + Bundle.allFrameworks
        if let m = NSManagedObjectModel.mergedModel(from: candidates) {
            return m
        }
        fatalError("Could not load Core Data model for LoopCaregiver.")
    }()

    static func caregiverPersistentContainer(inMemory: Bool = false) -> NSPersistentContainer {
        let container = NSPersistentContainer(
            name: "LoopCaregiverStore",
            managedObjectModel: caregiverManagedObjectModel
        )
        let desc = container.persistentStoreDescriptions.first ?? NSPersistentStoreDescription()
        if inMemory { desc.url = URL(fileURLWithPath: "/dev/null") }
        desc.shouldMigrateStoreAutomatically = true
        desc.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [desc]
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Core Data load error: \(error)") }
        }
        return container
    }
}
