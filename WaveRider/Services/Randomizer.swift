//
//  Randomizer.swift
//  WaveRider
//
//  Created by Nick Barton on 12/23/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import Foundation

class Randomizer {
    
    static let instance = Randomizer()
    
    var initialized = false
    var initialPLLength = 0
    
    var playlistSongs = [Song]()
    var playedSongs = [Song]()
    var droppedSongs = [Song]()
    
    var fourVoting = [Song]()
    var nextFour = [Song]()
    
    var currentSong = Song()
    var nextSong = Song()
    
    var randomizerPartyID = ""
    
    var votingEnds = NSDate()
    var isVoting = false
    
    func setup(withPlaylist playlist:[Song]){
    
        playlistSongs = playlist
        playedSongs.removeAll()
        droppedSongs.removeAll()
        fourVoting.removeAll()
        nextFour.removeAll()
        initialPLLength = playlistSongs.count
        
        // TODO: Find the actual minumum number
        if (playlistSongs.count>10){
            
            fourVoting = getFourSongs()
            sendSongsToFirebase()
            initialized = true
            
        }else{
            print("Needs more songs")
        }
        print("Randomizer setup")
    }
    
    func sendSongsToFirebase(){
        let songsForFirebase = ["1":[fourVoting[0].title,fourVoting[0].artist],
                                "2":[fourVoting[1].title,fourVoting[1].artist],
                                "3":[fourVoting[2].title,fourVoting[2].artist],
                                "4":[fourVoting[3].title,fourVoting[3].artist]
        ]
        
        DataService.instance.changeSongs(forParty: randomizerPartyID, songs: songsForFirebase)
    }
    
    func setupNextRound(){
        var songVotes = [0,0,0,0]
        
        DataService.instance.getVotes(forParty: randomizerPartyID) { (votes) in
            
            songVotes = votes
            let max = songVotes.max()
            let indexForPlayerWithMaxScore = songVotes.indices.filter { songVotes[$0] == max }
            let nextSongIndex = Int(arc4random_uniform(UInt32(indexForPlayerWithMaxScore.count)))
            let nextSongValue = indexForPlayerWithMaxScore[nextSongIndex]
            self.nextSong = self.fourVoting[nextSongValue]
            self.fourVoting.remove(at: nextSongValue)
            for droppedSong in self.fourVoting{
                self.droppedSongs.append(droppedSong)
            }
            self.fourVoting = []
            self.nextFour = self.getFourSongs()
            self.nextRoundReady()
        }
        
    }
    
    func nextRoundReady() {
        DataService.instance.nextSong(forParty: randomizerPartyID, track: nextSong.uri)
    }
    
    func nextRound(){
        print("Randomizer - Next Round")
        currentSong = nextSong
        fourVoting = nextFour
        nextFour = []
        sendSongsToFirebase()
        if playlistSongs.count<(initialPLLength/4) {
            shufflebackPlayedSongs()
        }

        shufflebackDroppedSongs()
        
    }
    
    func updateFirebaseForNewRound(){
        
        let songInfo = ["title":currentSong.title,
                        "artist":currentSong.artist,
                        "albumArt":currentSong.albumArtworkLarge]
        
        let songsForVoting = ["1":[fourVoting[0].title,fourVoting[0].artist],
                                "2":[fourVoting[1].title,fourVoting[1].artist],
                                "3":[fourVoting[2].title,fourVoting[2].artist],
                                "4":[fourVoting[3].title,fourVoting[3].artist]
                                ]
        let votes = ["temp":0]
        let roundUpdates = ["currentSong":songInfo,
                            "songs":songsForVoting,
                            "votes":votes,
                            "status":"Voting",
                            "votingEnds":votingEnds.timeIntervalSince1970] as [String : Any]
        DataService.instance.nextRound(forParty: randomizerPartyID, withUpdates: roundUpdates)
    }
    
    func getFourSongs() -> [Song]{
        
        var next = [Song]()
        
        for _ in 0..<4 {
            let randomNum = arc4random_uniform(UInt32(playlistSongs.count))
            let tempSong = playlistSongs[Int(randomNum)]
            next.append(tempSong)
            playlistSongs.remove(at: Int(randomNum))
        }
        
        return next
    }
    
    func shufflebackPlayedSongs(){
        if (playedSongs.count <= 2) {
            print("Not enough songs have been played")
            return
        }
        for _ in 0..<(playedSongs.count/2){ //Shuffle in first half of the played songs
            let tempSong = playedSongs.first!
            playedSongs.removeFirst()
            playlistSongs.append(tempSong)
            
        }
        
    }
    
    func shufflebackDroppedSongs(){
        if (playedSongs.count <= 3) {
            print("Not enough songs have been dropped")
            return
        }
        for _ in 0..<(droppedSongs.count/2){ //Shuffle in first half of the played songs
            let tempSong = droppedSongs.first
            droppedSongs.removeFirst()
            playlistSongs.append(tempSong!)
            
        }
    }
    
    func processRoundVotes(votes:[Int]){
        
        for i in 0..<votes.count{
            if(votes[i]==1){
                playedSongs.append(fourVoting[i])
            }
            else{
                droppedSongs.append(fourVoting[i])
            }
        }
        
    }
    
    func finishRound(){
        initialized = false
    }
    
    func showRandomizer(){
        print("")
        print("Randomizer Info\n\n")
        print("Randomizer is initialized - \(initialized)")
        print("Initial PL Length - \(initialPLLength)")
        print("There are \(playlistSongs.count) songs in the playlist")
        print("There are \(playedSongs.count) songs already played")
        print("There are \(droppedSongs.count) songs that have been dropped")
        print("Four Voting are:")
        for i in 0..<fourVoting.count{
            fourVoting[i].printSong()
        }
        print("Next Four are:")
        for i in 0..<nextFour.count{
            nextFour[i].printSong()
        }
        print("Current Song - ")
        currentSong.printSong()
        print("Next Song - ")
        nextSong.printSong()
        print("")
        
    }
    
    
}
