import Foundation
import AVFoundation
import UIKit

class AudioFileManager {
    static let shared = AudioFileManager()
    
    private let fileManager = FileManager.default
    
    // Supported audio file extensions
    private let supportedExtensions = ["mp3", "m4a", "wav", "aac", "aif", "aiff"]
    
    // Directory paths
    private var documentsDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var musicDirectory: URL {
        let musicDir = documentsDirectory.appendingPathComponent("Music", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: musicDir.path) {
            do {
                try fileManager.createDirectory(at: musicDir, withIntermediateDirectories: true)
            } catch {
                print("Error creating music directory: \(error)")
            }
        }
        
        return musicDir
    }
    
    private var downloadsDirectory: URL {
        let downloadsDir = documentsDirectory.appendingPathComponent("Downloads", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: downloadsDir.path) {
            do {
                try fileManager.createDirectory(at: downloadsDir, withIntermediateDirectories: true)
            } catch {
                print("Error creating downloads directory: \(error)")
            }
        }
        
        return downloadsDir
    }
    
    // MARK: - File Operations
    
    func getAllMusicFiles() -> [URL] {
        // Get files from app bundle
        let bundleFiles = getBundleMusicFiles()
        
        // Get files from documents directory
        let documentFiles = getDocumentMusicFiles()
        
        return bundleFiles + documentFiles
    }
    
    func getDownloadedFiles() -> [URL] {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: downloadsDirectory,
                includingPropertiesForKeys: nil
            )
            
            return fileURLs.filter { url in
                return supportedExtensions.contains(url.pathExtension.lowercased())
            }
        } catch {
            print("Error getting downloaded files: \(error)")
            return []
        }
    }
    
    private func getBundleMusicFiles() -> [URL] {
        var bundleFiles: [URL] = []
        
        for fileExtension in supportedExtensions {
            if let paths = Bundle.main.urls(forResourcesWithExtension: fileExtension, subdirectory: nil) {
                bundleFiles.append(contentsOf: paths)
            }
        }
        
        return bundleFiles
    }
    
    private func getDocumentMusicFiles() -> [URL] {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: musicDirectory,
                includingPropertiesForKeys: nil
            )
            
            return fileURLs.filter { url in
                return supportedExtensions.contains(url.pathExtension.lowercased())
            }
        } catch {
            print("Error getting document music files: \(error)")
            return []
        }
    }
    
    // MARK: - File Metadata
    
    func extractMetadata(from url: URL) -> (title: String, artist: String, album: String, duration: TimeInterval, artwork: UIImage?) {
        let asset = AVAsset(url: url)
        
        // Default values
        var title = url.deletingPathExtension().lastPathComponent
        var artist = "Unknown Artist"
        var album = "Unknown Album"
        var duration: TimeInterval = 0
        var artwork: UIImage? = nil
        
        // Get duration
        duration = CMTimeGetSeconds(asset.duration)
        
        // Get metadata
        let metadata = asset.metadata
        
        for item in metadata {
            guard let key = item.commonKey?.rawValue, let value = item.value else { continue }
            
            switch key {
            case "title":
                if let stringValue = value as? String {
                    title = stringValue
                }
            case "artist":
                if let stringValue = value as? String {
                    artist = stringValue
                }
            case "albumName":
                if let stringValue = value as? String {
                    album = stringValue
                }
            case "artwork":
                if let data = value as? Data {
                    artwork = UIImage(data: data)
                }
            default:
                break
            }
        }
        
        // If no artwork was found, use a default image
        if artwork == nil {
            artwork = UIImage(named: "default_album_art")
        }
        
        return (title, artist, album, duration, artwork)
    }
    
    // MARK: - File Management
    
    func downloadSong(from sourceURL: URL, completion: @escaping (URL?, Error?) -> Void) {
        let destinationURL = downloadsDirectory.appendingPathComponent(sourceURL.lastPathComponent)
        
        // Check if file already exists
        if fileManager.fileExists(atPath: destinationURL.path) {
            completion(destinationURL, nil)
            return
        }
        
        // Copy file to downloads directory
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            completion(destinationURL, nil)
        } catch {
            print("Error downloading song: \(error)")
            completion(nil, error)
        }
    }
    
    func deleteSong(at url: URL) -> Bool {
        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            print("Error deleting song: \(error)")
            return false
        }
    }
    
    // MARK: - Import Files
    
    func importSongToLibrary(from sourceURL: URL, completion: @escaping (URL?, Error?) -> Void) {
        let destinationURL = musicDirectory.appendingPathComponent(sourceURL.lastPathComponent)
        
        // Check if file already exists
        if fileManager.fileExists(atPath: destinationURL.path) {
            completion(destinationURL, nil)
            return
        }
        
        // Copy file to music directory
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            completion(destinationURL, nil)
        } catch {
            print("Error importing song: \(error)")
            completion(nil, error)
        }
    }
}
