import Vapor
import Fluent
import Leaf

struct DocController: RouteCollection {
    
    func boot(router: Router) throws {
        let docsRouter = router.grouped("docs")
        docsRouter.get(use: getAllHandler)
        docsRouter.get("create", use: createHandler)
        docsRouter.post(use: createPostHandler)
        docsRouter.get(Doc.parameter, use: docInfoHandler)
    }
    
    func createHandler(_ req: Request) throws -> Future<View> {
        return try req.leaf().render("createDoc", "")
    }
    
    func createPostHandler(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(DocPostData.self).flatMap(to: Response.self) { data in
            let doc = Doc(name: data.name)
            return doc.save(on: req).map(to: Response.self) { _ in
                return req.redirect(to: "/docs")
            }
        }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<View> {
        return Doc.query(on: req).all().flatMap(to: View.self) { docs in
            return try req.leaf().render("allDocs", AllDocsData(docs: docs))
        }
    }
    
    func docInfoHandler(_ req: Request) throws -> Future<Doc> {
        return try req.parameters.next(Doc.self)
    }
    
}

extension Request {
    func leaf() throws -> LeafRenderer {
        return try self.make(LeafRenderer.self)
    }
}

struct DocPostData: Content {
    static var defaultMediaType = MediaType.urlEncodedForm
    let name: String
}

struct AllDocsData: Encodable {
    let docs: [Doc]
}
