import Foundation
import CoreData

public extension Bundle {
    /// URL til .momd som SPM bygger inn i denne pakken
    static var coreDataModelURL: URL {
        guard let url = Bundle.module.url(forResource: "LoopCaregiver", withExtension: "momd") else {
            fatalError("LoopCaregiver.momd ikke funnet i Bundle.module")
        }
        return url
    }

    /// Ferdiglastet NSManagedObjectModel fra SPM-bundle
    static var caregiverManagedObjectModel: NSManagedObjectModel = {
        guard let model = NSManagedObjectModel(contentsOf: coreDataModelURL) else {
            fatalError("Klarte ikke å laste NSManagedObjectModel fra \(coreDataModelURL)")
        }
        return model
    }()
}
