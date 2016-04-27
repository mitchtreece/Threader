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

    @IBOutlet weak var delaySlider: UISlider!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var waitingOverlayView: UIView!
    
    var delayInSeconds: Int = 2
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        waitingOverlayView.hidden = true
        delaySlider.addTarget(self, action: #selector(sliderDidSlide(_:)), forControlEvents: .ValueChanged)
                
    }
    
    func sliderDidSlide(sender: UISlider) {
        
        delayInSeconds = Int(sender.value)
        delayLabel.text = "\(delayInSeconds) sec"
        
    }
    
    @IBAction func dispatchAfter() {
        
        waitingOverlayView.hidden = false
        Thread.Dispatch(.AsyncAfter(Double(delayInSeconds), DispatchQueue.mainQueue())).execute {
            self.waitingOverlayView.hidden = true
            self.alert("Thread", "Thread.Dispatch(.AsyncAfter)")
        }
        
    }
    
    @IBAction func dispatchMain() {
        
        Thread.Dispatch(.AsyncMain).execute {
            self.alert("Thread", "Thread.Dispatch(.AsyncMain)")
        }
        
    }
    
    @IBAction func dispatchQueue() {
        
        DispatchQueue.Async(DispatchQueue.mainQueue()).execute {
            self.alert("DispatchQueue", "DispatchQueue.Async")
        }
        
    }
    
    func alert(title: String, _ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

