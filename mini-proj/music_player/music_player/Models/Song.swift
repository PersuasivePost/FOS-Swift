import Foundation
import UIKit

struct Song: Codable, Equatable {
    let id: String
    let title: String
    let artist: String
    let album: String
    let duration: TimeInterval
    let fileURL: URL
    var moodTag: String?
    
    // Non-codable properties
    var albumArt: UIImage?
    
    // Coding keys for Codable
    enum CodingKeys: String, CodingKey {
        case id, title, artist, album, duration, fileURL, moodTag
    }
    
    // Initialize from a file URL
    init(fileURL: URL) {
        self.id = UUID().uuidString
        self.fileURL = fileURL
        
        // Extract metadata from the file
        let metadata = AudioFileManager.shared.extractMetadata(from: fileURL)
        self.title = metadata.title
        self.artist = metadata.artist
        self.album = metadata.album
        self.duration = metadata.duration
        self.albumArt = metadata.artwork
    }
    
    // Custom initializer for creating a song with all properties
    init(id: String, title: String, artist: String, album: String, duration: TimeInterval, fileURL: URL, albumArt: UIImage?, moodTag: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.fileURL = fileURL
        self.albumArt = albumArt
        self.moodTag = moodTag
    }
    
    // Equatable implementation
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Encode method to handle non-Codable UIImage
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(artist, forKey: .artist)
        try container.encode(album, forKey: .album)
        try container.encode(duration, forKey: .duration)
        try container.encode(fileURL, forKey: .fileURL)
        try container.encodeIfPresent(moodTag, forKey: .moodTag)
    }
    
    // Init from decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        album = try container.decode(String.self, forKey: .album)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        fileURL = try container.decode(URL.self, forKey: .fileURL)
        moodTag = try container.decodeIfPresent(String.self, forKey: .moodTag)
        
        // Load album art
        let metadata = AudioFileManager.shared.extractMetadata(from: fileURL)
        albumArt = metadata.artwork
    }
}
