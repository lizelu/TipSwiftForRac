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
    
    
    @IBAction func tapEvent(_ sender: Any) {
        let event: Event<Int, NSError> = .value(100)
        print("event.isTerminating = \(event.isTerminating)")
        print("event.isCompleted = \(event.isCompleted)")
        print("event = \(event) && event.event = \(event.event)")
        
        //映射
        let mapEvent: Event<String, NSError> = event.map { value -> String in
            return "\(value)"
        }
        print(mapEvent.value!)
        
    }
    
    @IBAction func tapEventErrorMap(_ sender: Any) {
        
        class MyError: Error {
            func display() -> String {
                return "MyError: error message"
            }
        }
        
        class MyError1: Error {
            var message: String
            init(message: String) {
                self.message = message
            }
            func display() -> String {
                return message + " MyError1 error message"
            }
        }
        
        let errorEvent: Event<Int, MyError> = .failed(MyError())
        print(errorEvent.error!.display())
        
        let mapErrorEvent: Event<Int, MyError1> = errorEvent.mapError { (error) -> MyError1 in
            return MyError1(message: error.display())
        }
        print(mapErrorEvent.error!.display())
    }
}
