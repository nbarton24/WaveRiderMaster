//
//  JoinPartyViewController.swift
//  WaveRider
//
//  Created by Nick Barton on 12/18/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import UIKit

class JoinPartyViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var partyCodeTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        partyCodeTF.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func joinPartyButtonPressed(_ sender: Any) {
       
        if let inputCode = partyCodeTF.text, inputCode != ""{
            
            DataService.instance.checkValidParty(partyCode: inputCode) { (returnCode) in
                if (returnCode==true){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let pvvc = storyboard.instantiateViewController(withIdentifier: "PartyVotingViewController") as! PartyVotingViewController
                    pvvc.partyCode = inputCode
                    self.present(pvvc, animated: true, completion: nil)
                }else{
                    print("That round code is no longer valid")
                }
            }
            
        }else{
            print("You must enter a code")
        }
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (string.contains(" ")) {
            return false
        }else{
            return true
        }
    }
    

}
