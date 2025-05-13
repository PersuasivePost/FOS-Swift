import Foundation

var songnames: [String] = ["Migrane", "Fake Plastic Trees", "Cancer"]

print("Enter 0 to add a song")
let input = Int(readLine()!)!
if input == 0 {
    print("Enter song to append:")
    let addition = readLine()!
    songnames.append(addition)
}

print("Enter 1 to remove a song")
let input2 = Int(readLine()!)!
if input2 == 1 {
    print("Enter song to remove:")
    let removal = readLine()!
    if let index = songnames.firstIndex(of: removal) {
        songnames.remove(at: index)
    } else {
        print("Song not found.")
    }
}

print("Enter 2 to sort and display songs")
let input3 = Int(readLine()!)!
if input3 == 2 {
    songnames.sort()
    print(songnames)
}
