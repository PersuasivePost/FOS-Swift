import Foundation

var inventory = [String: Int]()

print("Enter 1 to add a new item.")
print("Enter 2 to update an existing item's stock.")
print("Enter 3 to remove an item.")
print("Enter 4 to print all items and their stock quantities.")

let option = Int(readLine()!)!

if option == 1 {
    print("Enter the item name to add:")
    let itemName = readLine()!
    
    if inventory[itemName] != nil {
        print("Item already exists. Cannot overwrite stock.")
    } else {
        print("Enter the stock quantity for \(itemName):")
        let stockQuantity = Int(readLine()!)!
        inventory[itemName] = stockQuantity
        print("\(itemName) added with stock quantity \(stockQuantity).")
    }
} else if option == 2 {
    print("Enter the item name to update:")
    let itemName = readLine()!
    
    if let currentStock = inventory[itemName] {
        print("Current stock for \(itemName): \(currentStock)")
        print("Enter the new stock quantity for \(itemName):")
        let newStockQuantity = Int(readLine()!)!
        inventory[itemName] = newStockQuantity
        print("\(itemName) updated to new stock quantity \(newStockQuantity).")
    } else {
        print("Item not found in inventory.")
    }
} else if option == 3 {
    print("Enter the item name to remove:")
    let itemName = readLine()!
    
    if inventory[itemName] != nil {
        inventory.removeValue(forKey: itemName)
        print("\(itemName) removed from inventory.")
    } else {
        print("Item not found in inventory.")
    }
} else if option == 4 {
    print("Current Inventory:")
    if inventory.isEmpty {
        print("No items in inventory.")
    } else {
        for (item, stock) in inventory {
            print("\(item): \(stock) units")
        }
    }
} else {
    print("Invalid option. Please choose 1, 2, 3, or 4.")
}
