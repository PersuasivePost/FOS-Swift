// very much basic code here!!

import Foundation

// String
let myFirstItem: String = "First String"

// reference previously created objects
let myTitle = myFirstItem

print(myTitle)

// boolean = true or false
let mySecondItem: Bool = true
let myThirdItem: Bool = false

let fourthItem = "hii" // let fourthItem = true, then this would set to boolean automatically

// Dwte
let myFirstDate: Date = Date()

print(myFirstDate)

// number can be: double, cgfloat, int, float
// int is whole number
let myFirstNumber: Int = 1
// use double for math
let mySecondNumber: Double = 2.0
// use cgfloat for ui
let myThirdNumber :CGFloat = 3.0

// constants cant change
let a = "he"

// variables can change
var b = "hehe"

// lets check
b = "hii"
// a = "aaa" // this will not work
print(b)

// example
var c = 55.0
print(c)
c = 100
print(c)
c = 2332.343
print(c)
c = 333
print(c)

// end

// if statements
var userIsPremium: Bool = true

if userIsPremium == true {
    print("1 - User is premium")
} 
if userIsPremium {
    print("2 - User is premium")
}
if userIsPremium == false {
    print("3 - User is not premium")
}
if !userIsPremium {
    print("4 - User is not premium")
}

// operations
var a1 = 11
var a2 = 22
var a3 = a1 + a2
print(a3)
//same for all basic operators
a2 += 1 // a2 = a2 + 1
a2 -= 1 // a2 = a2 - 1
a2 *= 1 // a2 = a2 * 1
a2 /= 1 // a2 = a2 / 1
a2 %= 1 // a2 = a2 % 1
print(a2)
//similarly work with <,>,<=,>=,&&,||,==,!=,
//also work with if, else if, else
