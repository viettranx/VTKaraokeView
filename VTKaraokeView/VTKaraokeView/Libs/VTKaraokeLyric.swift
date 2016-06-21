//
//  VTKaraokeLyric.swift
//  VTKaraokeView
//
//  Created by Tran Viet on 6/19/16.
//  Copyright © 2016 idea. All rights reserved.
//

import UIKit

struct VTKaraokeLyric {
    var title:String
    var singer:String
    var composer:String
    var album:String
    var content:Dictionary<CGFloat,String>?
    
    init(title:String, singer:String, composer:String, album:String) {
        self.title      = title
        self.singer     = singer
        self.composer   = composer
        self.album      = album
    }
}