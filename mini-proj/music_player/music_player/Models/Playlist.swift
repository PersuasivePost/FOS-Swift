import Foundation

struct Playlist: Codable {
    let id: String
    var name: String
    var songs: [Song]
    
    init(id: String = UUID().uuidString, name: String, songs: [Song] = []) {
        self.id = id
        self.name = name
        self.songs = songs
    }
}

// MARK: - Sample Playlist Generation
extension Playlist {
    static func createSamplePlaylists(from songs: [Song]) -> [Playlist] {
        guard !songs.isEmpty else { return [] }
        
        let playlist1 = Playlist(
            name: "Favorites",
            songs: Array(songs.prefix(3))
        )
        
        let playlist2 = Playlist(
            name: "Workout",
            songs: songs.filter { $0.title.lowercased().contains("beat") || $0.moodTag == "Energetic" }
        )
        
        let playlist3 = Playlist(
            name: "Relaxing",
            songs: songs.filter { $0.moodTag == "Calm" || $0.album.lowercased().contains("relax") }
        )
        
        return [playlist1, playlist2, playlist3]
    }
}

// MARK: - Playlist Persistence
class PlaylistManager {
    static let shared = PlaylistManager()
    private init() {}
    
    private let fileName = "playlists.json"
    
    private var fileURL: URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }
    
    func savePlaylists(_ playlists: [Playlist]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(playlists)
            try data.write(to: fileURL)
        } catch {
            print("❌ Failed to save playlists: \(error.localizedDescription)")
        }
    }
    
    func loadPlaylists() -> [Playlist] {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let playlists = try decoder.decode([Playlist].self, from: data)
            return playlists
        } catch {
            print("⚠️ No playlists found or failed to load: \(error.localizedDescription)")
            return []
        }
    }
}

