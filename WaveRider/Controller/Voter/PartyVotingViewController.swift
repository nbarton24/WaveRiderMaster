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
    var partyStatus = "Pending"
    
    var votingTimer = Timer()
    var isVoting = false
    
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
            self.loadImage(imageString: image)
        }
        DataService.instance.songOptionsChanged(forParty: code) { (songs) in
            self.songOneButton.setTitle(songs[0], for: .normal)
            self.songTwoButton.setTitle(songs[1], for: .normal)
            self.songThreeButton.setTitle(songs[2], for: .normal)
            self.songFourButton.setTitle(songs[3], for: .normal)
        }
        DataService.instance.votingEndsChanged(forParty: code) { (end) in
            self.votingEnds = end
            if(!self.votingTimer.isValid){
                self.runTimer()
            }
            print("Voting will now end at \(self.votingEnds)")
        }
        DataService.instance.partyStatusChanged(forParty: code) { (status) in
            self.partyStatus = status
            self.statusChanged()
        }
        connected = true
    }
    
    func disconnectFromFirebase(){
        
    }
    
    func statusChanged(){
        var temp = ""
        isVoting = false
        switch partyStatus {
        case "Voting":
            isVoting = true
            temp = "Votes are being cast"
        case "Paused":
            temp = "The host has paused the round"
        case "Tallying":
            temp = "The votes are being tallied"
        case "Waiting":
            temp = "The voting is about to begin!"
        case "Finished":
            temp = "This party has ended"
        default:
            temp = "An Unknown status has been entered"
        }
        print(temp)
    }
    
    func runTimer() {
        votingTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(PartyVotingViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        //Compare now to end time
        let difference = Int(votingEnds - NSDate().timeIntervalSince1970)
        if (difference>=0){
            countdownLabel.text = "\(difference)"
        }else{
            votingTimer.invalidate()
        }
        
    }
    
    func loadImage(imageString:String){
        
        if imageString == ""{
            return
        }
        
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
    
    @IBAction func voteCast(_ sender: UIButton) {
        if(!isVoting){
            return
        }
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
