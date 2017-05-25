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

let genericityClassInt = GenericityClass<Int>(v1: 10, v2: 6)
print(genericityClassInt.comparable())

let genericityClassDouble = GenericityClass<Double>(v1: 10.1, v2: 10.10)
print(genericityClassDouble.comparable())
