//
//  LogInSignupVC.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 16/09/22.
//

import UIKit
import Amplify

class LogInSignupVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchCurrentAuthSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }

    func fetchCurrentAuthSession() {
        _ = Amplify.Auth.fetchAuthSession { result in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
                self.signUp(username: "prashantkumar2@yopmail.com", password: "M1234@1234m", email: "2")
            case .failure(let error):
                print("Fetch session failed with error \(error)")
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
                } else {
                    print("SignUp Complete")
                    self.confirmSignUp(for: username, with: "")
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
            }
        }
    }
    
    func confirmSignUp(for username: String, with confirmationCode: String) {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { result in
            switch result {
            case .success:
                print("Confirm signUp succeeded")
            case .failure(let error):
                print("An error occurred while confirming sign up \(error)")
            }
        }
    }
    
    
    func signIn(username: String, password: String) {
        Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
    }
    
    func signOutLocally() {
        Amplify.Auth.signOut() { result in
            switch result {
            case .success:
                print("Successfully signed out")
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
    
//    func fetchCurrentAuthSession() -> AnyCancellable {
//        Amplify.Auth.fetchAuthSession().resultPublisher
//            .sink {
//                if case let .failure(authError) = $0 {
//                    print("Fetch session failed with error \(authError)")
//                }
//            }
//            receiveValue: { session in
//                print("Is user signed in - \(session.isSignedIn)")
//            }
//    }
    
}
