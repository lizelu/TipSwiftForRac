//
//  FirstViewController.swift
//  LookReactiveSwift
//
//  Created by Mr.LuDashi on 2017/5/24.
//  Copyright © 2017年 ZeluLi. All rights reserved.
//

import UIKit
import Result
import ReactiveSwift

class FirstViewController: UIViewController {
    
    let property = MutableProperty(0)
    
    var observer: Observer<String, NoError>!
    
    var producer: SignalProducer<String, NoError>!
    
    let producerForProperty = SignalProducer<String, NoError> {observer, _ in
        observer.send(value: "属性值")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        weak var weak_self = self
        producer = SignalProducer<String, NoError> {observer, _ in
            observer.send(value: "发送消息\((weak_self?.property.value)!)")
        }
    }
    
    @IBAction func tapSendMessageButton(_ sender: UIButton) {
        property.value += 1
        producerForProperty.start()
        producer.start(observer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        print("deinit")
    }
}
