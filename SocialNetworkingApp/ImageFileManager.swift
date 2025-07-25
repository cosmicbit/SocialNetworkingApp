import Foundation
import UIKit

enum ImageStorageError: Error {
    case directoryNotFound
    case dataConversionFailed
    case fileWritingFailed(Error)
    case fileReadingFailed(Error)
    case fileDeletionFailed(Error)
    case fileNotFound
}

class ImageFileManager {

    static let shared = ImageFileManager() // Singleton for easy access

    private func getDirectoryURL(for directory: FileManager.SearchPathDirectory) throws -> URL {
        do {
            return try FileManager.default.url(for: directory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: true) // Create directory if it doesn't exist
        } catch {
            print("Error getting directory URL for \(directory): \(error.localizedDescription)")
            throw ImageStorageError.directoryNotFound
        }
    }

    private func getImageDirectory() throws -> URL {
        // You can choose .documentDirectory, .cachesDirectory, or .applicationSupportDirectory
        // For app-managed images that should persist and be backed up, .applicationSupportDirectory is often good.
        // For images that can be re-downloaded/re-created and shouldn't be backed up, use .cachesDirectory.
        return try getDirectoryURL(for: .applicationSupportDirectory)
    }

    // You can also create a subdirectory within the chosen directory for better organization
    private func getImagesSubdirectory() throws -> URL {
        let baseDirectory = try getImageDirectory()
        let imagesDirectory = baseDirectory.appendingPathComponent("MyImages")
        
        // Create the subdirectory if it doesn't exist
        if !FileManager.default.fileExists(atPath: imagesDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating 'MyImages' subdirectory: \(error.localizedDescription)")
                throw ImageStorageError.directoryNotFound
            }
        }
        return imagesDirectory
    }

    // MARK: - Saving Images

    func saveImage(image: UIImage, withName imageName: String, completion: @escaping (URL?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { // Or .pngData()
            completion(nil, ImageStorageError.dataConversionFailed)
            return
        }

        do {
            let directoryURL = try getImagesSubdirectory()
            let fileURL = directoryURL.appendingPathComponent(imageName) // Add extension if needed: imageName + ".jpg"

            try imageData.write(to: fileURL)
            print("Image saved successfully to: \(fileURL.path)")
            completion(fileURL, nil)
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            completion(nil, nil)
        }
    }

    // MARK: - Loading Images

    func loadImage(url fileURL: URL, completion: @escaping (UIImage?, Error?) -> Void) {
        do {
            //let directoryURL = try getImagesSubdirectory()
            //let fileURL = directoryURL.appendingPathComponent(imageName) // Ensure the name matches the saved name
            
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                completion(nil, nil)
                return
            }

            let imageData = try Data(contentsOf: fileURL)
            guard let image = UIImage(data: imageData) else {
                completion(nil, nil)
                return
            }
            print("Image loaded successfully from: \(fileURL.path)")
            completion(image, nil)
        } catch {
            print("Error loading image")
            completion(nil, nil)
        }
    }

    // MARK: - Deleting Images

    func deleteImage(named imageName: String) throws {
        do {
            let directoryURL = try getImagesSubdirectory()
            let fileURL = directoryURL.appendingPathComponent(imageName)

            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                throw ImageStorageError.fileNotFound
            }

            try FileManager.default.removeItem(at: fileURL)
            print("Image deleted successfully: \(fileURL.path)")
        } catch let error as ImageStorageError {
            throw error
        } catch {
            print("Error deleting image: \(error.localizedDescription)")
            throw ImageStorageError.fileDeletionFailed(error)
        }
    }
    
    // MARK: - Check if image exists
    
    func imageExists(named imageName: String) -> Bool {
        do {
            let directoryURL = try getImagesSubdirectory()
            let fileURL = directoryURL.appendingPathComponent(imageName)
            return FileManager.default.fileExists(atPath: fileURL.path)
        } catch {
            return false // Directory not found or other error
        }
    }

    // MARK: - Helper for unique file names

    func generateUniqueImageName(prefix: String? = nil, fileExtension: String) -> String {
        let uuid = UUID().uuidString
        if let prefix = prefix, !prefix.isEmpty {
            return "\(prefix)_\(uuid).\(fileExtension)"
        }
        return "\(uuid).\(fileExtension)"
    }
}
