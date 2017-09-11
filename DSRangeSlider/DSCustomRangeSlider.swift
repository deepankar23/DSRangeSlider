//
//  DSCustomRangeSlider.swift
//  DSRangeSlider
//
//  Created by deepankar srivastava on 01/18/16.
//  Copyright © 2016 Apple. All rights reserved.


import UIKit

import QuartzCore

//=============================================================================
// MARK: - Slider Track Layer

class RangeSliderTrackLayer: CALayer {
    weak var rangeSlider: DSCustomRangeSlider?

    override func draw(in ctx: CGContext) {
        if let slider = rangeSlider {
            // Clip
            let cornerRadius = CGFloat(1.0)
            let trackRect = CGRect(x: bounds.origin.x + rangeSlider!.thumbWidth/2, y: bounds.origin.y+5, width: bounds.width - rangeSlider!.thumbWidth, height: 1.0)
            let path = UIBezierPath(roundedRect: trackRect, cornerRadius: cornerRadius)
            ctx.addPath(path.cgPath)

            // Fill the track
            ctx.setFillColor(slider.trackTintColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()

            // Fill the highlighted range
            ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
            let lowerValuePosition = CGFloat(slider.positionForValue(slider.lowerValue))
            let upperValuePosition = CGFloat(slider.positionForValue(slider.upperValue))

            let rect = CGRect(x: lowerValuePosition, y: trackRect.origin.y, width: upperValuePosition-lowerValuePosition, height:trackRect.size.height)

            ctx.fill(rect)
        }
    }
}

//=============================================================================
// MARK: - Slider Thumb Layer

class RangeSliderThumbLayer: CALayer {
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var rangeSlider: DSCustomRangeSlider?

    override func draw(in ctx: CGContext) {
        if let slider = rangeSlider {
            let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
            let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)

            // Fill
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()

            // Outline
            let strokeColor = UIColor.gray
            ctx.setStrokeColor(strokeColor.cgColor)
            ctx.setLineWidth(0.5)
            ctx.addPath(thumbPath.cgPath)
            ctx.strokePath()

            if highlighted {
                ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
                ctx.addPath(thumbPath.cgPath)
                ctx.fillPath()
            }
        }
    }
}

// MARK: - Custom Slider Protocol
protocol DSSliderTimeDelegate : class {
    func updateSliderTimeLabels(_ timeInterval: Int, startTimeLabel: Bool)

}

//=============================================================================// MARK: - Custom Range Slider

class DSCustomRangeSlider: UIControl {

   weak var delegate: DSSliderTimeDelegate?

    var minimumValue: Double = 0.0 {
        willSet(newValue) {
            assert(newValue < maximumValue, "RangeSlider: minimumValue should be lower than maximumValue")
        }
        didSet {
            updateLayerFrames()
        }
    }

    var maximumValue: Double = 702.0 {
        willSet(newValue) {
            assert(newValue > minimumValue, "RangeSlider: maximumValue should be greater than minimumValue")
        }
        didSet {
            updateLayerFrames()
        }
    }

    var lowerValue: Double = 0.0 {
        didSet {
            if lowerValue < minimumValue {
                lowerValue = minimumValue
            }
            updateLayerFrames()
        }
    }

    var upperValue: Double = 702.0 {
        didSet {
            if upperValue > maximumValue {
                upperValue = maximumValue
            }
            updateLayerFrames()
        }
    }

    var gapBetweenThumbs: Double {
        return 30.0  //Double(thumbWidth/2)*(maximumValue - minimumValue) / Double(bounds.width)
    }

    var trackTintColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    var trackHighlightTintColor = UIColor.blue {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    var thumbTintColor = UIColor.white {
        didSet {
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }

    var curvaceousness: CGFloat = 1.0 {
        didSet {
            if curvaceousness < 0.0 {
                curvaceousness = 0.0
            }

            if curvaceousness > 1.0 {
                curvaceousness = 1.0
            }

            trackLayer.setNeedsDisplay()
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }

    fileprivate var previouslocation = CGPoint()

    fileprivate let trackLayer = RangeSliderTrackLayer()
    fileprivate let lowerThumbLayer = RangeSliderThumbLayer()
    fileprivate let upperThumbLayer = RangeSliderThumbLayer()
    fileprivate var lowerThumbCenter: CGFloat = 0.0
    fileprivate var upperThumbCenter: CGFloat = 0.0

    fileprivate var lowerThumbEndPoint: CGFloat = 0.0
    fileprivate var upperThumbStartPoint: CGFloat = 0.0

    fileprivate var nearestLeftEndPoint: Int = 0
    fileprivate var nearestRightEndPoint: Int = 0

    fileprivate var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }

    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initializeLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    fileprivate func initializeLayers() {
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)

        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerThumbLayer)

        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperThumbLayer)

