//
//  DynamicMaskSegmentSwitch.swift
//  DynamicMaskSegmentSwitch
//
//  Created by Kitten x iDaily on 16/5/13.
//  Copyright © 2016年 KittenYang. All rights reserved.
//

import UIKit

class RoundedLayer: CALayer {
    
    override var bounds: CGRect {
        didSet { cornerRadius = bounds.height / 2.0 }
    }
    
}

struct DynamicMaskSegmentSwitchConfigure {
    
    var highlightedColor : UIColor
    var normalColor : UIColor
    var items: [String]
    
}

class DynamicMaskSegmentSwitch: UIView {
    
    var configure: DynamicMaskSegmentSwitchConfigure!
    private let marginInset: CGFloat = 2.0
    private var count: Int {
        set{ self.count = newValue }
        get{ return self.configure.items.count }
    }
    private var eachItemWidth: CGFloat {
        return self.bounds.width / CGFloat(count)
    }
    
    private(set) var indicator = UIView()
    private var selectedLabelsBaseView = UIView()
    private var selectedLabelsMaskView = UIView()
    
    init(frame: CGRect, configure: DynamicMaskSegmentSwitchConfigure) {
        super.init(frame: frame)
        self.configure = configure
        initialViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(self, forKeyPath: "indicator.frame")
    }
    
    override internal class func layerClass() -> AnyClass {
        return RoundedLayer.self
    }
    
    func switchToItem(index: Int) {
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [.BeginFromCurrentState, .CurveEaseInOut], animations: {
            self.indicator.frame.origin = CGPoint(x: self.marginInset + CGFloat(index)*self.eachItemWidth, y: self.marginInset)
            }, completion: nil)
    }
    
}

/// private
extension DynamicMaskSegmentSwitch {
    
    private func initialViews() {
        backgroundColor = configure.highlightedColor
        
        for i in 0..<count {
            let item = configure.items[i]
            let unselectedLabel = UILabel()
            unselectedLabel.frame = CGRect(x: eachItemWidth*CGFloat(i), y: 0, width: eachItemWidth, height: bounds.height)
            unselectedLabel.text = item
            unselectedLabel.textColor = configure.normalColor
            unselectedLabel.textAlignment = .Center
            addSubview(unselectedLabel)
        }
        
        object_setClass(indicator.layer, RoundedLayer.self)
        indicator.frame = CGRect(x: marginInset, y: marginInset, width: eachItemWidth - marginInset*2, height: bounds.height - marginInset*2)
        indicator.backgroundColor = configure.normalColor
        addSubview(indicator)
        addObserver(self, forKeyPath: "indicator.frame", options: .New, context: nil)
        
        object_setClass(selectedLabelsMaskView.layer, RoundedLayer.self)
        selectedLabelsMaskView.backgroundColor = .blackColor()
        
        selectedLabelsBaseView.frame = bounds
        selectedLabelsBaseView.layer.mask = selectedLabelsMaskView.layer
        selectedLabelsMaskView.frame = indicator.frame
        addSubview(selectedLabelsBaseView)
        
        for i in 0..<count {
            let item = configure.items[i]
            let selectedLabel = UILabel()
            selectedLabel.frame = CGRect(x: eachItemWidth*CGFloat(i), y: 0, width: eachItemWidth, height: bounds.height)
            selectedLabel.text = item
            selectedLabel.textColor = configure.highlightedColor
            selectedLabel.textAlignment = .Center
            selectedLabelsBaseView.addSubview(selectedLabel)
        }
        
        // Gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DynamicMaskSegmentSwitch.handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
        
    }
    
    /// gesture actions
    @objc private func handleTapGesture(gesture: UITapGestureRecognizer) {
        let location = gesture.locationInView(self)
        let index = Int(floor(location.x / eachItemWidth))
        switchToItem(index)
    }
    
}

/// KVO
extension DynamicMaskSegmentSwitch {
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "indicator.frame" {
            selectedLabelsMaskView.frame = indicator.frame
        }
    }
    
}
