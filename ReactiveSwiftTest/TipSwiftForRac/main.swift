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




func magicMethods(file: String = #file, function: String = #function, line: Int = #line)  {
    print("\n file=  \(file), \(function), \(line)")
}

magicMethods()
magicMethods()

