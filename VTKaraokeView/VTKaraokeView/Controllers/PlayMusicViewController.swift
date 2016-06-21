//
//  PlayMusicViewController.swift
//  VTKaraokeView
//
//  Created by Tran Viet on 6/21/16.
//  Copyright © 2016 idea. All rights reserved.
//

import UIKit
import AVFoundation

class PlayMusicViewController: UIViewController {
    
    var songURL:NSURL?
    var lyric:VTKaraokeLyric?
    private var timingKeys:Array<CGFloat> = [CGFloat]()
    
    private var audioPlayer:AVAudioPlayer?
    private var playerTimer:NSTimer?
    
    @IBOutlet private weak var toogleButton: UIButton!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var lyricPlayer: VTKaraokeLyricPlayerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lyric = self.lyric where self.lyric?.content != nil {
            timingKeys = Array(lyric.content!.keys).sort(<)
        }
        
        self.lyricPlayer.dataSource = self
        self.lyricPlayer.delegate = self
        
        if let songURL = self.songURL {
            audioPlayer = try! AVAudioPlayer(contentsOfURL: songURL)
            audioPlayer?.delegate = self
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        audioPlayer?.prepareToPlay()
        lyricPlayer.prepareToPlay()
        
        self.title = self.lyric?.title
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopAll() {
        playerTimer?.invalidate()
        audioPlayer?.stop()
        lyricPlayer.stop()
    }
    
    func timerStick(timer:NSTimer) {
        
        if let audioPlayer = self.audioPlayer where audioPlayer.playing {
            let value = audioPlayer.currentTime / audioPlayer.duration
            self.slider.value = Float(value)
        }
        
    }
    
    func startTimer() {
        playerTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(timerStick(_:)), userInfo: nil, repeats: true)
    }
    
    @IBAction func tooglePlayStop(sender: UIButton) {
        
        if self.toogleButton.tag == 0 {
        
            audioPlayer?.play()
            lyricPlayer.start()
            self.startTimer()
        
        } else {
            
            if !self.lyricPlayer.isPlaying {
            
                self.lyricPlayer.resume()
                audioPlayer?.play()
                self.startTimer()
                self.toogleButton.setTitle("Pause", forState: .Normal)
            
            } else {
                
                self.lyricPlayer.pause()
                audioPlayer?.pause()
                playerTimer?.invalidate()
                
                self.toogleButton.setTitle("Resume", forState: .Normal)
                
            }
            
        }
        
    }
    
    @IBAction func sliderDidChange(sender: UISlider) {
        
        guard let audioPlayer = self.audioPlayer else { return }
        
        let songDuration = audioPlayer.duration
        let currentTime = NSTimeInterval(sender.value) * songDuration
        
        audioPlayer.currentTime = currentTime
        lyricPlayer.setCurrentTime(currentTime)
    }
    
}



extension PlayMusicViewController: VTLyricPlayerViewDataSource {
    
    func timesForLyricPlayerView(playerView: VTKaraokeLyricPlayerView) -> Array<CGFloat> {
        return timingKeys
    }
    
    func lyricPlayerView(playerView: VTKaraokeLyricPlayerView, atIndex:NSInteger) -> VTKaraokeLyricLabel {
        
        let lyricLabel          = playerView.reuseLyricView()
        lyricLabel.textColor    = UIColor.whiteColor()
        lyricLabel.fillTextColor = UIColor.blueColor()
        lyricLabel.font         = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        
        let key = timingKeys[atIndex]
        
        lyricLabel.text = self.lyric?.content![key]
        return lyricLabel
    }
    
    func lyricPlayerView(playerView: VTKaraokeLyricPlayerView, allowLyricAnimationAtIndex: NSInteger) -> Bool {
        return true
    }
}

extension PlayMusicViewController: VTLyricPlayerViewDelegate {
    func lyricPlayerViewDidStop(playerView: VTKaraokeLyricPlayerView) {
        playerTimer?.invalidate()
    }
    
    func lyricPlayerViewDidStart(playerView: VTKaraokeLyricPlayerView) {
        self.toogleButton.setTitle("Pause", forState: .Normal)
        self.toogleButton.tag = 1
    }
}

extension PlayMusicViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.stopAll()
    }
}
