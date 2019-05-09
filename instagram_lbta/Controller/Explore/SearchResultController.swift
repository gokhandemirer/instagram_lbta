//
//  SearchResultController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 8.06.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit
import FirebaseDatabase
import LBTAComponents

private let cellId = "cellId"

class SearchResultController: UITableViewController, UISearchResultsUpdating {
    
    var users = [User]()
    var userDictionary = [String: User]()
    
    var exploreController: ExploreController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.refreshControl = UIRefreshControl()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        exploreController?.pushToUserProfileControllerWithUser(user: user)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let strSearch = searchController.searchBar.text, !strSearch.isEmpty {
            
            tableView.refreshControl?.beginRefreshing()
            
            users.removeAll(keepingCapacity: false)
            userDictionary.removeAll(keepingCapacity: false)
            
            let ref = Database.database().reference().child("users")
            let query = ref.queryOrdered(byChild: "username").queryStarting(atValue: strSearch, childKey: "username").queryEnding(atValue: strSearch + "\u{f8ff}", childKey: "username")

            query.observe(.childAdded) { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    
                    if let username = user.username {
                        self.userDictionary[username] = user
                        self.users = Array(self.userDictionary.values)
                        
                        self.tableView.refreshControl?.endRefreshing()
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImage(urlString: profileImageUrl)
        } else {
            cell.profileImageView.image = nil
        }
        
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = user.name
        
        return cell
    }
}

class UserCell: UITableViewCell {
    
    let profileImageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 62, y: (textLabel?.frame.origin.y)!, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        
        detailTextLabel?.frame = CGRect(x: 62, y: (detailTextLabel?.frame.origin.y)!, width: frame.width - 62, height: (detailTextLabel?.frame.height)!)
        
        textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        
        detailTextLabel?.textColor = .gray
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}








