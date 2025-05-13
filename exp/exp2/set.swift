
import Foundation

print("Enter the names of attendees for Workshop A (comma-separated):")
let workshopAInput = readLine()!
let workshopA = Set(workshopAInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })

print("Enter the names of attendees for Workshop B (comma-separated):")
let workshopBInput = readLine()!
let workshopB = Set(workshopBInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })

let bothWorkshops = workshopA.intersection(workshopB)
let onlyOneWorkshop = workshopA.symmetricDifference(workshopB)
let allAttendees = workshopA.union(workshopB)

print("Attendees who attended both workshops: \(bothWorkshops)")
print("Attendees who attended only one workshop: \(onlyOneWorkshop)")
print("All unique attendees: \(allAttendees)")
