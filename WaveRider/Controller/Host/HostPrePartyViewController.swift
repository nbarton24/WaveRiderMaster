//
//  HostPrePartyViewController.swift
//  WaveRider
//
//  Created by Nick Barton on 12/12/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//
// This view controller is responsible for setting up the playlist songs, selecting the first song to play, setting up the randomizer, and counting how many players are in the round waiting for it to start.
//The number of users ready to vote will display in the label, and voting will begin when the host presses the button to begin.

import UIKit

class HostPrePartyViewController: UIViewController {

    @IBOutlet weak var startPartyButton: UIButton!
    @IBOutlet weak var participantCountLabel: UILabel!
    
    let kClientID = "49c32ed6a0f74e1f9339ba3c40b8ca15"
    let kClientSecret = "280285cb1fd84f59972ff19e104fb4bf"
    let kRedirectURL = "waverider2017://returnAfterLogin"
    
    var auth = SPTAuth.defaultInstance()
    var session: SPTSession!
    
    var playlist:Playlist!
    var playlistSongs = [Song]()
    var roundID:String?
    
    var readyToParty = false
    
    var participants = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playlist.printPL()
        checkSession()
        if session != nil {
            if session.isValid() == false{
                //showLogin()
            }
            setupRandomizer()
            
        }else{
            //showLogin()
        }
        
        DataService.instance.voterCountForParty(partyCode: roundID!) { (partyVoters) in
            self.participants = partyVoters
            self.participantCountLabel.text = "\(self.participants)"
        }
    
        if (readyToParty && Randomizer.instance.initialized) {
            //Do the rest
            //DataService.instance.partyReady(forParty: roundID!)
            DataService.instance.changePartyStatus(forParty: roundID!, status: "Ready")
        }else{
            //Retry
        }
        
        // Do any additional setup after loading the view.
    }
    
    func checkSession(){
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let spotifySession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = spotifySession
            //print("Woo Session!")
        }else{
            //print("Nope.")
        }
    }
    
    func setupRandomizer(){
        //TODO: Fetch songs from playlist, add to playlistSongs variable
        var count = 0
        Randomizer.instance.randomizerPartyID = roundID!
        
        //print("Getting songs for \(String(describing: playlist.url))")
        let songsString = "\(playlist.url)/tracks?fields=items(track(uri,name,duration_ms,album(name,images),artists(name)))"
        let urlToSend = URL(string:songsString)
        print(songsString)
        let accessToken = self.session.accessToken
        if let _ = urlToSend, let _ = accessToken{
            
        }else{
            print("Couldn't grab playlist")
            return
        }
        
        let isValid = self.session.isValid()
        print("Session Valid - \(isValid)")
        
        var request = URLRequest(url: urlToSend!)
        request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data,response,err) in
            
            if (err == nil){ //This is good!
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    self.parseJSONForSongs(input: json)
                }catch let error as NSError{
                    print("Error -- \(String(describing:error))")
                }
            }else{
                print("Fetch encountered an error -- \(String(describing: err?.localizedDescription))")
            }
            
            }.resume()

        while !readyToParty {
            count+=1
            //Build in a wait
            if count>10000000000{
                print("Fetch took too long!")
                return
            }else{
                
            }
        }

        if(playlistSongs.count>10){
            //TODO: Find random song as the "First Song"
            let randomNum = Int(arc4random_uniform(UInt32(playlistSongs.count)))
            let firstSong = playlistSongs[randomNum]
            playlistSongs.remove(at: randomNum)
            
            Randomizer.instance.currentSong = firstSong
            Randomizer.instance.setup(withPlaylist: playlistSongs)
        }
        
        
    }
    
    func parseJSONForSongs(input: [String:Any]){
        if let tracks = input["items"] as? [[String:AnyObject]]{
            playlistSongs = []
            for i in 0..<tracks.count{
                let track = tracks[i]["track"] as? [String:Any]
                if let _ = track{
                    let songFromTrack = Song(track: track!)
                    playlistSongs.append(songFromTrack)
                }
            }
        }else{
            print("Could not parse song list")
        }
        readyToParty = true
    }
    
    @IBAction func startPartyButtonPressed(_ sender: Any) {
        
        if(readyToParty && Randomizer.instance.initialized){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let hpmvc = storyboard.instantiateViewController(withIdentifier: "HostPartyMainViewController") as! HostPartyMainViewController
            hpmvc.partyCode = roundID!
            present(hpmvc, animated: true, completion: nil)
        }else{
            print("Something is wrong with the randomizer")
        }
        //Randomizer.instance.showRandomizer()
    }
    
}
