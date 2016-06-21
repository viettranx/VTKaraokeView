//
//  VTKaraokeLyricLabel.swift
//  VTKaraokeView
//
//  Created by Tran Viet on 6/19/16.
//  Copyright © 2016 idea. All rights reserved.
//

import UIKit

protocol VTXKaraokeLyricViewDelegate:class {
    func karaokeLyric(label: VTKaraokeLyricLabel, didStartAnimation: CAAnimation)
    func karaokeLyric(label: VTKaraokeLyricLabel, didStopAnimation: CAAnimation, finished: Bool)
}


final class VTKaraokeLyricLabel: UILabel {
    
    weak var delegate:VTXKaraokeLyricViewDelegate?
    var duration:CGFloat                = 0.25
    
    private var textLayer:CATextLayer   = CATextLayer()
    private let animationKey            = "runLyric"
    
    var isAnimating:Bool {
        return textLayer.speed > 0
    }
    
    var fillTextColor:UIColor? {
        didSet {
            guard let fillTextColor = self.fillTextColor else { return }
            textLayer.foregroundColor = fillTextColor.CGColor
        }
    }
    
    var lyricSegment:Dictionary<CGFloat,String>? {
        didSet {
            
            guard let lyricSegment = self.lyricSegment else { return }
            let sortedKeys = Array(lyricSegment.keys).sort(<)
            
            var fullText = ""
            for k in sortedKeys {
                
                if let segmentStr = lyricSegment[k] {
                    fullText = fullText.stringByAppendingString(segmentStr)
                }
                
            }
            
            self.text = fullText
        }
    }
    
    override var text: String? {
        didSet {
            self.updateLayer()
        }
    }
    
    override var font: UIFont! {
        didSet {
            self.updateLayer()
        }
    }
    
    
    // MARK: Init methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareForLyricLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareForLyricLabel()
    }
    
    func prepareForLyricLabel() {
        textLayer.removeFromSuperlayer()
        
        textLayer = CATextLayer()
        textLayer.frame = self.bounds
        
        self.numberOfLines = 1
        self.clipsToBounds = true
        self.textAlignment = .Left
        self.baselineAdjustment = .AlignBaselines
        
        textLayer.foregroundColor = fillTextColor?.CGColor ?? UIColor.blueColor().CGColor
        
        let textFont = self.font
        textLayer.font      = CGFontCreateWithFontName(textFont.fontName)
        textLayer.fontSize  = textFont.pointSize
        textLayer.string    = self.text
        textLayer.contentsScale = UIScreen.mainScreen().scale
        textLayer.masksToBounds = true
        
        textLayer.anchorPoint   = CGPoint(x: 0, y: 0.5)
        textLayer.frame         = self.bounds
        textLayer.hidden        = true
        self.layer.addSublayer(textLayer)
    }
    
    
    
    // MARK: Animation
    func animationForTextLayer() -> CAKeyframeAnimation {
        textLayer.hidden = false
        
        let textAnim = CAKeyframeAnimation(keyPath: "bounds.size.width")
        textAnim.duration   = CFTimeInterval(self.duration)
        textAnim.values     = valuesFromLyricSegment()
        textAnim.keyTimes   = keyTimesFromLyricSegment()
        textAnim.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
        textAnim.removedOnCompletion   = true
        textAnim.delegate              = self
        
        return textAnim
    }
    
    // MARK: Help methods
    
    func updateLayer() {
        self.sizeToFit()
        self.setNeedsLayout()
        self.prepareForLyricLabel()
    }
    
    
    func valuesFromLyricSegment() -> Array<CGFloat> {
        let layerWidth = textLayer.bounds.size.width
        
        guard let lyricSegment = self.lyricSegment else {
            return [0.0,layerWidth]
        }
        
        var values:Array<CGFloat> = [0.0]
        let sortedKeys = Array(lyricSegment.keys).sort( < )
        
        var val:CGFloat = 0
        for k in sortedKeys {
            let str = lyricSegment[k]!
            let strWidth = str.sizeWithAttributes([NSFontAttributeName:self.font]).width
            val += strWidth
            values.append(val)
        }
        
        return values
    }
    
    
    func keyTimesFromLyricSegment() -> Array<CGFloat> {
        
        guard let lyricSegment = self.lyricSegment else {
            return [0.0, 1.0]
        }
        
        let keyTimes:Array<CGFloat> = [0.0] + Array(lyricSegment.keys).sort( < ) + [1.0]
        return keyTimes
    }
    
    func pauseLayer() {
        let pauseTime = textLayer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        textLayer.speed = 0.0
        textLayer.timeOffset = pauseTime
    }
    
    func resumeLayer() {
        let pauseTime = textLayer.timeOffset
        textLayer.speed = 1.0;
        textLayer.timeOffset = 0.0;
        textLayer.beginTime = 0.0;
        textLayer.beginTime = textLayer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pauseTime
    }
    
    // MARK: Main methods
    
    func startAnimation() {
        guard let _ = textLayer.animationForKey(animationKey) else {
            
            let anim = self.animationForTextLayer()
            textLayer.addAnimation(anim, forKey: animationKey)
            
            return
        }
    }
    
    func pauseAnimation() {
        guard let _ = textLayer.animationForKey(animationKey) else {
            return
        }
        
        self.pauseLayer()
    }
    
    func resumeAnimation() {
        guard let _ = textLayer.animationForKey(animationKey) else {
            return
        }
        
        self.resumeLayer()
    }
    
    func reset() {
        textLayer.removeAnimationForKey(animationKey)
        textLayer.hidden = true
    }
    
    // MARK: Delegate
    
    override func animationDidStart(anim: CAAnimation) {
        self.delegate?.karaokeLyric(self, didStartAnimation: anim)
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.delegate?.karaokeLyric(self, didStopAnimation: anim, finished: flag)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
