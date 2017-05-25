//
//  ObseverTestViewController.swift
//  LookReactiveSwift
//
//  Created by Mr.LuDashi on 2017/5/25.
//  Copyright © 2017年 ZeluLi. All rights reserved.
//

import UIKit

import Result
import ReactiveSwift

class ObseverTestViewController: UIViewController {
    
    
    /// 调用便利构造器，通过闭包回调出发送的值
    let observer = Observer<String, NSError>(value: { (value) in
        print(value)
    }, failed: { (error) in
        print(error)
    }, completed: {
        print("observer-完成事件")
    }) {
        print("observer-中断事件")
    }
    
    
    
    /// 直接调用构造器，给Action闭包赋值
    let observer01 = Observer<String, NSError> { event in
        switch event {
        case let .value(v):
            print(v)
            
        case let .failed(error):
            print("错误事件\(error)")
            
        case .completed:
            print("observer01-完成事件")
            
        case .interrupted:
            print("observer01-中断事件")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapSentValueButton(_ sender: Any) {
        observer.send(value: "observer: 发送值")
        observer01.send(value: "observer01: 发送值")
        print("\n")
    }
    
    
    @IBAction func tapSendErrorButton(_ sender: Any) {
        observer.send(error: NSError(domain: "发送错误", code: 98764, userInfo: ["userInfo":"value"]))

        observer01.send(error: NSError(domain: "observer01：发送错误", code: 98764, userInfo: ["userInfo":"value"]))
        print("\n")
    }

    @IBAction func tapSendCompleted(_ sender: Any) {
        observer.sendCompleted()

        observer01.sendCompleted()
        print("\n")
    }
    
    @IBAction func tapSendInterruptedButton(_ sender: Any) {
        observer.sendInterrupted()
        
        observer01.sendInterrupted()
        print("\n")
    }
}
