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
    
    let observerTest = Observer<String, NoError>(value: { (value) in
        print(value)
    }, failed: { (error) in
        print(error)
    }, completed: {
        print("completed")
    }) {
        print("interrupted")
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
        observerTest.send(value: "发送值")
    }
    
    
    @IBAction func tapSendErrorButton(_ sender: Any) {
        observerTest.send(error: NSError(domain: "发送错误", code: 4815, userInfo: nil) as! NoError)
    }

    @IBAction func tapSendCompleted(_ sender: Any) {
        observerTest.sendCompleted()
    }
    
    @IBAction func tapSendInterruptedButton(_ sender: Any) {
        observerTest.sendInterrupted()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
