//
//  FeedPostTVCell.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 19/09/22.
//

import UIKit
import Amplify
import SDWebImage

class FeedPostTVCell: UITableViewCell {
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var imgViewPost: UIImageView!
    @IBOutlet weak var lblPostDiscription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgViewProfile.layer.cornerRadius = self.imgViewProfile.bounds.height/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func cellConfiguration(key: String, discription: String, userName: String){
        DispatchQueue.main.async {
            Amplify.Storage.getURL(key: key) { event in
                switch event {
                case let .success(url):
                    print("Completed url : \(url)")
                    DispatchQueue.main.async {
                        self.imgViewPost.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                        self.imgViewPost.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                    }
                case let .failure(storageError):
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
            //self.lblPostDiscription.numberOfLines = 2
            self.lblPostDiscription.text = discription
            self.lblUserName.text = userName
        }
        
    }
}
