//
//  ViewControllerExtension.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 19/09/22.
//

import Foundation
import UIKit


extension UIViewController{
    enum AppStoryboard {
        case Main
        var description : UIStoryboard {
            switch self {
            case .Main: return UIStoryboard(name: "Main", bundle: nil)
            }
        }
    }
    
    
    //MARK: *************   Show Alert   ***************
    func showAlert(message: String?, title:String = kAppName, otherButtons:[String:((UIAlertAction)-> ())]? = nil, cancelTitle: String = "Ok",onWindow :Bool = false ,cancelAction: ((UIAlertAction)-> ())? = nil) {
        let newTitle = title
        let newMessage = message
        let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
        // Accessing alert view backgroundColor :
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.white

        let cancelBtn = UIAlertAction(title: cancelTitle, style: .default, handler: cancelAction)
        cancelBtn.setValue(UIColor.black , forKey: "titleTextColor")
        alert.addAction(cancelBtn)

        if otherButtons != nil {
            for key in otherButtons!.keys {
                let otherBtn = UIAlertAction(title: key, style: .default, handler: otherButtons![key])
                otherBtn.setValue(UIColor.black, forKey: "titleTextColor")
                alert.addAction(otherBtn)
            }
        }
        if onWindow{
            let window = (UIApplication.shared.delegate as! AppDelegate).window
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }else{
            present(alert, animated: true, completion: nil)
        }
    }
    
    func showErrorMessage(error: NSError?, cancelAction: ((UIAlertAction)-> ())? = nil) {
        var title = kAppName
        var message = "Something Went Wrong"
        if error != nil {
            title = error!.domain
            message = error!.userInfo["message"] as? String ?? ""
        }
        let newTitle = title.capitalized
        let newMessage = message.capitalized
        let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
        let cancelBtn = UIAlertAction(title: "Okay", style: .default, handler: cancelAction)
        cancelBtn.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(cancelBtn)
        present(alert, animated: true, completion: nil)
    }
}
