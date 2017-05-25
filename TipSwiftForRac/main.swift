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



typealias CompareIntType = GenericityClass<Int>

let genericityClassInt = CompareIntType(v1: 10, v2: 6)
print(genericityClassInt.comparable())



//枚举关联值
//枚举的关联值
enum MobileLanguage{
    case IOS (String, String)
    case Android (String)
}

var iPhone: MobileLanguage = .IOS("Objective-C", "Swift")

switch iPhone {
case .IOS(let language1, let language2):
    print("language1 = \(language1), language2 = \(language2)")
    
case .Android(let temp):
    print(temp);
}

//输出结果：language1 = Objective-C, language2 = Swift
