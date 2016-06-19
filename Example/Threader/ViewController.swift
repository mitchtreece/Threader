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
        waitingOverlayView.isHidden = true
        delaySlider.addTarget(self, action: #selector(sliderDidSlide), for: .valueChanged)
                
    }
    
    func sliderDidSlide(sender: UISlider) {
        
        delayInSeconds = Int(sender.value)
        delayLabel.text = "\(delayInSeconds) sec"
        
    }
    
    @IBAction func dispatchAfter() {
        
        waitingOverlayView.isHidden = false
        Threader.DispatchAsyncAfter(.now() + Double(delayInSeconds), .main).execute {
            self.waitingOverlayView.isHidden = true
            self.alert("Threader", "DispatchAsyncAfter")
        }
        
    }
    
    @IBAction func dispatchMain() {

        Threader.DispatchAsyncMain.execute { 
            self.alert("Threader", "DispatchAsyncMain")
        }
        
    }
    
    @IBAction func dispatchQueue() {
        
        Threader.DispatchAsync(.main).execute {
            self.alert("Threader", "DispatchAsync")
        }
        
    }
    
    func alert(_ title: String, _ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

