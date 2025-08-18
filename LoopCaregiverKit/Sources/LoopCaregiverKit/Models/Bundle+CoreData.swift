//
//  Bundle+CoreData.swift
//

import Foundation
import CoreData

public extension Bundle {

    /// Robust oppslag av Core Data-modellen, funker i SPM + app
    static var caregiverManagedObjectModel: NSManagedObjectModel = {
        // 1) Best: SPM-resource bundle
        #if SWIFT_PACKAGE
        if let m = NSManagedObjectModel.mergedModel(from: [Bundle.module]) {
            return m
        }
        #endif

        // 2) App-runtime: ressurs-bundlen vi fant i .ipa
        if let resURL = Bundle(for: LooperCD.self)
            .url(forResource: "LoopCaregiverKit_LoopCaregiverKit", withExtension: "bundle"),
           let resBundle = Bundle(url: resURL),
           let m = NSManagedObjectModel.mergedModel(from: [resBundle]) {
            return m
        }

        // 3) Fallback: prøv kjente bundler
        let candidates: [Bundle] = [Bundle.main, Bundle(for: LooperCD.self)] + Bundle.allFrameworks
        if let m = NSManagedObjectModel.mergedModel(from: candidates) {
            return m
        }

        fatalError("Could not load Core Data model for LoopCaregiver.")
    }()

    /// Lag en persistent container som bruker modellen over
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
