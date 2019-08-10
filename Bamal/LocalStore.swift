import CoreData
import UIKit

open class LocalStore<M: LocalState>: NSObject {
	open func insert() -> M { return M(context: managedContext) }

	public var all: [M]  { return(fetch(fetchReq(sortedBy: [])) as! [M]) }
	
	public func by(id: String) -> M { return fetchedOrInsertedBy(predicate: predicateWith(id: id), initializing: nil) }
	public func fetchedOrInsertedBy(id: String) -> M { return fetchedOrInsertedBy(predicate: predicateWith(id: id), initializing: nil) }
	public func fetchedOrInsertedBy(id: String, initializing: ((M) -> Void)?) -> M { return fetchedOrInsertedBy(predicate: predicateWith(id: id), initializing: initializing) }
	public func fetchedOrInsertedBy(predicate: NSPredicate) -> M { return fetchedOrInsertedBy(predicate: predicate, initializing: nil) }

	public func fetchedOrInsertedBy(predicate: NSPredicate, initializing: ((M) -> Void)?) -> M {
		let fr = fetchReq(sortedBy: [])
		fr.predicate = predicate
		if let m = fetch(fr).first as? M { return m }
		else {
			let m = insert()
			if let i = initializing { i(m) }
			return m
		}
	}

	public func by(predicate: NSPredicate) -> M? {
		return by(predicate: predicate).first
	}

	public func by(predicate: NSPredicate) -> [M] {
		let fr = fetchReq(sortedBy: [])
		fr.predicate = predicate
		return fetch(fr) as! [M]
	}

	public func commit() {
		do { try managedContext.save() }
		catch { fatalError("Failed to save managedContext: \(error)") }
	}
	
	public func undo() { managedContext.undo() }
	
	public func deleteAll() {
		let r = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
		do {
			try managedContext.execute(r)
			try managedContext.save()
		}
		catch { fatalError("Failed to delete all managedContext: \(error)") }
	}
	
	public func fetch(_ request: NSFetchRequest<NSManagedObject> ) -> [NSManagedObject] {
		do {
			let r = try managedContext.fetch(request)
			return r
		}
		catch { fatalError("Failed to fetch \(request.entityName!) entities: \(error)") }
	}
	
	public func fetchReq(sortedBy sortDescriptors: [NSSortDescriptor] = []) -> NSFetchRequest<NSManagedObject> {
		let e = entityName
		do { if e == "undefined" { throw StoreError.invalidEntityName(forName: e) } }
		catch {
			print("\nThere is no entity model with the name '\(e)'. Check that your ViewFetchedDataSource redefines its controller to use the one from the correct Store subclass.\n")
		}
		let fr = NSFetchRequest<NSManagedObject>(entityName: e)
		fr.sortDescriptors = sortDescriptors
		return fr
	}
	
	public func controller(_ sortDescriptors: [NSSortDescriptor]) -> NSFetchedResultsController<M> {
		return NSFetchedResultsController(fetchRequest: fetchReq(sortedBy: sortDescriptors), managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil) as! NSFetchedResultsController<M>
	}

	func predicateWith(id: String) -> NSPredicate { return NSPredicate(format: "id = %@", id) }

	override public init() { managedContext = Stack.instance.mainContext }
	
	public var managedContext: NSManagedObjectContext
	open var entityName: String { return String(describing: M.self) }
	
	enum StoreError: Error { case invalidEntityName(forName: String) }
}

