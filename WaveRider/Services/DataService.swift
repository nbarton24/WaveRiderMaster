//
//  DataService.swift
//  WaveRider
//
//  Created by Nick Barton on 12/4/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

let DB_BASE = Database.database().reference()

class DataService {
    
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_PARTIES = DB_BASE.child("parties")
    private var _REF_ROUNDS = DB_BASE.child("rounds")
    private var _REF_SONGS = DB_BASE.child("songs")
    private var _REF_USERS = DB_BASE.child("users")
    //Create a different variable for each "table"
    //private var _REF_SOMETHING = DB_BASE.child("something")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_PARTIES: DatabaseReference {
        return _REF_PARTIES
    }
    
    var REF_ROUNDS: DatabaseReference {
        return _REF_ROUNDS
    }
    
    var REF_SONGS: DatabaseReference {
        return _REF_SONGS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    func checkValidParty(partyCode code:String,handler: @escaping(_ status:Bool)->()){
        
        print("Attempting to join round \(code)")
        
        REF_PARTIES.child(code).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                
                if let status = snapshot.childSnapshot(forPath: "status").value {
                    if(status as! String != "Finished"){
                        handler(true)
                    }else{
                        handler(false)
                    }
                }
            }else{
                handler(false)
            }
        }
        
    }
    
    func connectTo(partyCode code:String,asUser user:String){
        let userInfo = ["isHost":false,
                        "round":code] as [String : Any]
        let childUpdates = ["/parties/\(code)/voters/\(user)":true,
                            "/users/\(user)":userInfo] as [String : Any]
        REF_BASE.updateChildValues(childUpdates)
    }
    
    func castVote(forParty code:String,asUser user:String,withVote vote:Int){
        
        let vote = [user:vote]
        
        REF_PARTIES.child(code).child("votes").updateChildValues(vote)
    }
    
    func createParty(forParty code:String, roundName name:String, roundNotes notes:String, creator user:String, handler: @escaping(_ wasAdded:Bool,_ withMessage:String)->()){
        
        REF_PARTIES.child(code).observeSingleEvent(of: .value){(snapshot) in
            
            if snapshot.exists(){
                /*print("Exists")
                if let partyStatus = snapshot.childSnapshot(forPath: "status").value{
                    print("Status is \(partyStatus)")
                }*/
                handler(false,"Round already exists")
            }else{
                let votes = ["nick":1,
                             "other Nick":1];
                let voters = ["nick":true,
                              "other Nick":true];
                
                let roundInfo = ["diaplayName":name,
                                 "roundNotes":notes,
                                 "host":user,
                                 "status":"setup",
                                 "voters":voters,
                                 "votes":votes] as [String : Any]
                
                let userInfo = ["isHost":true,
                                "round":code] as [String : Any]
                
                let childUpdates = ["/parties/\(code)":roundInfo,
                                    "/users/\(user)":userInfo]
                
                self.REF_BASE.updateChildValues(childUpdates)
                //Need to handle the status and pass something back to transition viewController if successful
                handler(true,"Success!")
            }
        }
        
        
    }
    
    func voterCountForParty(partyCode code:String, handler:@escaping(_ count:Int)->()){
        
        REF_PARTIES.child(code).child("voters").observe(.value) { (snapshot) in
            print("Count = \(snapshot.childrenCount)")
            let count = snapshot.childrenCount
            handler(Int(count))
        }
        
    }
    
    func removeUser(fromParty code:String, userID:String){
        let childUpdates = ["parties/\(code)/voters/\(userID)":"false",
                            "users/\(userID)/round":"",
                            "users/\(userID)/isHost":""]
        REF_BASE.updateChildValues(childUpdates)
    }
    
    func nextTrackChanged(forParty code:String, handler:@escaping(_ trackURI:String)->()){
        REF_PARTIES.child(code).child("nextTrack").observe(.value){ (snapshot) in
            //print("Queueing \(snapshot.value)")
            if let uri = snapshot.value{
                handler(String(describing: uri))
            }else{
                handler("")
            }
        }
    }
    
    func currentSongChanged(forParty code:String, handler:@escaping(_ title:String,_ atrist:String,_ image:String)->()){
        
        REF_PARTIES.child(code).child("currentSong").observe(.value){(snapshot) in
            var songTitle = ""
            var songArtist = ""
            var albumArt = ""
            
            if snapshot.exists(){
                if let title = snapshot.childSnapshot(forPath: "title").value {
                    songTitle = String(describing: title)
                }
                if let artist = snapshot.childSnapshot(forPath: "artist").value {
                    songArtist = String(describing: artist)
                }
                if let image = snapshot.childSnapshot(forPath: "albumArt").value {
                    albumArt = String(describing: image)
                }
            }
            
            handler(songTitle, songArtist, albumArt)
            
        }
    }
    
    func songOptionsChanged(forParty code:String, handler:@escaping(_ songs:[String])->()){
        var returnSongs = ["Song 1","Song 2","Song 3","Song 4"]
        REF_PARTIES.child(code).child("songs").observe(.value){(snapshot) in
            
            if snapshot.exists(){
                if let song1 = snapshot.childSnapshot(forPath: "1/0").value{
                    returnSongs[0] = String(describing:song1)
                }
                if let song2 = snapshot.childSnapshot(forPath: "2/0").value{
                    returnSongs[1] = String(describing:song2)
                }
                if let song3 = snapshot.childSnapshot(forPath: "3/0").value{
                    returnSongs[2] = String(describing:song3)
                }
                if let song4 = snapshot.childSnapshot(forPath: "4/0").value{
                    returnSongs[3] = String(describing:song4)
                }
            }
            handler(returnSongs)
        }
        
    }
    
    func partyStatusChanged(forParty code:String, handler:@escaping(_ roundStatus:String)->()){
        
        REF_PARTIES.child(code).child("status").observe(.value){(snapshot) in
            if snapshot.exists(){
                if let newStatus = snapshot.value {
                    let status = newStatus as! String
                    handler(status)
                }else{
                    handler("UNKNOWN")
                }
            }else{
                handler("UNKNOWN")
            }
        }
        
    }
    
    func votingEndsChanged(forParty code:String, handler:@escaping(_ endTime:Double)->()){
        
        REF_PARTIES.child(code).child("votingEnds").observe(.value){(snapshot) in
            if snapshot.exists(){
                if let ends = snapshot.value {
                    let time = ends as! Double
                    handler(time)
                }else{
                    handler(0.0)
                }
            }else{
                handler(0.0)
            }
        }
        
    }
    
    func partyReady(forParty code:String){
        REF_PARTIES.child(code).child("status").setValue("Ready")
    }
    
    func changePartyStatus(forParty code:String, status:String){
        REF_PARTIES.child(code).child("status").setValue(status)
    }
    
    func enableVoting(forParty code:String, endTime:Double){
        let childUpdates = ["/status":"Voting",
                            "/votingEnds":endTime] as [String : Any]
        REF_PARTIES.child(code).updateChildValues(childUpdates)
        
    }
    
    func changeSongs(forParty code:String,songs:[String:[String]]){
        REF_PARTIES.child(code).child("songs").setValue(songs)
    }
    
    func nextRound(forParty code:String, withUpdates updates:[String:Any]){
        REF_PARTIES.child(code).updateChildValues(updates)
    }
    
    func nextSong(forParty code:String,track uri:String){
        REF_PARTIES.child(code).child("nextTrack").setValue(uri)
    }
    
    func getVotes(forParty code:String, handler:@escaping(_ count:[Int])->()){
        
        var votes = [0,0,0,0]
        
        REF_PARTIES.child(code).child("votes").observeSingleEvent(of: .value) { (rawVotes) in
            //print(rawVotes)
            let enumerator = rawVotes.children
            
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let vote = rest.value as? Int
                if let _ = vote{
                    switch vote!{
                    case 1:
                        votes[0]+=1
                        continue
                    case 2:
                        votes[1]+=1
                        continue
                    case 3:
                        votes[2]+=1
                        continue
                    case 4:
                        votes[3]+=1
                        continue
                    default:
                        continue
                    }
                }
            }
            handler(votes)
        }
        
    }
    
}
