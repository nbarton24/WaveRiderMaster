//
//  JoinPartyViewController.swift
//  WaveRider
//
//  Created by Nick Barton on 12/18/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import UIKit

class JoinPartyViewController: UIViewController {

    @IBOutlet weak var partyCodeTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func joinPartyButtonPressed(_ sender: Any) {
       
        if let inputCode = partyCodeTF.text, inputCode != ""{
            
            DataService.instance.checkValidParty(partyCode: inputCode) { (returnCode) in
                if (returnCode==true){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let pvvc = storyboard.instantiateViewController(withIdentifier: "PartyVotingViewController") as! PartyVotingViewController
                    self.present(pvvc, animated: true, completion: nil)
                }else{
                    print("That round code is no longer valid")
                }
            }
            
        }else{
            print("You must enter a code")
        }
        
    }
    

}
