//
//  HostPartyMainViewController.swift
//  WaveRider
//
//  Created by Nick Barton on 12/30/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import UIKit
import AVFoundation

class HostPartyMainViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {

    //Spotify Stuff
    let kClientID = "49c32ed6a0f74e1f9339ba3c40b8ca15"
    let kClientSecret = "280285cb1fd84f59972ff19e104fb4bf"
    let kRedirectURL = "waverider2017://returnAfterLogin"
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    
    var audioSession = AVAudioSession()
    
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    @IBOutlet weak var partyIDLabel: UILabel!
    @IBOutlet weak var currentSongTitleLabel: UILabel!
    @IBOutlet weak var currentSongArtistLabel: UILabel!
    @IBOutlet weak var currentSongImage: UIImageView!
    
    @IBOutlet weak var leftToVoteLabel: UILabel!
    
    var partyCode:String!
    var currentImage:UIImage?
    
    var isVoting = false
    var votingEnds = NSDate()

    var votingTimer = Timer()
    var hasPlayed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        partyIDLabel.text = partyCode!
        print("Main VDL")
        setup()
        checkSession()
        if session != nil {
            print("Session Validity - \(session.isValid())")
            initializePLayer(authSession: session)
            if self.player != nil{
                //playFirstSong()
            }
            //print("Session Access Token - \(session.accessToken)")
        }else{
            print("Session is nil")
        }
        DataService.instance.nextTrackChanged(forParty: partyCode) { (newURI) in
            //print("Okay it's queueing")
            //Call queueing function
            self.queueNext(uri: newURI)
            
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
        audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        }catch{
            
        }
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let spotifySession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = spotifySession
            
        }else{
            
        }
    }
    
    func initializePLayer(authSession:SPTSession){
        //print(self.player)
        if self.player == nil {
            
            self.player = SPTAudioStreamingController.sharedInstance()
            
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            //print(self.player)
            try! player?.start(withClientId: auth.clientID)
            
            
            self.player!.login(withAccessToken: authSession.accessToken)
            /*print("Player is set up...in theory")
            print(player?.initialized)
            print(player?.loggedIn)
            print(player?.playbackState)*/
        }else{
            print(":( no player set up")
        }
    }
    
    func runTimer() {
        Randomizer.instance.isVoting = true
        votingTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(HostPartyMainViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        //Compare now to end time
        let difference = Int(Randomizer.instance.votingEnds.timeIntervalSince1970 - NSDate().timeIntervalSince1970)
        if (difference>=0){
            leftToVoteLabel.text = "\(difference)"
        }else{
            votingTimer.invalidate()
            Randomizer.instance.isVoting = false
            DataService.instance.changePartyStatus(forParty: partyCode!, status: "Tallying")
            Randomizer.instance.setupNextRound()
        }
        
    }
    
    func queueNext(uri:String){
        let testURI = "spotify:track:0ofbQMrRDsUaVKq2mGLEAb"
        var trackURI = uri
        if trackURI == "" {
            trackURI = testURI
        }
        self.player?.queueSpotifyURI(trackURI, callback: { (err) in
            print("\(trackURI) queued")
        })
    }
    
    func playFirstSong(){
        
        print("Going to play the first song")
        let currentSong = Randomizer.instance.currentSong
        let currentSongURI = currentSong.uri
        
        self.player?.playSpotifyURI(currentSongURI, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error == nil){
                self.loadImage(imageString: currentSong.albumArtworkLarge)
                self.currentSongTitleLabel.text = currentSong.title
                self.currentSongArtistLabel.text = currentSong.artist
                var songDuration = Double(currentSong.duration)/1000
                if (songDuration > 30){
                    songDuration-=30
                }
                let endTime = TimeInterval(songDuration)
                self.votingEnds = NSDate(timeInterval: endTime, since: Date())
                Randomizer.instance.votingEnds = NSDate(timeInterval: endTime, since: Date())
                Randomizer.instance.updateFirebaseForNewRound()
                self.runTimer()
                self.hasPlayed = true
            }else{
                print("Error - \(String(describing: error))")
            }
        })
    }
    
    func playNextSong(){
        print("Going to play the next song")
        let currentSong = Randomizer.instance.currentSong
        //let currentSongURI = currentSong.uri
        
        self.loadImage(imageString: currentSong.albumArtworkLarge)
        self.currentSongTitleLabel.text = currentSong.title
        self.currentSongArtistLabel.text = currentSong.artist
        var songDuration = Double(currentSong.duration)/1000
        if (songDuration > 30){
            songDuration-=30
        }
        let endTime = TimeInterval(songDuration)
        self.votingEnds = NSDate(timeInterval: endTime, since: Date())
        Randomizer.instance.votingEnds = NSDate(timeInterval: endTime, since: Date())
        Randomizer.instance.updateFirebaseForNewRound()
        self.runTimer()
        
//        self.player?.playSpotifyURI(currentSongURI, startingWith: 0, startingWithPosition: 0, callback: { (error) in
//            if (error == nil){
//                self.loadImage(imageString: currentSong.albumArtworkLarge)
//                self.currentSongTitleLabel.text = currentSong.title
//                self.currentSongArtistLabel.text = currentSong.artist
//                var songDuration = Double(currentSong.duration)/1000
//                if (songDuration > 30){
//                    songDuration-=30
//                }
//                let endTime = TimeInterval(songDuration)
//                self.votingEnds = NSDate(timeInterval: endTime, since: Date())
//                Randomizer.instance.votingEnds = NSDate(timeInterval: endTime, since: Date())
//                Randomizer.instance.updateFirebaseForNewRound()
//                self.runTimer()
//
//            }else{
//                print("Error - \(String(describing: error))")
//            }
//        })
    }
    
    func loadImage(imageString:String){
        
        let session = URLSession(configuration: .default)
        let imageURL = URL(string: imageString)
        //creating a dataTask
        let getImageFromUrl = session.dataTask(with: imageURL!) { (data, response, error) in
            
            //if there is any error
            if let e = error {
                //displaying the message
                print("Error Occurred: \(e)")
                
            } else {
                //in case of now error, checking wheather the response is nil or not
                if (response as? HTTPURLResponse) != nil {
                    
                    //checking if the response contains an image
                    if let imageData = data {
                        DispatchQueue.main.async { // Correct
                            //getting the image
                            let image = UIImage(data: imageData)
                            
                            //displaying the image
                            self.currentSongImage.image = image
                        }
                        
                    } else {
                        print("Image file is currupted")
                    }
                } else {
                    print("No response from server")
                }
            }
        }
        
        //starting the download task
        getImageFromUrl.resume()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        print("Callback - Song playing")
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        print("Callback - Switching song")
        Randomizer.instance.nextRound()
        playNextSong()
        
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("Callback - Did login")
        if !hasPlayed{
            playFirstSong()
        }else{
           print("Callback - Did login - it's already played")
        }
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        print("Callback - Did logout")
    }
    
    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) {
        print("Callback - did pop queue")
    }
    func audioStreamingDidReconnect(_ audioStreaming: SPTAudioStreamingController!) {
        print("Callback - Did reconnect")
    }
    func audioStreamingDidDisconnect(_ audioStreaming: SPTAudioStreamingController!) {
        print("Callback - Did disconnect")
    }
    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {
        print("Callback - Did skip to next")
    }
    func audioStreamingDidSkip(toPreviousTrack audioStreaming: SPTAudioStreamingController!) {
        print("Callback - Did skip to previous")
    }
    func audioStreamingDidLosePermission(forPlayback audioStreaming: SPTAudioStreamingController!) {
        print("Callback - Did lose Permission")
    }
    func audioStreamingDidBecomeActivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
        print("Callback - Became active playback device")
    }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("Callback - did receive error")
    }
    func audioStreamingDidBecomeInactivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
        print("Callback - Did become inactive playback device")
    }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) {
        print("Callback - did receive event")
        print(event)
    }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        print("Callback - did change meta")
        print(metadata.description)
    }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print("Callback - did receive message")
    }
    func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController!) {
        print("Callback - Did encounter temporary connection error")
    }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("Callback - did change playback status")
    }
}
