import CoreData

open class Model: NSManagedObject {
	open var asDictionary: [String: Any] {
		return entity.attributesByName.keys.reduce([String: Any]()) { (r, k) in
			var r = r
			r[k] = value(forKey: k)
			return r
		}
	}
	
	public func delete() {
		type(of: self).store.managedContext.delete(self)
		type(of: self).store.commit()
	}

	func undo() { type(of: self).store.undo() }
	
	public var entityName: String { return store.entityName }

	public var store: Store<Model> { return type(of: self).store }
	public static var entityName: String { return store.entityName }
	static var store = Store<Model>()
	
	lazy var directory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
