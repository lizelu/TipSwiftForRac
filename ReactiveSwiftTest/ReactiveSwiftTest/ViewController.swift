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
        
        /// 实例化Bags,并指定泛型类型为String
        var myBags = Bag<String>()
        
        /// 用来存储Bag中每个元素的Token的数组
        var bagsTokens = ContiguousArray<RemovalToken>()
        
        //往包中添加值
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
    
    @IBAction func tapSignalTestButton(_ sender: Any) {
        
        var myObserver: Observer<Int, NoError>?

        let mySignal = Signal<Int, NoError> { (innerObserver) -> Disposable? in
            myObserver = innerObserver
            return nil
        }
        
        let subscriber01 = Observer<Int, NoError>(value: { print("Subscriber 01 received \($0)") } )
        let subscriber02 = Observer<Int, NoError>(value: { print("Subscriber 02 received \($0)") } )
        mySignal.observe(subscriber01)
        mySignal.observe(subscriber02)
        
        myObserver?.send(value: 1000)
        
        
        print("\n\n")
        
        let (signal, observer) = Signal<Int, NoError>.pipe()
        
        let subscriber1 = Observer<Int, NoError>(value: { print("Subscriber 1 received \($0)") } )
        let subscriber2 = Observer<Int, NoError>(value: { print("Subscriber 2 received \($0)") } )
        
        let actionDisposable1 = signal.observe(subscriber1)
        observer.send(value: 10)
        
        print("\n")
        signal.observe(subscriber2)
        observer.send(value: 20)
        
        print("\n")
        print(actionDisposable1?.isDisposed ?? "")
        actionDisposable1?.dispose()
        print(actionDisposable1?.isDisposed ?? "")
        observer.send(value: 30)

    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

