//
//  main.swift
//  TipSwiftForRac
//
//  Created by Mr.LuDashi on 2017/5/25.
//  Copyright © 2017年 ZeluLi. All rights reserved.
//

import Foundation

func testGenericity() {
    //泛型
    let genericityClass = GenericityClass <String> (v1: "abc", v2: "bcd")
    
    print(genericityClass.comparable())
    print(genericityClass.genericityFunc(value: ["a", "b"]))
    
    
    typealias CompareIntType = GenericityClass<Int>
    
    let genericityClassInt = CompareIntType(v1: 10, v2: 6)
    
    print(genericityClassInt.comparable())
    print("\n\n")
    
}
//testGenericity()


func testEnum() {
    let iPhone: MobileLanguage = .iOS("Objective-C", "Swift")
    print(iPhone.iOSValue!)
    
    let iPhone2: MobileLanguage = .iOS("Objective-C", "Swift")
    print(iPhone == iPhone2)
}
//testEnum()


func testMagicMethod() {
    let magic = MagicMethodsClass()
    let str = magic.testMethod(value: "AAA")
    print(str)
}
//testMagicMethod()


func testAutoclosure() {
    let autoClosure = AutoclosureTestClass()
    
    let result1 = autoClosure.testMethod { () -> Bool in
        return 10 > 20
    }
    print(result1)
    
    let result2 = autoClosure.testMethod1(value: 20 > 10)
    print(result2)
    
}
//testAutoclosure()


class SayLove {
    var sound = "I"
    
    var Love: SayLove {
        sound += " ❤️ "
        return self
    }
    
    var You: SayLove {
        sound += "You"
        return self
    }
    
    func ILoveYou() {
        print(sound)
    }
}

let courage = true

let I : SayLove = SayLove()

let IWantToSay = I.Love.You

while courage {
    IWantToSay.ILoveYou()
}



