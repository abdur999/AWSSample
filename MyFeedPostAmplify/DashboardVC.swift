//
//  DashboardVC.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 21/09/22.
//

import UIKit
import Amplify

class DashboardVC: UIViewController {
    
    @IBOutlet weak var tableVDashboard: UITableView!
    
    var postData: (List<Todo>)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set automatic dimensions for row height
            // Swift 4.2 onwards
        tableVDashboard.rowHeight = UITableView.automaticDimension
        tableVDashboard.estimatedRowHeight = UITableView.automaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.listTodos()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @IBAction func logOutBtnTapped(_ sender: UIButton) {
        self.signOutLocally()
    }
    
    @IBAction func postBtnTapped(_ sender: UIButton) {
        let otpVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedPostVC") as? FeedPostVC
        self.navigationController?.pushViewController(otpVC!, animated: true)
    }
    
    func listTodos() {
        displayActivityIndicator(shouldDisplay: true)
        let todo = Todo.keys
        //let predicate = todo.name == "my first todo" && todo.description == "todo description"
        //Amplify.API.query(request: .paginatedList(Todo.self, where: predicate, limit: 1000)) {
        Amplify.API.query(request: .paginatedList(Todo.self, limit: 1000)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let todos):
                    print("Successfully retrieved list of todos: \(todos)")
                    self.postData = todos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.tableVDashboard.reloadData()
                        self.displayActivityIndicator(shouldDisplay: false)
                    }
//                    DispatchQueue.main.async {
//                        self.tableVDashboard.reloadData()
//                    }
                    for item in todos{
                        print(item.description)
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    DispatchQueue.main.async {
                        self.displayActivityIndicator(shouldDisplay: false)
                    }
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
                DispatchQueue.main.async {
                    self.displayActivityIndicator(shouldDisplay: false)
                }
            }
        }
    }
    
    func signOutLocally() {
        self.displayActivityIndicator(shouldDisplay: true)
        Amplify.Auth.signOut() { result in
            switch result {
            case .success:
                print("Successfully signed out")
                UserDefaults.standard.set(false, forKey: kLogIn) //Bool
                UserDefaults.standard.set(nil, forKey: kUserName) //setObject
                UserDefaults.standard.set(nil, forKey: kEmailID) //setObject
                DispatchQueue.main.async {
                    self.displayActivityIndicator(shouldDisplay: false)
                    self.navigationController?.popToRootViewController(animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.displayActivityIndicator(shouldDisplay: false)
                }
                print("Sign out failed with error \(error)")
            }
        }
    }
    
    /*func displayURL(){
        Amplify.Storage.getURL(key: "ExampleKey1") { event in
            switch event {
            case let .success(url):
                print("Completed url : \(url)")
            case let .failure(storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        }
    }
    
    func downloadImage(imageKey: String) {
        Amplify.Storage.downloadData(key: imageKey) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    //self.image = UIImage(data: data)
                }
            case .failure(let error):
                print(error)
            }
        }
    }*/
    
}



extension DashboardVC: UITableViewDelegate, UITableViewDataSource{
    
    // UITableViewAutomaticDimension calculates height of label contents/text
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Swift 4.2 onwards
        return UITableView.automaticDimension
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postData?.count ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedPostTVCell", for: indexPath) as? FeedPostTVCell
        let eachPost = self.postData?[indexPath.row]
        let description = eachPost?.description ?? ""
        let username = eachPost?.username ?? ""
        cell?.cellConfiguration(key: eachPost?.imageURL ?? "" , discription: description, userName: username)

        return cell!
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        let retriveVC = self.storyboard?.instantiateViewController(withIdentifier: "RetriveVC") as? RetriveVC
        let selectedPost = self.postData?[indexPath.row]
        retriveVC?.imageKey = selectedPost?.imageURL ?? ""
        retriveVC?.discription = selectedPost?.description ?? ""
        self.navigationController?.pushViewController(retriveVC!, animated: true)
    }
}


