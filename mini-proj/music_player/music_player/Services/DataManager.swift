import Foundation
import UIKit

class DataManager {
    static let shared = DataManager()
    
    private(set) var songs: [Song] = []
    private(set) var playlists: [Playlist] = []
    private(set) var downloadedSongs: [Song] = []
    
    private let audioFileManager = AudioFileManager.shared
    private let userDefaults = UserDefaults.standard
    
    private let playlistsKey = "savedPlaylists"
    private let downloadedSongsKey = "downloadedSongs"
    private let songsWithMoodKey = "songsWithMood"
    
    private init() {
        loadSongs()
        loadPlaylists()
        loadDownloadedSongs()
    }
    
    // MARK: - Data Loading
    
    private func loadSongs() {
        // Get all music files
        let musicFiles = audioFileManager.getAllMusicFiles()
        
        // Create Song objects from files
        songs = musicFiles.map { Song(fileURL: $0) }
        
        // Load mood tags from UserDefaults
        loadMoodTags()
    }
    
    private func loadMoodTags() {
        if let savedMoodData = userDefaults.dictionary(forKey: songsWithMoodKey) as? [String: String] {
            // Update mood tags for songs
            for (songId, mood) in savedMoodData {
                if let index = songs.firstIndex(where: { $0.id == songId }) {
                    var updatedSong = songs[index]
                    updatedSong.moodTag = mood
                    songs[index] = updatedSong
                }
            }
        }
    }
    
    private func loadPlaylists() {
        if let savedData = userDefaults.data(forKey: playlistsKey) {
            do {
                let savedPlaylists = try JSONDecoder().decode([PlaylistData].self, from: savedData)
                
                // Convert PlaylistData to Playlist
                playlists = savedPlaylists.map { playlistData in
                    let playlistSongs = playlistData.songIds.compactMap { songId in
                        return songs.first { $0.id == songId }
                    }
                    return Playlist(id: playlistData.id, name: playlistData.name, songs: playlistSongs)
                }
            } catch {
                print("Error loading playlists: \(error)")
                playlists = []
            }
        } else {
            playlists = []
        }
    }
    
    private func loadDownloadedSongs() {
        // Get downloaded files
        let downloadedFiles = audioFileManager.getDownloadedFiles()
        
        // Create Song objects from files
        downloadedSongs = downloadedFiles.map { Song(fileURL: $0) }
        
        // Load mood tags for downloaded songs
        if let savedMoodData = userDefaults.dictionary(forKey: songsWithMoodKey) as? [String: String] {
            for (songId, mood) in savedMoodData {
                if let index = downloadedSongs.firstIndex(where: { $0.id == songId }) {
                    var updatedSong = downloadedSongs[index]
                    updatedSong.moodTag = mood
                    downloadedSongs[index] = updatedSong
                }
            }
        }
    }
    
    // MARK: - Data Saving
    
    private func savePlaylists() {
        // Convert Playlist to PlaylistData for saving
        let playlistsData = playlists.map { playlist in
            return PlaylistData(
                id: playlist.id,
                name: playlist.name,
                songIds: playlist.songs.map { $0.id }
            )
        }
        
        do {
            let data = try JSONEncoder().encode(playlistsData)
            userDefaults.set(data, forKey: playlistsKey)
        } catch {
            print("Error saving playlists: \(error)")
        }
    }
    
    private func saveMoodTags() {
        // Create dictionary of song IDs to mood tags
        var moodData: [String: String] = [:]
        
        // Add mood tags from all songs
        for song in songs where song.moodTag != nil {
            moodData[song.id] = song.moodTag
        }
        
        // Add mood tags from downloaded songs
        for song in downloadedSongs where song.moodTag != nil {
            moodData[song.id] = song.moodTag
        }
        
        userDefaults.set(moodData, forKey: songsWithMoodKey)
    }
    
    // MARK: - Song Management
    
    func getAllSongs() -> [Song] {
        return songs
    }
    
    func getSongsByAlbum() -> [String: [Song]] {
        var albumDict: [String: [Song]] = [:]
        
        for song in songs {
            if albumDict[song.album] == nil {
                albumDict[song.album] = [song]
            } else {
                albumDict[song.album]?.append(song)
            }
        }
        
        return albumDict
    }
    
