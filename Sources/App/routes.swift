import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let docController = DocController()
    try router.register(collection: docController)
}

