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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundCodeTF.delegate = self
        roundCodeTF.text = randomString()
    }

    @IBAction func addRoundButtonPressed(_ sender: Any) {
        if let code = roundCodeTF.text, let user = userID {
            let name = ""
            let notes = ""
            if (code == "") {return}
            DataService.instance.createParty(forParty: code, roundName: name, roundNotes: notes, creator: user, handler: { (status,returnMsg) in
                
                if (status){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let hppvc = storyboard.instantiateViewController(withIdentifier: "HostSetupPlaylistViewController") as! HostSetupPlaylistViewController
                    hppvc.roundID = code
                    self.present(hppvc, animated: true, completion: nil)
                }else{
                    print("Error Adding Round - \(returnMsg)")
                }
                
            })
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func randomString() -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< 5 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
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
