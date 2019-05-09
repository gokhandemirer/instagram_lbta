//
//  PostController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 5.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents
import FirebaseDatabase

class PostController: DatasourceController {
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Fotoğraf"
        
        collectionView?.refreshControl = getRefreshControl()
        
        datasource = PostDatasource()
        datasource?.objects = posts
        collectionView?.reloadData()
        
//        let reloadButton = UIButton(type: .system)
//        reloadButton.setImage(#imageLiteral(resourceName: "reload"), for: .normal)
//        reloadButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reloadButton)
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
    
    fileprivate func getPostLikeCount(postId: String, completion: @escaping (UInt) -> Void) {
        Database.database().reference().child("post-likes").child(postId).observe(.value) { (snapshot) in
            completion(snapshot.childrenCount)
        }
    }
    
    fileprivate func fetchPostWithId(postId: String) {
        Database.database().reference().child("posts").child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let post = Post(dictionary: dictionary)
                post.id = snapshot.key
                
                if let postId = post.id {
                    self.getPostLikeCount(postId: postId, completion: { (likeCount) in
                        post.likeCount = NSNumber(value: likeCount)
                        self.posts = [post]
                        
                        self.datasource?.objects = self.posts
                        self.collectionView?.refreshControl?.endRefreshing()
                        
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    })
                }
                
            }
            
        })
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
    
    override func handleRefresh() {
        
        if let postId = posts.first?.id {
            self.fetchPostWithId(postId: postId)
        }
        
    }
}
