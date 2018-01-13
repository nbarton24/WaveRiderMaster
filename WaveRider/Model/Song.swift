//
//  Song.swift
//  WaveRider
//
//  Created by Nick Barton on 12/23/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import Foundation

class Song {
    
    var title  = ""
    var uri = ""
    var album = ""
    var albumArtworkLarge = ""
    var albumArtworkSmall = ""
    var artist = ""
    var feats = [String]()
    var duration = 0
    
    init(){
        
    }
    
    init(track:[String:Any]){
        
        //Track URI
        if let uri = (track["uri"] as? String){
            self.uri = uri
        }
        
        if let name = (track["name"] as? String){
            self.title = name
        }
        
        if let length = (track["duration_ms"] as? Int){
            self.duration = length
        }else{
            print("Couldn't convert")
        }
        
        if let album = (track["album"] as? [String:Any]){
            if let albumTitle = (album["name"] as? String){
                self.album = albumTitle
            }
            if let images = (album["images"] as? [[String:Any]]){
                if let image = images[1]["url"] as? String{
                    self.albumArtworkLarge = image
                }
                if let imageSM = images[2]["url"] as? String{
                    self.albumArtworkSmall = imageSM
                }
            }
        }
        
        if let artists = (track["artists"] as? [[String:Any]]){
            for j in 0..<artists.count{
                if let artist = artists[j]["name"] as? String{
                    if (j==0){
                        self.artist = artist
                    }else{
                        self.feats.append(artist)
                    }
                }
            }
        }
        
    }
    
    func printSong(){
        let songString = "\(self.title) by \(self.artist)"
        print(songString)
    }
    
}
