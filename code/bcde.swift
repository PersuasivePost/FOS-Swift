// functions and greater versions here

import Foundation

func haha() {
    // print("haha")
    hehe()
    print("haha")
}

func hehe() {
    print("hehe")
}

//haha()
//

func getName() -> String {
    var name = "ace"
    //print(name)
    return name
}

//print(getName())

//

showFirstScreen()

func showFirstScreen() {
    var userDidCompleteOnBoarding = false
    var userProfileIsCreated = true
    let status = checkUserStatus(userDidCompleteOnBoarding: userDidCompleteOnBoarding, userProfileIsCreated: userProfileIsCreated)

    if status == true {
        print("show home screen")
    } 
    else {
        print("show onboarding screen")
    }
}

func checkUserStatus(userDidCompleteOnBoarding: Bool, userProfileIsCreated: Bool) -> Bool {
    if userDidCompleteOnBoarding && userProfileIsCreated {
        doSomethingElse(someValue: userDidCompleteOnBoarding)
        return true
    } else {
        return false
    }
}

func doSomethingElse(someValue: Bool) {

}

let newValue = doSomething()

func doSomething() -> String {
    //var isNew: Bool = false
    var title = "Avengers"

    if title == "Avengers" {
        return "Marvel"
    }
    else {
        return "Not Marvel"
    }
}

// Guards

func doSomethingWithGuard()  {
    var title: String = "Avengers"

    // Guard statement
    guard title == "Avengers" else {
        print("Not Marvel with guards")
        return
    } 

    print("Marvel with guards")
    //return true
}

doSomethingWithGuard()


func doSomethingWithGuard2()  {
    var title: String = "Avengers"

    // if
    if title == "Avengers"{
        print("Marvel with if")
        //return true
    }
    else {
        print("Not Marvel with if")
        //return false
    }
}

doSomethingWithGuard2()