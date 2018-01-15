//
//  ViewController.swift
//  WaveRider
//
//  Created by Nick Barton on 12/2/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//
//

import UIKit
import SafariServices
import AVFoundation

class ViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {

    //Spotify Stuff
    let kClientID = "49c32ed6a0f74e1f9339ba3c40b8ca15"
    let kClientSecret = "280285cb1fd84f59972ff19e104fb4bf"
    let kRedirectURL = "waverider2017://returnAfterLogin"
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessful"), object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let partyCode = UserDefaults.standard.value(forKey: "lastActiveRound"), let voterType = UserDefaults.standard.value(forKey: "userType"){
            
            let code = String(describing: partyCode)
            switch code {
            case "voter":
                print("You were last in \(partyCode) as a \(voterType)")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let pvvc = storyboard.instantiateViewController(withIdentifier: "PartyVotingViewController") as! PartyVotingViewController
                pvvc.partyCode = String(describing:partyCode)
                present(pvvc, animated: true, completion: nil)
            case "host":
                print("You were last in \(partyCode) as a \(voterType)")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let hpmcv = storyboard.instantiateViewController(withIdentifier: "HostPartyMainViewController") as! HostPartyMainViewController
                hpmcv.partyCode = code
                present(hpmcv, animated: true, completion: nil)
            default:
                print("Invalid value in user defaults")
                
            }
            /*print("You were last in \(partyCode) as a \(voterType)")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let pvvc = storyboard.instantiateViewController(withIdentifier: "PartyVotingViewController") as! PartyVotingViewController
            pvvc.partyCode = String(describing:partyCode)
            present(pvvc, animated: true, completion: nil)*/
        }else{
            
        }
        
        checkSession()
        if session != nil {
            
        }else{
            
        }
        
    }

    func setup() {
        let redirectURL = kRedirectURL
        let clientID = kClientID
        auth.redirectURL = URL(string: redirectURL)
        auth.clientID = clientID
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = auth.spotifyWebAuthenticationURL()
    }
    
    func checkSession(){
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let spotifySession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = spotifySession
            
        }else{
            
        }
    }
    
    func initializePLayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }else{
            print(":( no player set up")
        }
    }
    
    @objc func updateAfterFirstLogin(){
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            
            //initializePLayer(authSession: session)
        
        }else{
            print("Nope.")
        }
        
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController){

        print("Would have played the song")
    }
    
    @IBAction func hostButtonPressed(_ sender: Any) {
        
        let hvc = mainStoryboard.instantiateViewController(withIdentifier: "PartyStartViewController") as! PartyStartViewController
        self.present(hvc, animated: true, completion: nil)
        
    }
    
    @IBAction func guestButtonPressed(_ sender: Any) {
        
        let hvc = mainStoryboard.instantiateViewController(withIdentifier: "JoinPartyViewController") as! JoinPartyViewController
        self.present(hvc, animated: true, completion: nil)
    }
    
    @IBAction func spotifyLoginPressed(_ sender: Any) {
        
        if UIApplication.shared.openURL(loginUrl!){
            if (auth.canHandle(auth.redirectURL)){
                
            }else{
                
            }
        }
        
    }
    

    
}

