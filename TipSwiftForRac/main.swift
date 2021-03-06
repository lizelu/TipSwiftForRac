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

func testClosureType() {
    class MyClass {
        var des = ""
        
        init(des: String) {
            self.des = des
        }
        
        func add(other: MyClass) -> MyClass {
            return MyClass(des:"add: " + self.des + other.des)
        }
    }
    
    let myClass1 = MyClass(des: "aa ")
    let myClass2 = MyClass(des: "bb")
    let desc = myClass1.add(other: myClass2).des
    print(desc)
    
    print("\n\n")
    //==============================================================================
    
    class MyClassProducer {
        var myClass1: MyClass
        var myClass2: MyClass
        
        init(value1: String, value2: String) {
            myClass1 = MyClass(des: value1)
            myClass2 = MyClass(des: value2)
        }
        
        func add(closure: @escaping (MyClass) -> (MyClass) -> MyClass) ->MyClass {
            return closure(myClass1)(myClass2)
        }
    }
    
    let myProducer1 = MyClassProducer(value1: "cc ", value2: "dd")
    
    let sum01 = myProducer1.add { myclass1 -> (MyClass) -> MyClass in
        return { myclass2 -> MyClass in
            return MyClass(des:"closure：" + myclass1.des + myclass2.des)
        }
    }
    print(sum01.des)
    
    print("\n\n")
    //==============================================================================
    
    let myProducer2 = MyClassProducer(value1: "ee ", value2: "ff")
    
    let sum02 = myProducer2.add(closure: MyClass.add(other:))
    
    print(sum02.des)
    
    print("\n\n")

}




func deferTest() {
    print("a")
    
    defer {
        print("b")
    }
    
    print("c")
    
    defer {
        print("d")
    }
}

//deferTest()

let lock1 = NSLock()
func testLock() {
    lock1.lock()
    
        lock1.lock()
            print("a")
        lock1.unlock()
    
    lock1.unlock()
}
//testLock()  //deadlock


let lock2 = NSRecursiveLock()

func testRecursiveLock() {
    lock2.lock()
    
        lock2.lock()
            print("b")
        lock2.unlock()
    
    lock2.unlock()
}
//testRecursiveLock()


//let lock = NSLock()

let lock = NSRecursiveLock()

func recursiveMethod(value: Int) {
    lock.lock()
        if value > 0 {
            recursiveMethod(value: value-1)
            print("value = \(value)")
            sleep(1)
        }
    lock.unlock()
}

recursiveMethod(value: 10)


