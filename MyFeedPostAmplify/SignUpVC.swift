//
//  SignUpVC.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 16/09/22.
//

import UIKit
import Amplify

class SignUpVC: UIViewController {

    @IBOutlet weak var tFUserName: UITextField!
    @IBOutlet weak var tFEmailId: UITextField!
    @IBOutlet weak var tFPassword: UITextField!
    @IBOutlet weak var btnSignup: UIButton!
    
    var textfields: [UITextField]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = UserDefaults.standard.string(forKey: kEmailID) ?? "prashantkumar15@yopmail.com"
        tFEmailId.text = email
        self.textfields = [tFUserName, tFEmailId, tFPassword]
        for textfield in textfields!{
          textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        self.btnSignup.isEnabled = false
    }
    
    @IBAction func signupBtnTapped(_ sender: UIButton) {
        self.fetchCurrentAuthSession()
    }
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func fetchCurrentAuthSession() {
        self.displayActivityIndicator(shouldDisplay: true)
        _ = Amplify.Auth.fetchAuthSession { result in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
                DispatchQueue.main.async {
                    self.signUp(username: self.tFEmailId.text ?? "", password: self.tFPassword.text ?? "", email: self.tFEmailId.text ?? "")
                }
            case .failure(let error):
                print("Fetch session failed with error \(error)")
                DispatchQueue.main.async {
                    self.displayActivityIndicator(shouldDisplay: false)
                }
            }
        }
    }
    
    //SignUp using
    /*Parameters: username, password, email get from Signup screen (i.e.. user inputs)*/
    func signUp(username: String, password: String, email: String) {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        Amplify.Auth.signUp(username: username, password: password, options: options) { result in
            switch result {
            case .success(let signUpResult):
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                    DispatchQueue.main.async {
                        self.displayActivityIndicator(shouldDisplay: false)
                        self.showAlert(message: "Verify your account by entering the OTP send to your register email address.", cancelTitle: "Ok") { _ in
                            let otpVC = self.storyboard?.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC
                            otpVC?.username = username
                            self.navigationController?.pushViewController(otpVC!, animated: true)
                        }
                    }
                } else {
                    print("SignUp Complete")
                    //self.confirmSignUp(for: username, with: "")
                    DispatchQueue.main.async {
                        self.displayActivityIndicator(shouldDisplay: false)
                    }
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
                DispatchQueue.main.async {
                    self.displayActivityIndicator(shouldDisplay: false)
                }
            }
        }
    }
    
    //Validation
    @objc func textFieldDidChange(_ textField: UITextField) {
      //set Button to false whenever they begin editing
        btnSignup.isEnabled = false
//        guard let first = textfields?[0].text, first != "", first.count > 5 else {
//            print("textField 1 is empty")
//            return
//        }
        guard let second = textfields?[1].text, second != "", second.count > 5 else {
            print("textField 2 is empty")
            return
        }
        guard let third = textfields?[2].text, third != "", third.count > 7 else {
            print("textField 3 is empty")
            return
        }
        //set button to true whenever all textfield criteria is met.
        btnSignup.isEnabled = true
    }
    
}
