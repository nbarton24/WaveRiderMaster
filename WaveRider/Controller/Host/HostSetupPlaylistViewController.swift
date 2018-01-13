//
//  HostSetupPlaylistViewController.swift
//  WaveRider
//
//  Created by Nick Barton on 12/10/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import UIKit

class HostSetupPlaylistViewController: UIViewController {

    @IBOutlet weak var playlistTable: UITableView!
    @IBOutlet weak var selectPLButton: UIButton!
    
    let kClientID = "49c32ed6a0f74e1f9339ba3c40b8ca15"
    let kClientSecret = "280285cb1fd84f59972ff19e104fb4bf"
    let kRedirectURL = "waverider2017://returnAfterLogin"
    
    var auth = SPTAuth.defaultInstance()
    var session: SPTSession!
    
    var spotPlaylists = [Playlist]()
    var finishedLoadingPlaylists = false
    
    var roundID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playlistTable.delegate = self
        playlistTable.dataSource = self
        checkSession()
        if session != nil {
            if session.isValid() == false{
                showLogin()
            }
            setupPlaylists()
            repeat{
                //
            }while !finishedLoadingPlaylists
            
            playlistTable.reloadData()

        }else{
            showLogin()
        }
        // Do any additional setup after loading the view.
    }
    
    func showLogin(){
        
    }
    
    func setupPlaylists(){
        let urlString = "https://api.spotify.com/v1/users/npbarton33/playlists"
        let urlToSend = URL(string:urlString)
        let accessToken = self.session.accessToken
        if let _ = urlToSend, let _ = accessToken{
            
        }else{
            print("Couldn't grab playlist")
            return
        }
        
        var request = URLRequest(url: urlToSend!)
        request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data,response,err) in
            
            if (err == nil){ //This is good!
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    self.parseJSONforSongs(input: json)
                }catch let error as NSError{
                    print("Error -- \(String(describing:error))")
                }
            }else{
                print("Fetch encountered an error -- \(String(describing: err?.localizedDescription))")
            }
            self.finishedLoadingPlaylists = true
            
        }.resume()
        
    }
    
    func parseJSONforSongs(input: [String:Any]){
        //print(input)
        if let playlists = input["items"] as? [[String:AnyObject]] {
            for i in 0..<playlists.count{
                var plName = ""
                var plURI = ""
                var plURL = ""
                var plCount = 0
                
                if let playlistName = playlists[i]["name"] as? String{
                    plName = playlistName
                }
                if let playlistURI = playlists[i]["uri"] as? String{
                    plURI = playlistURI
                }
                if let playlistURL = playlists[i]["href"] as? String{
                    plURL = playlistURL
                }
                if let playlistTracks = playlists[i]["tracks"] as? [String:Any]{
                    if let trackCount = playlistTracks["total"] as? Int {
                        plCount = trackCount
                    }
                }
                let currentPlaylist = Playlist(uri: plURI, url: plURL, name: plName, count: plCount)
                spotPlaylists.append(currentPlaylist)
                
            }
        }else{
            print("Could not parse the list of playlists")
        }
    }
    
    func displayPlaylists() {
        for i in 0..<spotPlaylists.count{
            spotPlaylists[i].printPL()
        }
    }
    
    @IBAction func selectPLButtonPressed(_ sender: Any) {
        if let selectedRow = playlistTable.indexPathForSelectedRow?.row{
            print("You've selected the '\(spotPlaylists[selectedRow].name)' playlist")
        }
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
    
    @IBAction func selectPlaylistButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let roundVC = storyboard.instantiateViewController(withIdentifier: "HostPrePartyViewController") as! HostPrePartyViewController
        roundVC.roundID = self.roundID
        roundVC.playlist = spotPlaylists[(playlistTable.indexPathForSelectedRow?.row)!]
        self.present(roundVC, animated: true, completion: nil)
    }
    
    
}
extension HostSetupPlaylistViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let currentPL = spotPlaylists[indexPath.row]
        cell.textLabel?.text = "\(currentPL.name) - (\(currentPL.songCount))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spotPlaylists.count
    }
}
