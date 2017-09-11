//
//  ViewController.swift
//  DSRangeSlider
//
//  Created by Deepankar Srivastava on 9/9/17.
//
//

import UIKit

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    //MARK:- IB-Outlets
    @IBOutlet weak var hitButton: UIButton!
    
    //MARK:- Gloabl Variables
    let customSlider = DSCustomRangeSlider(frame: CGRect.zero)

    //MARK:- ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == DSRangePopoverSegueIdentifer{
        
            let popverVC = segue.destination as! DSRangePopoverViewController
            
            popverVC.popoverPresentationController!.delegate = self
            popverVC.preferredContentSize = CGSize(width: kCustomPopoverWidth, height: kCustomPopoverHeight)
            popverVC.popoverPresentationController?.sourceView = self.hitButton as UIButton
            popverVC.popoverPresentationController?.sourceRect = (self.hitButton as UIButton).bounds
            popverVC.sliderStartTimeLabel.text = "02-JUN 16:15"
            popverVC.sliderEndTimeLabel.text = "03-JUN 04:20"
        }
    }

}

