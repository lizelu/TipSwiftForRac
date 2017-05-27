//
//  MobileLanguage.swift
//  TipSwiftForRac
//
//  Created by Mr.LuDashi on 2017/5/27.
//  Copyright © 2017年 ZeluLi. All rights reserved.
//

import Foundation

//枚举关联值
//枚举的关联值
enum MobileLanguage{
    
    case iOS (String, String)
    case Android (String)
    
    //获取iOS关联的值
    public var iOSValue: (String, String)? {
        if case let .iOS(value1, value2) = self {
            return (value1, value2)
        } else {
            return nil
        }
    }
    
    //获取Android关联的值
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
