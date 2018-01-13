//
//  HostBeginViewController.swift
//  WaveRider
//
//  Created by Nick Barton on 12/2/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import UIKit

class HostBeginViewController: UIViewController {

    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("auth - \(auth)")
        checkSession()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeVCButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkSession(){
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let spotifySession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = spotifySession
            //print("Woo Session!")
            printSession()
        }else{
            //print("Nope.")
        }
    }
    
    func printSession(){
        print("Session Username- \(session.canonicalUsername)")
        print("Session Valid - \(session.isValid())")
        print("Session Refresh Token - \(session.encryptedRefreshToken)")
        print("Session Access Token - \(session.accessToken)")
        print("Session Expiration Date - \(session.expirationDate)")
    }

}