    func getAlbums() -> [String] {
        return Array(Set(songs.map { $0.album })).sorted()
    }
    
    func getSongsForAlbum(_ album: String) -> [Song] {
        return songs.filter { $0.album == album }
    }
    
    func searchSongs(query: String) -> [Song] {
        let lowercasedQuery = query.lowercased()
        return songs.filter {
            $0.title.lowercased().contains(lowercasedQuery) ||
            $0.artist.lowercased().contains(lowercasedQuery) ||
            $0.album.lowercased().contains(lowercasedQuery)
        }
    }
    
    // MARK: - Playlist Management
    
    func getAllPlaylists() -> [Playlist] {
        return playlists
    }
    
    func createPlaylist(name: String) -> Playlist {
        let newPlaylist = Playlist(id: UUID().uuidString, name: name, songs: [])
        playlists.append(newPlaylist)
        savePlaylists()
        return newPlaylist
    }
    
    func addSongToPlaylist(song: Song, playlistId: String) {
        if let index = playlists.firstIndex(where: { $0.id == playlistId }) {
            // Check if song is already in playlist
            if !playlists[index].songs.contains(where: { $0.id == song.id }) {
                playlists[index].songs.append(song)
                savePlaylists()
            }
        }
    }
    
    func removeSongFromPlaylist(songId: String, playlistId: String) {
        if let playlistIndex = playlists.firstIndex(where: { $0.id == playlistId }) {
            playlists[playlistIndex].songs.removeAll(where: { $0.id == songId })
            savePlaylists()
        }
    }
    
    // MARK: - Downloads Management
    
    func getDownloadedSongs() -> [Song] {
        return downloadedSongs
    }
    
    func downloadSong(_ song: Song, completion: @escaping (Bool) -> Void) {
        // Check if song is already downloaded
        if downloadedSongs.contains(where: { $0.id == song.id }) {
            completion(true)
            return
        }
        
        audioFileManager.downloadSong(from: song.fileURL) { url, error in
            if let url = url, error == nil {
                // Create a new Song object for the downloaded file
                let downloadedSong = Song(
                    id: song.id,
                    title: song.title,
                    artist: song.artist,
                    album: song.album,
                    duration: song.duration,
                    fileURL: url,
                    albumArt: song.albumArt,
                    moodTag: song.moodTag
                )
                
                self.downloadedSongs.append(downloadedSong)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func removeSongFromDownloads(songId: String) {
        if let index = downloadedSongs.firstIndex(where: { $0.id == songId }) {
            let song = downloadedSongs[index]
            
            // Delete the file
            if audioFileManager.deleteSong(at: song.fileURL) {
                downloadedSongs.remove(at: index)
            }
        }
    }
    
    func updateSongMoodTag(songId: String, moodTag: String) {
        // Update in downloaded songs
        if let index = downloadedSongs.firstIndex(where: { $0.id == songId }) {
            var updatedSong = downloadedSongs[index]
            updatedSong.moodTag = moodTag
            downloadedSongs[index] = updatedSong
        }
        
        // Update in all songs
        if let index = songs.firstIndex(where: { $0.id == songId }) {
            var updatedSong = songs[index]
            updatedSong.moodTag = moodTag
            songs[index] = updatedSong
        }
        
        // Save mood tags
        saveMoodTags()
    }
    
    // MARK: - Recommendations
    
    func getRecommendedSongs(mood: String) -> [Song] {
        // Get songs with matching mood tag
        return songs.filter { $0.moodTag?.lowercased() == mood.lowercased() }
    }
    
    // MARK: - Import Songs
    
    func importSong(from url: URL, completion: @escaping (Song?) -> Void) {
        audioFileManager.importSongToLibrary(from: url) { destinationURL, error in
            if let destinationURL = destinationURL, error == nil {
                // Create a new Song object
                let newSong = Song(fileURL: destinationURL)
                
                // Add to songs array
                self.songs.append(newSong)
                
                completion(newSong)
            } else {
                completion(nil)
            }
        }
    }
}

// Helper struct for saving playlists to UserDefaults
struct PlaylistData: Codable {
    let id: String
    let name: String
    let songIds: [String]
}
