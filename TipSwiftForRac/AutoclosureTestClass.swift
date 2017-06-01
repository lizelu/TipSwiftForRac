//
//  AutoclosureTestClass.swift
//  TipSwiftForRac
//
//  Created by Mr.LuDashi on 2017/5/27.
//  Copyright © 2017年 ZeluLi. All rights reserved.
//

import Foundation
class AutoclosureTestClass {
    func testMethod(value: () -> Bool ) -> String {
        if value() {
            return "true"
        } else {
            return "false"
        }
    }
    
    func testMethod1(value: @autoclosure () -> Bool) -> String {
        if value() {
            return "true"
        } else {
            return "false"
        }
    }

}
