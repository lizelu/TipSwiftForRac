//
//  GenericityClass.swift
//  TipSwiftForRac
//
//  Created by Mr.LuDashi on 2017/5/25.
//  Copyright © 2017年 ZeluLi. All rights reserved.
//

import Foundation
class GenericityClass<MyCustomType: Comparable> {

    var value1: MyCustomType
    var value2: MyCustomType
    
    init(v1: MyCustomType, v2: MyCustomType) {
        self.value1 = v1
        self.value2 = v2
    }
    
    func comparable() -> String {
        if self.value1 > self.value2 {
            return "\(self.value1) > \(self.value2)"
        }
        
        if self.value1 < self.value2 {
            return "\(self.value1) < \(self.value2)"
        }
        return "\(self.value1) = \(self.value2)"
    }
}
