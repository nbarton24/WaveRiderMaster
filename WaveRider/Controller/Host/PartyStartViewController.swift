//
//  PartyStartViewController.swift
//  WaveRider
//
//  Created by Nick Barton on 12/8/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import UIKit

class PartyStartViewController: UIViewController,UITextFieldDelegate {

    var userID = UIDevice.current.identifierForVendor?.uuidString
    
    @IBOutlet weak var roundCodeTF: UITextField!
    @IBOutlet weak var roundNameTF: UITextField!
    @IBOutlet weak var roundNotesTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundCodeTF.delegate = self
    }

    @IBAction func addRoundButtonPressed(_ sender: Any) {
        if let code = roundCodeTF.text, let user = userID {
            let name = roundNameTF.text ?? ""
            let notes = roundNotesTF.text ?? ""
            DataService.instance.createParty(roundCode: code, roundName: name, roundNotes: notes, creator: user, handler: { (status) in
                print("Round Added")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let hppvc = storyboard.instantiateViewController(withIdentifier: "HostSetupPlaylistViewController") as! HostSetupPlaylistViewController
                hppvc.roundID = code
                self.present(hppvc, animated: true, completion: nil)
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
