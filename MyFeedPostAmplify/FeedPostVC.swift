//
//  FeedPostVC.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 19/09/22.
//

import UIKit
import Amplify

class FeedPostVC: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var TvMsg: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedPostVC.imageTapped(gesture:)))
        
        // add it to the image view;
        imgView.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        imgView.isUserInteractionEnabled = true
    }
    
    @IBAction func postBtnTapped(_ sender: UIButton) {
        let timestamp = "\(Date().currentTimeMillis())"
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "-yyyy-MM-dd-HH:mm:ss"
        let time = format.string(from: date)
        
        let key = timestamp + time
        
        if imgView.image != nil{
            uploadData(key: key, img: imgView.image)
        }
        
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            
            let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))
            
            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
                self.openGallery()
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func uploadData( key: String, img: UIImage?) {
        self.displayActivityIndicator(shouldDisplay: true)
        let dataString = "Example file contents"
        let img = img //UIImage(named: "natureImg")
        let data = img?.jpegData(compressionQuality: 0.1) ?? Data()

        //let data = dataString.data(using: .utf8)!
        Amplify.Storage.uploadData(key: key, data: data,
                                   progressListener: { progress in
            print("Progress: \(progress)")
        }, resultListener: { (event) in
            switch event {
            case .success(let data):
                print("Completed:: \(data)")
                print("URL of image :: ", "https://myfeedpostamplify6550a914a64f4b0aa9521cf495adfe183354-dev.s3.amazonaws.com/public/ExampleKey1")
                self.createTodo(description: self.TvMsg.text ?? "", key: key)
                //self.displayURL()
            case .failure(let storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        })
    }
    
    func createTodo(description: String, key: String) {
        self.displayActivityIndicator(shouldDisplay: true)
        let username = UserDefaults.standard.string(forKey: kUserName) ?? ""
        let email = UserDefaults.standard.string(forKey: kEmailID) ?? ""
        
        let todo = Todo(id: key, username: username, email: email, description: description, imageURL: key)
        Amplify.API.mutate(request: .create(todo)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let todo):
                    print("Successfully created the todo:: \(todo)")
                    DispatchQueue.main.async {
//                        let retriveVC = self.storyboard?.instantiateViewController(withIdentifier: "RetriveVC") as? RetriveVC
//                        self.navigationController?.pushViewController(retriveVC!, animated: true)
                        self.displayActivityIndicator(shouldDisplay: false)
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let graphQLError):
                    print("Failed to create graphql \(graphQLError)")
                    DispatchQueue.main.async {
                        self.displayActivityIndicator(shouldDisplay: false)
                    }
                }
            case .failure(let apiError):
                print("Failed to create a todo", apiError)
                DispatchQueue.main.async {
                    self.displayActivityIndicator(shouldDisplay: false)
                }
            }
        }
    }
    
}

extension FeedPostVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    //Camera image picker functionality:
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Gallery image picker functionality:
    func openGallery(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK:-- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.imgView.contentMode = .scaleToFill
            self.imgView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}


//extension FeedPostVC{
//    /// can be done "heic", "heix", "hevc", "hevx"
//    enum ImageFormat: String {
//        case png, jpg, gif, tiff, webp, heic, unknown
//    }
//
//    static func get(from data: Data) -> ImageFormat {
//        switch data[0] {
//        case 0x89:
//            return .png
//        case 0xFF:
//            return .jpg
//        case 0x47:
//            return .gif
//        case 0x49, 0x4D:
//            return .tiff
//        case 0x52 where data.count >= 12:
//            let subdata = data[0...11]
//
//            if let dataString = String(data: subdata, encoding: .ascii),
//               dataString.hasPrefix("RIFF"),
//               dataString.hasSuffix("WEBP")
//            {
//                return .webp
//            }
//
//        case 0x00 where data.count >= 12 :
//            let subdata = data[8...11]
//
//            if let dataString = String(data: subdata, encoding: .ascii),
//               Set(["heic", "heix", "hevc", "hevx"]).contains(dataString)
//            ///OLD: "ftypheic", "ftypheix", "ftyphevc", "ftyphevx"
//            {
//                return .heic
//            }
//        default:
//            break
//        }
//        return .unknown
//    }
//
//    var contentType: String {
//        return "image/\(rawValue)"
//    }
//
//    //uses
////    for file in ["1.jpg", "2.png", "3.gif", "4.svg", "5.TIF", "6.webp", "7.HEIC"] {
////        if let data = Data(bundleFileName: file) {
////            print(file, ImageFormat.get(from: data))
////        }
////    }
//}
