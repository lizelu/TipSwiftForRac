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

