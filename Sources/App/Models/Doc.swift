import FluentPostgreSQL
import Vapor

final class Doc: Codable {
    
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
}

extension Doc: PostgreSQLModel {}
extension Doc: Content {}
extension Doc: Migration {}

extension Doc: Parameter {}

