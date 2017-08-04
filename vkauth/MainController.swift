//
//  MainController.swift
//  vkauth
//
//  Created by Mikhail Rymarev on 03.08.17.
//  Copyright © 2017 Mikhail Rymarev. All rights reserved.
//

import UIKit

class MainController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var friends: [User] = []
    
    var page: Int = 1
    var isFetching: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchFriends()
    }
    
    func fetchFriends(clear: Bool=false) {
        if clear {
            self.page = 0
            self.friends = []
        }
        VK().getFriends(page: self.page) { friends in
            self.isFetching = false
            self.friends += friends
            self.updateView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: UIButton) {
        VK.logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateView() {
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        
    }
}

extension MainController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserTVC", for: indexPath) as? UserTableViewCell {
            let user = friends[indexPath.row]
            cell.userImageView.setImage(img: user.image)
            cell.nameLabel.text = user.name
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = friends[indexPath.row]
        if let messageVC = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MessageVC") as? MessageViewController {
            messageVC.user = user
            self.present(messageVC, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if (actualPosition >= contentHeight - tableView.frame.size.height) {
            if !isFetching {
                isFetching = true
                self.page += 1
                self.fetchFriends()
            }
            
        }
    }

}
