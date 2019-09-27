import CoreData

open class Stack: NSObject {
	public static var ace: Stack!
	public var bundle: Bundle!
	public var containerName: String!
	public var fileName: String!
	public var applicationGroupIdentifier: String!

	lazy var mainContext: NSManagedObjectContext! = {
		let mc = persistentContainer.viewContext
		mc.undoManager = UndoManager()
		return mc
	}()
	
	public lazy var persistentContainer: NSPersistentContainer = {
		guard let mom = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Error initializing mom from: \(modelURL)") }
		
		let pc = NSPersistentContainer(name: containerName, managedObjectModel: mom)
		if storeExists { pc.persistentStoreDescriptions = [storeDescription(for: url)] }
		pc.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? { fatalError("Unresolved error \(error), \(error.userInfo)") }
		})
		return pc
	}()
	
	lazy var modelURL: URL = {
		guard let u = bundle.url(forResource: containerName, withExtension:"momd") else { fatalError("Error loading model from bundle") }
		return u
	}()
	
	public func saveContext () {
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
	
	public func storeDescription(for url: URL) -> NSPersistentStoreDescription {
		let d = NSPersistentStoreDescription(url: url)
		d.shouldInferMappingModelAutomatically = true
		d.shouldMigrateStoreAutomatically = true
		return d
	}
	
	lazy var url = directory.appendingPathComponent(fileName)
	lazy var directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: applicationGroupIdentifier)!
	lazy var storeExists = FileManager.default.fileExists(atPath: url.path)
}
