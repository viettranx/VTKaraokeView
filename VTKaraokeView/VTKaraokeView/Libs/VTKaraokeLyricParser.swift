//
//  VTKaraokeLyricParser.swift
//  VTKaraokeView
//
//  Created by Tran Viet on 6/19/16.
//  Copyright © 2016 idea. All rights reserved.
//

import UIKit

protocol VTKaraokeLyricParser {
    //var lyricContent:String? { get set }
    func lyricFromLRCString(lrcStr:String) -> VTKaraokeLyric
}


extension VTKaraokeLyricParser {
    func lyricFromLocalPathFileName(lrcFileName:String) -> VTKaraokeLyric? {
        
        guard let filePath = NSBundle.mainBundle().pathForResource(lrcFileName, ofType: "lrc") else { return nil }
        
        if let lyricContent = try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) {
            return self.lyricFromLRCString(lyricContent)
        }
        
        return nil
    }
    
    func timeStr2Float(strTime: String) -> CGFloat {
        var result:CGFloat = 0
        
        let timeParts = strTime.componentsSeparatedByString(":")
        if timeParts.count > 1 {
            let min = Double(timeParts[0]) ?? 0
            let sec = Double(timeParts[1]) ?? 0
            result = CGFloat(min * 60 + sec)
        }
        
        return result
    }
}



struct VTBasicKaraokeLyricParser:VTKaraokeLyricParser {
    //var lyricContent:String?
    
    func lyricFromLRCString(lrcStr: String) -> VTKaraokeLyric {
        
        let lyricRows = lrcStr.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        var lyricDict:Dictionary<CGFloat,String> = Dictionary<CGFloat,String>()
        
        
        var title:String = "", artist = "", album = "", by = ""
        
        for row in lyricRows {
            
            if row.hasPrefix("[") {
                
                if row.hasPrefix("[ti:") || row.hasPrefix("[ar:") || row.hasPrefix("[al:") || row.hasPrefix("[by:") {
                    
                    let text = row.substringWithRange(
                        row.startIndex.advancedBy(5)...row.endIndex.advancedBy(-2)
                    )
                    
                    switch row.substringWithRange(
                        row.startIndex.advancedBy(1) ... row.startIndex.advancedBy(2)
                    ) {
                        case "ti":
                            title       = text
                        case "ar":
                            artist      = text
                        case "al":
                            album		= text
                        case "by":
                            by		= text
                        default:
                            print("Unknow text")
                    }
                    
                } else {
                    let textParts = row.componentsSeparatedByCharactersInSet( NSCharacterSet(charactersInString:"[]"))
                    let lyricText = textParts[2];
                    let keyTime = self.timeStr2Float(textParts[1])
                    lyricDict[keyTime] = lyricText
                }
            }
        }
        
        var lyric = VTKaraokeLyric(title: title, singer: artist, composer: by, album: album)
        lyric.content = lyricDict
        return lyric
        
    }
}

