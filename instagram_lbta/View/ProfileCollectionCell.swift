//
//  ProfileCollectionCell.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 5.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents
import FirebaseAuth
import FirebaseDatabase

class ProfileCollectionCell: DatasourceCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    private let headerId = "headerId"
    var posts = [Post]()
    var postDictionary = [String: Post]()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    fileprivate func observeUserPosts() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
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
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
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
    
    override func setupViews() {
        super.setupViews()
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(CollectionCellHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        addSubview(collectionView)
        
        collectionView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        observeUserPosts()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCell
        
        let post = posts[indexPath.item]
        
        if let imageUrl = post.imageUrl {
            cell.imageView.loadImage(urlString: imageUrl)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 3 - 1, height: frame.width / 3 - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.item]
        (controller as? ProfileController)?.pushToPostViewController(post: post)
    }
}

class CollectionCellHeader: DatasourceCell {
    
    let gridButton: UIButton = {
        let button = UIButton()
        button.setTitle("Grid", for: .normal)
        return button
    }()
    
    override func setupViews() {
        
        let stackView = UIStackView(arrangedSubviews: [gridButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

class ImageCell: DatasourceCell {
    
    let imageView: CachedImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)

        imageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }
}
