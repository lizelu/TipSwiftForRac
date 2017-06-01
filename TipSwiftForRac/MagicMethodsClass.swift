//
//  MagicMethodsClass.swift
//  TipSwiftForRac
//
//  Created by Mr.LuDashi on 2017/5/27.
//  Copyright © 2017年 ZeluLi. All rights reserved.
//

import Foundation
class MagicMethodsClass {
    
    func testMethod(value: String) -> String {
        self.magicMethods()
        return "value = \(value)"
    }
    
    func magicMethods(file: String = #file,
                      function: String = #function,
                      column: Int = #column,
                      line: Int = #line)  {
        print("file=  \(file), \(function), \(column),\(line) \n")
    }
}
