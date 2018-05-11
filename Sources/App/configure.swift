import Vapor
import FluentPostgreSQL
import Leaf

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    /// Register providers first
    try services.register(FluentProvider())
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    //middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

    /// Register custom PostgreSQL Config
    var databases = DatabasesConfig()
    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "User", database: "VaporTest", password: nil)
    let database = PostgreSQLDatabase(config: psqlConfig)
    databases.enableLogging(on: .psql)
    databases.add(database: database, as: .psql)

    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Doc.self, database: .psql)
    services.register(migrations)

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

}
