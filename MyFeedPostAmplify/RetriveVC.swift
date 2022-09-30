//
//  RetriveVC.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 21/09/22.
//

import UIKit
import Amplify
import SDWebImage

class RetriveVC: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblDiscription: UILabel!
    
    var imageKey = ""
    var discription = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDataToView()
    }
    
    func setDataToView(){
        self.lblDiscription.text = discription
        self.displayURL(key: imageKey)
    }
    
    func displayURL(key: String){
        Amplify.Storage.getURL(key: key) { event in
            switch event {
            case let .success(url):
                print("Completed url : \(url)")
                DispatchQueue.main.async {
                    self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    self.imgView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                }
            case let .failure(storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        }
    }
}
