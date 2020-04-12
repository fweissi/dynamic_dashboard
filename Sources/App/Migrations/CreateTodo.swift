import Fluent

struct CreateTodo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos")
            .id()
            .field("title", .string, .required)
            .field("status", .string)
            .field("due", .datetime)
            .field("labels", .int)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos").delete()
    }
}