        updateLayerFrames()
    }

    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height/3)
        trackLayer.setNeedsDisplay()

        lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        lowerThumbEndPoint = lowerThumbCenter + 15

        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth/2, y: 0.0, width: thumbWidth, height: thumbWidth)

        lowerThumbLayer.setNeedsDisplay()

        upperThumbCenter = CGFloat(positionForValue(upperValue))
        upperThumbStartPoint = upperThumbCenter - 15

        upperThumbLayer.frame = CGRect(x: upperThumbStartPoint, y: 0.0, width: thumbWidth, height: thumbWidth)

        upperThumbLayer.setNeedsDisplay()

        CATransaction.commit()
    }

    func positionForValue(_ value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }

    func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }

    //=============================================================================
    // MARK: - Touches Delegate Methods

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previouslocation = touch.location(in: self)

        if lowerThumbLayer.frame.contains(previouslocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previouslocation) {
            upperThumbLayer.highlighted = true
        }

        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)

        // Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previouslocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)

        previouslocation = location

        // Update the values
        if lowerThumbLayer.highlighted {
            lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gapBetweenThumbs)
        } else if upperThumbLayer.highlighted {
            upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gapBetweenThumbs, upperValue: maximumValue)
        }

        //Update Time Labels on every 15 mins drag
        self.updateTimeOnContinuousDrag()

        sendActions(for: .valueChanged)

        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {

        let location = touch!.location(in: self)

        // Update Time Labels on every 15 mins drag
        self.updateTimeOnContinuousDrag()

        // Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previouslocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)

        // Update the values
        if lowerThumbLayer.highlighted {
            lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gapBetweenThumbs)
        } else if upperThumbLayer.highlighted {
            upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gapBetweenThumbs, upperValue: maximumValue)
        }

        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }

    //=============================================================================
    // MARK: - 15 mins Interval Time Update
    func updateTimeOnContinuousDrag() {

        var endMinuts: Int = 0

        if let delegate = self.delegate {
            if lowerThumbLayer.highlighted {

                if  lowerThumbEndPoint == thumbWidth {
                    nearestLeftEndPoint = 0
                } else if lowerThumbEndPoint == CGFloat(maximumValue - 15.0) {
                    nearestLeftEndPoint = 672
                } else if lowerThumbEndPoint.truncatingRemainder(dividingBy: 14) < 7 {
                    nearestLeftEndPoint = 14 * (Int)((lowerThumbEndPoint - 14) / 14)
                } else {
                    nearestLeftEndPoint = 14 * ((Int)((lowerThumbEndPoint - 14) / 14) + 1)
                }

                // If nearest left & right endPoints are same, the labels would be updated with same time...
                if nearestLeftEndPoint == nearestRightEndPoint {
                    nearestLeftEndPoint -= 14
                }

                endMinuts = Int((nearestLeftEndPoint / 14) * 15)
                delegate.updateSliderTimeLabels(endMinuts, startTimeLabel: true)
            } else {

                if upperThumbStartPoint == CGFloat(maximumValue - 30.0) {
                    nearestRightEndPoint = 672
                } else if (upperThumbStartPoint.truncatingRemainder(dividingBy: 14)) < 7 {
                    nearestRightEndPoint = 14 * (Int)( upperThumbStartPoint / 14)
                } else {
                    nearestRightEndPoint = 14 * (Int)(( upperThumbStartPoint / 14) + 1)
                }

                // When right thumb is at min diff from left thumb & left thumb is at leftmost position
                if nearestRightEndPoint == 28 {
                    nearestRightEndPoint = 14
                }

                // If nearest left & right endPoints are same, the labels would be updated with same time...
                if nearestRightEndPoint == nearestLeftEndPoint {
                    nearestRightEndPoint += 14
                }

                endMinuts = Int((nearestRightEndPoint / 14) * 15)
                delegate.updateSliderTimeLabels(endMinuts, startTimeLabel: false)
            }
        }
    }
}
