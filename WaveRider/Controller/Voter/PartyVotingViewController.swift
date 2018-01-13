//
//  PartyVotingViewController.swift
//  
//
//  Created by Nick Barton on 12/18/17.
//

import UIKit

class PartyVotingViewController: UIViewController {

    var user = "Unknown"
    
    var partyCode:String!
    var connected = false
    var currentVote = 0
    var votingEnds = 0.0
    
    @IBOutlet weak var partyCodeLabel: UILabel!
    @IBOutlet weak var songOneButton: UIButton!
    @IBOutlet weak var songTwoButton: UIButton!
    @IBOutlet weak var songThreeButton: UIButton!
    @IBOutlet weak var songFourButton: UIButton!
    
    @IBOutlet weak var currentSongImage: UIImageView!
    @IBOutlet weak var currentSongTitle: UILabel!
    @IBOutlet weak var currentSongArtist: UILabel!
    
    @IBOutlet weak var countdownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let code = partyCode{
            partyCodeLabel.text = code
            connectToFirebase(withCode: code)
        }
    }
    
    func connectToFirebase(withCode code:String){
        if let userID = UIDevice.current.identifierForVendor?.uuidString{
            user = userID
        }
        DataService.instance.connectTo(partyCode: code, asUser: user)
        DataService.instance.currentSongChanged(forParty: code) { (song, artist, image) in
            self.currentSongTitle.text = song
            self.currentSongArtist.text = artist
            print("\(image)")
        }
        DataService.instance.songOptionsChanged(forParty: code) { (songs) in
            self.songOneButton.setTitle(songs[0], for: .normal)
            self.songTwoButton.setTitle(songs[1], for: .normal)
            self.songThreeButton.setTitle(songs[2], for: .normal)
            self.songFourButton.setTitle(songs[3], for: .normal)
        }
        DataService.instance.votingEndsChanged(forParty: code) { (end) in
            self.votingEnds = end
            print("Voting will now end at \(self.votingEnds)")
        }
        connected = true
    }
    
    func disconnectFromFirebase(){
        
    }
    
    @IBAction func voteCast(_ sender: UIButton) {
        print("casting vote")
        switch sender {
        case songOneButton:
            currentVote = 1
        case songTwoButton:
            currentVote = 2
        case songThreeButton:
            currentVote = 3
        case songFourButton:
            currentVote = 4
        default:
            currentVote = 0
        }
        
        DataService.instance.castVote(forParty: partyCode!, asUser: user, withVote: currentVote)
        
    }
    
    
    

}
