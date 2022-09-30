//
//  LoginVC.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 16/09/22.
//

import UIKit
import Amplify

class LoginVC: UIViewController {
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    var textfields: [UITextField]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = UserDefaults.standard.string(forKey: kEmailID) ?? "prashantkumar15@yopmail.com"
        
        print("email :: ", email)
        
        userNameTF.text = email
        self.textfields = [userNameTF, passwordTF]
        
        for textfield in textfields!{
          textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        self.loginBtn.isEnabled = false
        
        //UserDefaults.standard.bool(forKey: "Key")
        //UserDefaults.standard.integer(forKey: "Key")
        //UserDefaults.standard.string(forKey: "Key")
        if UserDefaults.standard.bool(forKey: kLogIn) {
            DispatchQueue.main.async {
                //self.showAlert(message: "You have sucessfully Signup.", cancelTitle: "Ok") { _ in
                    let otpVC = self.storyboard?.instantiateViewController(withIdentifier: "DashboardVC") as? DashboardVC
                    self.navigationController?.pushViewController(otpVC!, animated: true)
                //}
            }
        }
//        if let appDomain = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: appDomain)
//        }
        
        
    }
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        self.signIn(username: userNameTF.text ?? "", password: passwordTF.text ?? "")
        //socialSignInWithWebUI()
    }
    
    
    @IBAction func SignupBtnTapped(_ sender: UIButton) {
        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC")
                     as? SignUpVC
        self.navigationController?.pushViewController(signUpVC!, animated: true)
    }
    
//    func socialSignInWithWebUI() -> AnyCancellable {
//        Amplify.Auth.signInWithWebUI(for: .facebook, presentationAnchor: self.view.window!)
//            .resultPublisher
//            .sink {
//                if case let .failure(authError) = $0 {
//                    print("Sign in failed \(authError)")
//                }
//            }
//            receiveValue: { _ in
//                print("Sign in succeeded")
//            }
//    }
    
//    func socialSignInWithWebUI() {
//        Amplify.Auth.signInWithWebUI(for: .google , presentationAnchor: self.view.window!) { result in
//            switch result {
//            case .success:
//                print("Sign in succeeded")
//            case .failure(let error):
//                print("Sign in failed \(error)")
//            }
//        }
//    }
    
    func signIn(username: String, password: String) {
        self.displayActivityIndicator(shouldDisplay: true)
        Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
                
                UserDefaults.standard.set(true, forKey: kLogIn) //Bool
                //UserDefaults.standard.set(1, forKey: "Key")  //Integer
                UserDefaults.standard.set(username, forKey: kUserName) //setObject
                UserDefaults.standard.set(username, forKey: kEmailID) //setObject
                DispatchQueue.main.async {
                    //self.showAlert(message: "You have sucessfully Signup.", cancelTitle: "Ok") { _ in
                    self.displayActivityIndicator(shouldDisplay: false)
                    let otpVC = self.storyboard?.instantiateViewController(withIdentifier: "DashboardVC") as? DashboardVC
                    self.navigationController?.pushViewController(otpVC!, animated: true)
                    //}
                }
            case .failure(let error):
                print("Sign in failed \(error)")
                DispatchQueue.main.async {
                    self.signOutLocally()
                    self.displayActivityIndicator(shouldDisplay: false)
                }
            }
        }
    }
    
    func signOutLocally() {
        Amplify.Auth.signOut() { result in
            switch result {
            case .success:
                print("Successfully signed out")
                UserDefaults.standard.set(false, forKey: kLogIn) //Bool
                UserDefaults.standard.set(nil, forKey: kUserName) //setObject
                UserDefaults.standard.set(nil, forKey: kEmailID) //setObject
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
      //set Button to false whenever they begin editing
        loginBtn.isEnabled = false
        guard let first = textfields?[0].text, first != "", first.count > 5 else {
            print("textField 1 is empty")
            return
        }
        guard let second = textfields?[1].text, second != "", second.count > 7 else {
            print("textField 2 is empty")
            return
        }
        //set button to true whenever all textfield criteria is met.
        loginBtn.isEnabled = true
    }
    
}
