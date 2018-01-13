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
    
    func createParty(roundCode code:String, roundName name:String, roundNotes notes:String, creator user:String, handler: @escaping(_ message:Bool)->()){
        
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
        
        REF_BASE.updateChildValues(childUpdates)
        //Need to handle the status and pass something back to transition viewController if successful
        
        handler(true)
    }
    
    func voterCountForParty(partyCode code:String, handler:@escaping(_ count:Int)->()){
        
        REF_PARTIES.child(code).child("voters").observe(.value) { (snapshot) in
            print("Count = \(snapshot.childrenCount)")
            let count = snapshot.childrenCount
            handler(Int(count))
        }
        
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
