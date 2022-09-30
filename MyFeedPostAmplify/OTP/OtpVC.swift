//
//  OtpVC.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 19/09/22.
//

import UIKit
import Amplify

class OtpVC: UIViewController {

    @IBOutlet weak var otpContainerView: UIView!
    @IBOutlet weak var testButton: UIButton!
    
    let otpStackView = OTPStackView()
    
    var username: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        testButton.isHidden = true
        otpContainerView.addSubview(otpStackView)
        otpStackView.delegate = self
        otpStackView.heightAnchor.constraint(equalTo: otpContainerView.heightAnchor).isActive = true
        otpStackView.centerXAnchor.constraint(equalTo: otpContainerView.centerXAnchor).isActive = true
        otpStackView.centerYAnchor.constraint(equalTo: otpContainerView.centerYAnchor).isActive = true
    }

    @IBAction func clickedForHighlight(_ sender: UIButton) {
        print("Final OTP : ",otpStackView.getOTP())
        //otpStackView.setAllFieldColor(isWarningColor: true, color: .yellow)
        self.confirmSignUp(for: username, with: otpStackView.getOTP())
    }
    
    func confirmSignUp(for username: String, with confirmationCode: String) {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { result in
            switch result {
            case .success:
                print("Confirm signUp succeeded")
                UserDefaults.standard.set(true, forKey: kLogIn) //Bool
                UserDefaults.standard.set(username, forKey: kUserName) //setObject
                UserDefaults.standard.set(username, forKey: kEmailID) //setObject
                DispatchQueue.main.async {
                    self.showAlert(message: "You have sucessfully Signup.", cancelTitle: "Ok") { _ in
                        let otpVC = self.storyboard?.instantiateViewController(withIdentifier: "DashboardVC") as? DashboardVC
                        self.navigationController?.pushViewController(otpVC!, animated: true)
                    }
                }
            case .failure(let error):
                print("An error occurred while confirming sign up \(error)")
            }
        }
    }
}

extension OtpVC: OTPDelegate {
    func didChangeValidity(isValid: Bool) {
        testButton.isHidden = !isValid
    }
}
