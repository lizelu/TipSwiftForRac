//
//  main.swift
//  TipSwiftForRac
//
//  Created by Mr.LuDashi on 2017/5/25.
//  Copyright © 2017年 ZeluLi. All rights reserved.
//

import Foundation

//泛型
let genericityClass = GenericityClass<String>(v1: "abc", v2: "bcd")
print(genericityClass.comparable())
print(genericityClass.genericityFunc(value: 100))
print(genericityClass.genericityFunc(value: "aaa"))
print(genericityClass.genericityFunc(value: 10.0))
print(genericityClass.genericityFunc(value: ["a", "b"]))


typealias CompareIntType = GenericityClass<Int>

let genericityClassInt = CompareIntType(v1: 10, v2: 6)
print(genericityClassInt.comparable())

print("\n\n")




//枚举关联值
//枚举的关联值
enum MobileLanguage{
    
    case iOS (String, String)
    case Android (String)
    
    //获取IOS的值
    public var iOSValue: (String, String)? {
        if case let .iOS(value1, value2) = self {
            return (value1, value2)
        } else {
            return nil
        }
    }
    
    public var androidValue: String? {
        if case let MobileLanguage.Android(value) = self {
            return value
        } else {
            return nil
        }
    }
}

func == (lhs: MobileLanguage, rhs: MobileLanguage) -> Bool {
    switch (lhs, rhs) {
    case let (.iOS(leftValue1, leftValue2), .iOS(rightValue1, rightValue2)) :
        return leftValue1 == rightValue1 && leftValue2 == rightValue2
    
    case let (.Android(leftValue), .Android(rightValue)) :
        return leftValue == rightValue
        
    default:
        return false
    }
}

var iPhone: MobileLanguage = .iOS("Objective-C", "Swift")
print(iPhone.iOSValue!)

var iPhone2: MobileLanguage = .iOS("Objective-C", "Swift")

print(iPhone == iPhone2)

switch iPhone {
case .iOS(let language1, let language2):
    print("language1 = \(language1), language2 = \(language2)")
    
case .Android(let temp):
    print(temp);
}

//输出结果：language1 = Objective-C, language2 = Swift
