//
//  Playlist.swift
//  WaveRider
//
//  Created by Nick Barton on 12/10/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import Foundation

class Playlist{
    
    var uri = ""
    var url = ""
    var name = ""
    var songCount = 0
    
    init(uri:String,url:String,name:String,count:Int){
        self.uri = uri
        self.url = url
        self.name = name
        self.songCount = count
    }
    
    func printPL(){
        print("This playlist is called '\(self.name)' and has \(self.songCount) songs")
    }
    
}
