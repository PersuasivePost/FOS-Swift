import Foundation

print("Enter the name of Product 1:")
let name1 = readLine()!
print("Enter the price of Product 1:")
let price1 = Double(readLine()!)!
print("Enter the rating of Product 1:")
let rating1 = Double(readLine()!)!

print("Enter the name of Product 2:")
let name2 = readLine()!
print("Enter the price of Product 2:")
let price2 = Double(readLine()!)!
print("Enter the rating of Product 2:")
let rating2 = Double(readLine()!)!

print("Enter the name of Product 3:")
let name3 = readLine()!
print("Enter the price of Product 3:")
let price3 = Double(readLine()!)!
print("Enter the rating of Product 3:")
let rating3 = Double(readLine()!)!

let product1 = (name1, price1, rating1)
let product2 = (name2, price2, rating2)
let product3 = (name3, price3, rating3)

let products = [product1, product2, product3]

let mostExpensiveProduct = products.max { $0.1 < $1.1 }
let highestRatedProduct = products.max { $0.2 < $1.2 }

print("Enter price threshold:")
let priceThreshold = Double(readLine()!)!
let productUnderThreshold = products.first { $0.1 < priceThreshold }

if let expensive = mostExpensiveProduct {
    print("Most Expensive Product: \(expensive.0), Price: ₹\(expensive.1), Rating: \(expensive.2)")
}

if let highestRated = highestRatedProduct {
    print("Highest Rated Product: \(highestRated.0), Price: ₹\(highestRated.1), Rating: \(highestRated.2)")
}

if let product = productUnderThreshold {
    print("Product Below ₹\(priceThreshold): \(product.0), Price: ₹\(product.1), Rating: \(product.2)")
} else {
    print("No products found under the given price threshold.")
}
