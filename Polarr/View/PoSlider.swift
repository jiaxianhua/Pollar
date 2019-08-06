//
//  PoSlider.swift
//  Polarr
//
//  Created by developer on 8/6/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit

class PoSlider: UISlider {
    private var valueLabel:UILabel!

    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        valueLabel = UILabel(frame: CGRect(origin: .zero, size: thumbSize))
        valueLabel.textAlignment = .center
        valueLabel.textColor = valueTextColor
        valueLabel.font = valueTextFont
        
        valueLabel.shadowColor = .darkGray
        valueLabel.shadowOffset = CGSize(width: 0.5, height: 0.5)
        
        self.addSubview(valueLabel)
    }

    var valueTextColor:UIColor = .gray{
        didSet{
            valueLabel.textColor = valueTextColor
        }
    }
    
    var valueTextFont:UIFont = UIFont.systemFont(ofSize: 12){
        didSet{
            valueLabel.font = valueTextFont
        }
    }
    
    private var thumbRect:CGRect{
        let trackRect = self.trackRect(forBounds: self.bounds)
        let thumbRect = self.thumbRect(forBounds: self.bounds, trackRect: trackRect, value: self.value)
        //let rectInView = view.convert(thumbRect, from: slider)
        return thumbRect
    }
    
    private var thumbSize:CGSize{
        return thumbRect.size
    }
    
    private func updateValueLbl(){
        let valueString = String(format: "%.1f", self.value)
        valueLabel.text = "\(valueString)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = thumbRect
        let center = CGPoint(x: rect.midX, y: rect.midY)
        valueLabel.center = center
        updateValueLbl()
        
        self.bringSubviewToFront(valueLabel)
    }
}
