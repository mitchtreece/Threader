//
//  ViewController.swift
//  Threader
//
//  Created by Mitch Treece on 04/26/2016.
//  Copyright (c) 2016 Mitch Treece. All rights reserved.
//

import UIKit
import Threader

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let queue = DispatchQueue.AsyncAfter(5, dispatch_get_main_queue())
        let thread = Thread.Dispatch(queue)
        
        print("s")
        thread.execute {
            print("Hello")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

