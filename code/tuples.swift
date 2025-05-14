// tuples

import Foundation

var userName: String = "Hello"
var userIsPremium: Bool = false
var userIsNew: Bool = true

func getUserName() -> String {
    // return userName
    userName
}

func getUserIsPremium() -> Bool {
    // return userIsPremium
    userIsPremium
}

// limited to 1 return type
func getUserInfo() -> String {
    let name = getUserName()
    let isPremium = getUserIsPremium()

    // do something with both
    return name
}

// tuple can combine multiple return types
func getUserInfo2() -> (String, Bool) {
    let name = getUserName()
    let isPremium = getUserIsPremium()

    // do something with both
    return (name, isPremium)
}

var userData1: String = userName
var userData2: (String, Bool, Bool) = (userName, userIsPremium, userIsNew)

let info1 = getUserInfo2()
// let name1 = info1.0
// let name2 = info1.1

func getUserInfo3() -> (name: String, isPremium: Bool) {
    let name = getUserName()
    let isPremium = getUserIsPremium()

    // do something with both
    return (name, isPremium)
}

let info2 = getUserInfo3()
let name3 = info2.isPremium

func getUserInfo4() -> (name: String, isPremium: Bool, isNew: Bool) {
    return (userName, userIsPremium, userIsNew)
}

func doSomethingWithUserInfo(info: (name: String, isPremium: Bool, isNew: Bool)) {

}

let info = getUserInfo4()
doSomethingWithUserInfo(info: info)