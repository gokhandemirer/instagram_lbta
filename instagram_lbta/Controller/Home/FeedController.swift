//
//  FeedController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 2.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents
import FirebaseAuth
import FirebaseDatabase

class FeedController: DatasourceController {
    
    var posts = [Post]()
    var postDictionary = [String: Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.refreshControl = getRefreshControl()
        datasource = FeedDatasource()

        setupNavigationItems()
        
        if Auth.auth().currentUser?.uid != nil {
            observeUserFeeds()
//            print("User authenticated")
        } else {
            perform(#selector(handleLogout), on: Thread.main, with: nil, waitUntilDone: false)
        }
        
    }
    
    fileprivate func observeUserFeeds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("user-posts").child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            self.fetchPostWithId(postId: postId)
            
        }
    }
    
    func fetchPostWithId(postId: String) {
        Database.database().reference().child("posts").child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let post = Post(dictionary: dictionary)
                post.id = snapshot.key
                
                if let postId = post.id {
                    self.getPostLikeCount(postId: postId, completion: { (likeCount) in
                        post.likeCount = NSNumber(value: likeCount)
                        self.postDictionary[postId] = post
                        self.posts = Array(self.postDictionary.values)
                        
                        self.posts.sort(by: { (post1, post2) -> Bool in
                            return (post1.timestamp?.intValue)! > (post2.timestamp?.intValue)!
                        })
                        
                        (self.datasource as? FeedDatasource)?.posts = self.posts
                        
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    })
                }
                
            }
            
        })
    }
    
    fileprivate func getPostLikeCount(postId: String, completion: @escaping (UInt) -> Void) {
        Database.database().reference().child("post-likes").child(postId).observe(.value) { (snapshot) in
            completion(snapshot.childrenCount)
        }
    }
    
    func handleLike(cell: FeedCell) {
        
        if let post = (cell.datasourceItem as? Post), let postId = post.id {
            
            guard let user = (tabBarController as? CustomTabbarController)?.currentUser, let uid = user.id, let username = user.username else { return }
            
            if cell.isLiked {
                
                Database.database().reference().child("post-likes").child(postId).child(uid).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        return
                    }
                    
                    self.fetchPostWithId(postId: postId)
                })
                
            } else {
                
                Database.database().reference().child("post-likes").child(postId).child(uid).updateChildValues([username: 1], withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    self.fetchPostWithId(postId: postId)
                })
                
            }
        }
    }
    
    func updateLikeCount(post: Post, increase: Bool) {
        if let count = post.likeCount?.intValue, let postId = post.id {
            let likeCount = increase ? count + 1 : count - 1
            
            guard let postId = post.id else { return }

            Database.database().reference().child("posts").child(postId).updateChildValues(["likeCount": likeCount])
            self.fetchPostWithId(postId: postId)
        }
        
    }
    
    @objc fileprivate func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    func setupNavigationItems() {
        let imageTitleView = UIImageView()
        imageTitleView.image = #imageLiteral(resourceName: "logo")
        
        navigationItem.titleView = imageTitleView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera"), style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send"), style: .plain, target: nil, action: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let post = posts[indexPath.item]
        
        var itemsHeight: CGFloat = 8 + 34 + 4 + 8 + 34 + 20
        
        if let imageWidth = post.imageWidth, let imageHeight = post.imageHeight {
            itemsHeight += CGFloat(imageHeight.floatValue / imageWidth.floatValue) * view.frame.width
        }
        
        if post.likeCount != 0 {
            itemsHeight += 8 + 20
        }
        
        if let comment = post.comment, comment != "", let username = post.postedByUsername {
            let modifiedComment = "\(username) \(comment)"
            
            let size = CGSize(width: view.frame.width, height: .infinity)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: modifiedComment).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], context: nil)
            
            itemsHeight += 8 + estimatedFrame.height

        }
        
        return CGSize(width: view.frame.width, height: itemsHeight)
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        view.layer.zPosition = 0.0
    }

    override func handleRefresh() {
        collectionView?.refreshControl?.endRefreshing()
    }
    
    func handleMoreButton() {
        let actionSheet = UIAlertController()
        
        let facebookShareAction = UIAlertAction(title: "Facebook'ta Paylaş", style: .default, handler: nil)
        let messengerShareAction = UIAlertAction(title: "Messenger'da Paylaş", style: .default, handler: nil)
        let copyLinkAction = UIAlertAction(title: "Bağlantıyı Kopyala", style: .default, handler: nil)
        let openNotificationsAction = UIAlertAction(title: "Gönderi Bildirimlerini Aç", style: .default, handler: nil)
        let complainAction = UIAlertAction(title: "Şikayet Et", style: .destructive, handler: nil)
        let unfollowAction = UIAlertAction(title: "Takibi Bırak", style: .destructive, handler: nil)
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        
        actionSheet.addAction(facebookShareAction)
        actionSheet.addAction(messengerShareAction)
        actionSheet.addAction(copyLinkAction)
        actionSheet.addAction(openNotificationsAction)
        actionSheet.addAction(complainAction)
        actionSheet.addAction(unfollowAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
}
