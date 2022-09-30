//
//  PostVC.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 19/09/22.
//

import UIKit
import Amplify

class PostVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        uploadData()
    }
    

    func uploadData() {
        
        let dataString = "Example file contents"
        let img = UIImage(named: "natureImg")
        let data = img?.jpegData(compressionQuality: 0.6) ?? Data()
        //let data = dataString.data(using: .utf8)!
        Amplify.Storage.uploadData(key: "ExampleKey1", data: data,
            progressListener: { progress in
                print("Progress: \(progress)")
            }, resultListener: { (event) in
                switch event {
                case .success(let data):
                    print("Completed: \(data)")
                    print("URL of image :: ", "https://myfeedpostamplify6550a914a64f4b0aa9521cf495adfe183354-dev.s3.amazonaws.com/public/ExampleKey1")
                case .failure(let storageError):
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        })
    }
}
