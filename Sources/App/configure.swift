import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import NIOTLS

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.views.use(.leaf)
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: 5434,
        username: Environment.get("DATABASE_USERNAME") ?? "fweissi",
        password: Environment.get("DATABASE_PASSWORD") ?? "fweissi",
        database: Environment.get("DATABASE_NAME") ?? "fweissi"
    ), as: .psql)

    app.migrations.add(CreateTodo())
    
    // configure any services
    app.http.server.configuration.supportVersions = [.one]
    app.http.server.configuration.hostname = "teratronibook-pro.local"
    app.http.server.configuration.responseCompression = .enabled
    app.http.server.configuration.requestDecompression = .disabled  // .enabled(limit: .none)
    
    // Enable TLS.
    // access home directory:
    // let homePath = NSString(string: "~").expandingTildeInPath

    // use .env file to provide cert / key paths:
    // let certPath = Environment.get("CERT_PATH")!
    // let keyPath = Environment.get("KEY_PATH")!

    let publicPath = app.directory.publicDirectory
    let resoucesPath = app.directory.resourcesDirectory
    let certPath = publicPath + "Cert/cert.pem"
    let keyPath = resoucesPath + "Key/key.pem"
    try app.http.server.configuration.tlsConfiguration = .forServer(
        certificateChain: [
            .certificate(.init(
                file: certPath,
                format: .pem
            ))
        ],
        privateKey: .file(keyPath)
    )

    // register routes
    try routes(app)
}
