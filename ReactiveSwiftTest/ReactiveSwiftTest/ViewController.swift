//
//  ViewController.swift
//  LookReactiveSwift
//
//  Created by Mr.LuDashi on 2017/5/23.
//  Copyright © 2017年 ZeluLi. All rights reserved.
//

import UIKit
import Result
import ReactiveSwift

let MainStorybaord = UIStoryboard(name: "Main", bundle: Bundle.main)

class ViewController: UIViewController {
    
    let observer = Observer<String, NoError>(value: { (str) in
        print(str)
    })
    let property = MutableProperty(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        property.producer.startWithValues { (value) in
            print(value);
        }
        
        testBag()
    }
    
    
    func testBag() {
        var myBags = Bag<String>()
        var bagsTokens = ContiguousArray<RemovalToken>()
        
        for i in 0..<10 {
            let token = myBags.insert("\(i)")
            bagsTokens.append(token)
        }
        
        print("============输出Token对象的Hash值=======")
        for i in bagsTokens.indices.reversed() {
            let identifier = ObjectIdentifier(bagsTokens[i])
            print(identifier.hashValue)
        }
        
        print("============初始化后的myBags=======")
        dump(myBags)
        
        print("通过Token移除元素")
        myBags.remove(using: bagsTokens[0])
        myBags.remove(using: bagsTokens[1])
        myBags.remove(using: bagsTokens[2])
        myBags.remove(using: bagsTokens[3])
        
        //获取StartIndex
        print("startIndex = \(myBags.startIndex)")
        
        //获取EndIndex
        print("endIndex = \(myBags.endIndex)")
        
        //获取Bag容器的迭代器
        var myBagsIterator = myBags.makeIterator()
        while let element = myBagsIterator.next() {
            print(element)
        }
    }
    

    @IBAction func showFirstVC(_ sender: UIButton) {
        let firstVC = MainStorybaord.instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
        firstVC.observer = observer
        self.property <~ firstVC.property   //属性绑定
        self.show(firstVC, sender: nil)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

