//
//  GenericityClass.swift
//  TipSwiftForRac
//
//  Created by Mr.LuDashi on 2017/5/25.
//  Copyright © 2017年 ZeluLi. All rights reserved.
//

import Foundation

protocol GenericityProtocol {
    associatedtype MyType       //关联类型
    func display(value: MyType)
}

//类泛型
class GenericityClass<MyCustomType: Comparable>: GenericityProtocol {
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
    
    //方法中使用泛型
    func genericityFunc<Type>(value: Type) -> Type {
        return value
    }
    
    func display(value: MyCustomType) {
        print(value)
    }

}
