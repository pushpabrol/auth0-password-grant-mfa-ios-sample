//
//  EnterCodeViewController.swift
//  Auth0Mfa
//
//  Created by Pushp Abrol on 4/16/17.
//  Copyright © 2017 Pushp Abrol. All rights reserved.
//

import UIKit
import Auth0
import SimpleKeychain
import Alamofire

class EnterCodeViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var authorizationPendingLabel: UILabel!
    @IBOutlet weak var idToken: UITextView!
    @IBOutlet weak var mfaCode: UITextField!
    @IBOutlet weak var accessToken: UITextView!
    @IBOutlet weak var validateCodeButton: UIButton!
    var t = 0;
    
    @IBOutlet weak var stopWaitingForAuthzButton: UIButton!
    @IBAction func enterOtpInsteadOfWaitingForAuthorization(_ sender: UIButton) {
        
        self.stopWaitingForAuthzButton.isHidden = true
        self.mfaCode.isHidden = false
        self.validateCodeButton.isHidden = false
        self.waitingForAuthorization.isHidden = true
        self.authorizationPendingLabel.isHidden = true
        self.stopWaitingForAuthzButton.isHidden = true
        self.mfaCode.becomeFirstResponder()
        Application.sharedInstance.challengeType = "otp"
        
    }
   
    @IBAction func startAgain(_ sender: Any) {
        
        
        self.idToken.text = ""
        self.accessToken.text = "";
        self.performSegue(withIdentifier: "startAgain", sender: self)
    }
    @IBOutlet weak var waitingForAuthorization: UIActivityIndicatorView!
    
    @IBAction func validateCode(_ sender: Any) {
        
    if(Application.sharedInstance.challengeType == "oob")
    {
        self.makeOOBGrantRequest()
    }
    if(Application.sharedInstance.challengeType == "otp")
    {
    self.makeOtpRequest()
    }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()  //if desired
        validateCode(self.mfaCode)
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        t = 0;
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mfaCode.delegate = self
        
        if(Application.sharedInstance.json != nil)
        {
            self.mfaCode.isHidden = true
            self.validateCodeButton.isHidden = true
            self.hideWaitingDisplays(hide: true)
            
            print(Application.sharedInstance.json?["id_token"] as! String)
            self.idToken.text = Application.sharedInstance.json?["id_token"] as! String
            self.accessToken.text = Application.sharedInstance.json?["access_token"] as! String
        }
        
        else
        {
            
        if(Application.sharedInstance.bindingMethod == "prompt" || Application.sharedInstance.challengeType == "otp")
        {
            self.mfaCode.isHidden = false
            self.validateCodeButton.isHidden = false
            self.hideWaitingDisplays(hide: true)
            self.mfaCode.becomeFirstResponder()

        }
        else
        {
        self.mfaCode.isHidden = true
        self.validateCodeButton.isHidden = true
        self.hideWaitingDisplays(hide: false)
        makeOOBGrantRequest()
            
        }

        }
    }
    
    func makeOOBGrantRequest()
    {
        
        let oAuthEndpoint: String = "https://".appending(Application.sharedInstance.domain!).appending("/oauth/token");
        let authRequest = ["mfa_token":Application.sharedInstance.mfa_token!,"binding_code":mfaCode.text!,"client_id":Application.sharedInstance.clientId!,"grant_type":"http://auth0.com/oauth/grant-type/mfa-oob","oob_code":Application.sharedInstance.oobCode!] as [String : Any]
        
        Alamofire.request(oAuthEndpoint , method: .post, parameters: authRequest, encoding: JSONEncoding.default)
            .LogRequest()
            .responseJSON { response in
                guard response.result.error == nil else {
                    print(response.result.error!)
                    
                    return
                }
                
                // make sure we got JSON and it's a dictionary
                guard let json = response.result.value as? [String: AnyObject] else {
                    print("didn't get todo object as JSON from API")
                    return
                }
                print(json)
                let err = json["error"]
                if(err != nil)
                {
                    if(err as! String == "authorization_pending")
                    {
                        
                        _ = self.setTimeout(delay: 10, block: { () -> Void in
                        self.makeOOBGrantRequest()

                        })
                        

                    }
                    if(err as! String == "slow_down")
                    {
                        let alertController = UIAlertController(title: "Error", message: json["error_description"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                        {
                            (result : UIAlertAction) -> Void in
                            
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    if(err as! String == "access_denied")
                    {
                            self.hideWaitingDisplays(hide: true)
                     self.idToken.text = "MFA Authorization rejected"
                     self.accessToken.text = "MFA Authorization rejected"
                    
                    }
                }
                
                else
                {
                self.hideWaitingDisplays(hide: true)
                print(json["id_token"] as! String)
                self.idToken.text = json["id_token"] as! String
                self.accessToken.text = json["access_token"] as! String
                }
                
        }
    }
    
    func makeOtpRequest()
    {
        let oAuthEndpoint: String = "https://".appending(Application.sharedInstance.domain!).appending("/oauth/token");
        let authRequest = ["mfa_token":Application.sharedInstance.mfa_token!,
                           "otp":mfaCode.text!,
                           "client_id":Application.sharedInstance.clientId!,
                           "grant_type":"http://auth0.com/oauth/grant-type/mfa-otp"] as [String : Any]
        
        Alamofire.request(oAuthEndpoint , method: .post, parameters: authRequest, encoding: JSONEncoding.default)
            .LogRequest()
            .responseJSON { response in
                guard response.result.error == nil else {
                    print(response.result.error!)
                    
                    return
                }
                
                // make sure we got JSON and it's a dictionary
                guard let json = response.result.value as? [String: AnyObject] else {
                    print("didn't get todo object as JSON from API")
                    return
                }
                print(json)
                let err = json["error"]
                if(err != nil)
                {
                    if(err as! String == "invalid_grant")
                    {
                        self.hideWaitingDisplays(hide: true)
                        self.idToken.text = "Invalid OTP"
                        self.accessToken.text = "Invalid OTP"
                        
                    }
                }
                    
                else
                {
                    self.waitingForAuthorization.isHidden = true
                    print(json["id_token"] as! String)
                    self.idToken.text = json["id_token"] as! String
                    self.accessToken.text = json["access_token"] as! String
                }
                
        }

    }
    
    func hideWaitingDisplays(hide: Bool)
    {
    self.waitingForAuthorization.isHidden = hide
    self.authorizationPendingLabel.isHidden = hide
    self.stopWaitingForAuthzButton.isHidden = hide
    self.authorizationPendingLabel.isHidden = hide
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setTimeout(delay:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
    
    func setInterval(interval:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: interval, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: true)
    }


}
