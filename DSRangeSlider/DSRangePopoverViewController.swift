//
//  DSRangePopoverViewController.swift
//  DSRangeSlider
//
//  Created by Deepankar Srivastava on 9/9/17.
//
//

import UIKit

class DSRangePopoverViewController: UIViewController, DSSliderTimeDelegate {

    let sliderStartTimeLabel = UILabel()
    let sliderEndTimeLabel = UILabel()
    
    var sliderStartTime: String = ""
    var sliderStartDate: String = ""
    var sliderEndTime: String = ""
    var sliderEndDate: String = ""
    
    var finalDate: String = ""

    
    let customSlider = DSCustomRangeSlider(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateSliderTimings()

        customSlider.frame = CGRect(x: 90.0, y: 30.0, width: kSliderWidth, height: kSliderHeight)

        sliderStartTimeLabel.frame = CGRect(x: 10, y: 25, width: 60, height: 40)
        sliderStartTimeLabel.numberOfLines = 2
        sliderStartTimeLabel.font = UIFont.systemFont(ofSize: 15)
        sliderStartTimeLabel.textColor = UIColor.black
        sliderStartTimeLabel.textAlignment = NSTextAlignment.center
        
        sliderEndTimeLabel.frame = CGRect(x: 807, y: 25, width: 60, height: 40)
        sliderEndTimeLabel.numberOfLines = 2
        sliderEndTimeLabel.font = UIFont.systemFont(ofSize: 15)
        sliderEndTimeLabel.textColor = UIColor.black
        sliderEndTimeLabel.textAlignment = NSTextAlignment.center
        
        print("\n *** sliderEndTimeLabel *** \n \(sliderEndTimeLabel) \n ")

        view.addSubview(sliderStartTimeLabel)
        view.addSubview(sliderEndTimeLabel)
        
        customSlider.delegate = self
        
        customSlider.trackHighlightTintColor = UIColor.blue
        customSlider.curvaceousness = 1.0
        view.addSubview(customSlider)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func updateSliderTimeLabels(_ timeInterval: Int, startTimeLabel: Bool) {
        
        print("\n *** timeInterval *** \n \(timeInterval) \n ")
        
        // sliderStartTime in hh:mm format
        let hr: Int = Int(sliderStartTime.components(separatedBy: ":")[0])!
        let min: Int = Int(sliderStartTime.components(separatedBy: ":")[1])!
        
        let totalMins = hr * 60 + min + timeInterval
        var finalHrValue: Int = Int(totalMins/60)
        let finalMinsValue: Int = Int (totalMins%60)
        
        if finalHrValue >= 24 {
            finalDate = sliderEndDate
        } else {
            finalDate = sliderStartDate
        }
        
        if finalHrValue > 23 {
            finalHrValue =  finalHrValue%24
        }
        
        let finalHr: String = finalHrValue < 10 ? "0\(finalHrValue)":"\(finalHrValue)"
        let finalMins: String = finalMinsValue < 10 ? "0\(finalMinsValue)":"\(finalMinsValue)"
        
        var finalTime: String = "\(finalHr):\(finalMins)"
        
        if startTimeLabel {
            sliderStartTimeLabel.text = finalDate + " " + finalTime
        } else {
            if timeInterval == 720 {
                finalTime = sliderEndTime
            }
            sliderEndTimeLabel.text = finalDate + " "  + finalTime
        }
        
    }

    func updateSliderTimings() {
        // Sanity Check to avoid crash due to wrong time format 
        if  (sliderStartTimeLabel.text != "" && sliderStartTimeLabel.text?.characters.count == 12)
            &&
            (sliderEndTimeLabel.text != "" && sliderEndTimeLabel.text?.characters.count == 12) {
            sliderStartTime = sliderStartTimeLabel.text!.components(separatedBy: " ")[1]
            sliderStartDate = sliderStartTimeLabel.text!.components(separatedBy: " ")[0]
            
            sliderEndTime = sliderEndTimeLabel.text!.components(separatedBy: " ")[1]
            sliderEndDate = sliderEndTimeLabel.text!.components(separatedBy: " ")[0]
            finalDate = sliderStartDate
        }
    }
    
}
