import Fluent
import Leaf
import SwiftGD
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    let todoController = TodoController()
    app.get("todos", use: todoController.index)
    app.post("todos", use: todoController.create)
    app.delete("todos", ":todoID", use: todoController.delete)
    
    
    let rootDirectory: URL = URL(string: app.directory.publicDirectory)!
    let uploadDirectory: URL = rootDirectory.appendingPathComponent("uploads")
    let originalsDirectory: URL = uploadDirectory.appendingPathComponent("originals")
    let thumbsDirectory: URL = uploadDirectory.appendingPathComponent("thumbs")

    app.on(.POST, "upload", body: .collect(maxSize: 2_000_000_000)) { req -> Response in
        struct UserFile: Content {
            var upload: File
        }
        
        let file = try req.content.decode(UserFile.self)
        let acceptableTypes = [
            HTTPMediaType(type: "image", subType: "png"),
            HTTPMediaType(type: "image", subType: "jpeg"),
        ]
        
        guard let mimeType = file.upload.contentType,
            acceptableTypes.contains(mimeType) else {
                throw Abort(HTTPResponseStatus.unsupportedMediaType)
        }
        
        let cleanedFilename = file.upload.filename.replacingOccurrences(of: " ", with: "-")
        let newURL = originalsDirectory.appendingPathComponent(cleanedFilename)
        _ = try? Data(buffer: file.upload.data).write(to: URL(fileURLWithPath: newURL.relativeString))
        
        let thumbURL = thumbsDirectory.appendingPathComponent(cleanedFilename)
        if let image = Image(url: newURL) {
            if let resized = image.resizedTo(width: 300) {
                resized.write(to: thumbURL)
            }
        }
        
        return req.redirect(to: "/")
    }
    
    app.get { req -> EventLoopFuture<View> in
        let fileManager = FileManager()
        guard let files = try? fileManager.contentsOfDirectory(
            at: originalsDirectory,
            includingPropertiesForKeys: nil,
            options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) else {
                throw Abort(HTTPResponseStatus.internalServerError)
        }
        
        let allFilenames: [String] = files.map { $0.lastPathComponent }
        let visibleFileNames: [String] = allFilenames.filter { !$0.hasPrefix(".") }
        
        struct Context: Codable {
            struct Index: Codable {
                var title: String
                var mainHeader: String
            }

            struct Page: Codable {
                var files: [String]
            }
            
            var index: Context.Index
            var page: Context.Page
        }
        
        let context = Context(
            index: .init(title: "UPLOAD IMAGES",
                         mainHeader: "List of images on disk"),
            page: .init(files: visibleFileNames)
        )
        
        return req.view.render("page", context)
    }
    
    
//    app.post("upload") { (req) -> Response in
//        struct UserFile: Content {
//            var upload: File
//        }
//
//        let file = try req.content.decode(UserFile.self)
//        let acceptableTypes = [
//            HTTPMediaType(type: "image", subType: "png"),
//            HTTPMediaType(type: "image", subType: "jpeg"),
//        ]
//
//        guard let mimeType = file.upload.contentType,
//            acceptableTypes.contains(mimeType) else {
//                throw Abort(HTTPResponseStatus.unsupportedMediaType)
//        }
//
//        let cleanedFilename = file.upload.filename.replacingOccurrences(of: " ", with: "-")
//        let newURL = originalsDirectory.appendingPathComponent(cleanedFilename)
//        _ = try? Data(buffer: file.upload.data).write(to: URL(fileURLWithPath: newURL.relativeString))
//
//        let thumbURL = thumbsDirectory.appendingPathComponent(cleanedFilename)
//        if let image = Image(url: newURL) {
//            if let resized = image.resizedTo(width: 300) {
//                resized.write(to: thumbURL)
//            }
//        }
//
//        return req.redirect(to: "/")
//    }
}
