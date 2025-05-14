import Foundation

struct Person: Codable {
    var name: String
    var age: Int
}

let fileName = "person.json"
let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(fileName)

let person = Person(name: "Harshit Gupta", age: 19 )

if let data = try? JSONEncoder().encode(person) {
    try? data.write(to: fileURL)
    print("JSON file created at: \(fileURL.path)")
}

if let data = try? Data(contentsOf: fileURL),
   let decoded = try? JSONDecoder().decode(Person.self, from: data) {
    print("Name: \(decoded.name)")
    print("Age: \(decoded.age)")
}
