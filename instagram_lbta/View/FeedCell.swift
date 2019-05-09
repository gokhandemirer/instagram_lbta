//
//  FeedCell.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 2.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents
import FirebaseDatabase
import FirebaseAuth

class FeedCell: DatasourceCell {
    
    override var datasourceItem: Any? {
        didSet {
            if let post = datasourceItem as? Post {
                setupData(post: post)
            }
        }
    }
    
    fileprivate func setupData(post: Post) {
        
        usernameLabel.text = post.postedByUsername
        
        if post.likeCount!.intValue > 0 {
            numberOfLikesLabel.text = "\(post.likeCount!) beğenme"
            numberOfLikesLabel.isHidden = false
        } else {
            numberOfLikesLabel.isHidden = true
        }
        
        checkUserLiked(postId: post.id!)
        
        if let imageUrl = post.imageUrl, let imageWidth = post.imageWidth, let imageHeight = post.imageHeight {
            let imageHeight: CGFloat = CGFloat(imageHeight.floatValue / imageWidth.floatValue) * UIScreen.main.bounds.width

            self.postImageView.constraints.forEach({ (constraint) in
                if constraint.firstAttribute == .height {
                    constraint.constant = imageHeight
                }
            })
            
            self.postImageView.loadImage(urlString: imageUrl)
        }
        
        if let comment = post.comment, comment != "", let username = post.postedByUsername {
            postTextView.isHidden = false
            let modifiedComment = "\(username) \(comment)"
            
            let size = CGSize(width: self.frame.width, height: .infinity)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: modifiedComment).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], context: nil)
            
            self.postTextView.constraints.forEach({ (constraint) in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedFrame.height
                }
            })
            
            setAttributedText(tv: self.postTextView, username: username, comment: comment)
            
        } else {
            postTextView.isHidden = true
        }
        
        setupUserProfileImage(id: post.postedById!)
        
        adjustConstraints(post: post)
        
    }
    
    func setupUserProfileImage(id: String) {
        Database.database().reference().child("users").child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                    self.profileImageView.loadImage(urlString: profileImageUrl)
                }
            }
        }
    }
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "1s"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        return label
    }()
    
    let profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        return iv
    }()
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        return sv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Istanbul, Turkey"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "more").withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleMoreButton), for: .touchUpInside)
        return button
    }()
    
    let collectButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "collect").withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var postImageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleImageZoom))
        imageView.addGestureRecognizer(pinchGesture)
        return imageView
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: -2, left: 0, bottom: 0, right: 0)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCommentTapped)))
        return button
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "send"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        return button
    }()
    
    let numberOfLikesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    let postTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return tv
    }()
    
    lazy var imageZoomLauncher: ImageZoomLauncher = {
        let launcher = ImageZoomLauncher(imageView: postImageView)
        return launcher
    }()
    
    fileprivate func setAttributedText(tv: UITextView, username: String, comment: String) {
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)])
        
        attributedText.append(NSAttributedString(string: " \(comment)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]))
        
        tv.attributedText = attributedText
    }
    
    @objc fileprivate func handleLike() {
        
        if let controller = controller as? FeedController {
            controller.handleLike(cell: self)
        } else if let controller = controller as? PostController {
            controller.handleLike(cell: self)
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(profileImageView)
        addSubview(stackView)
        addSubview(moreButton)
        addSubview(postImageView)
        addSubview(likeButton)
        addSubview(commentButton)
        addSubview(sendButton)
        addSubview(collectButton)
        addSubview(numberOfLikesLabel)
        addSubview(postTextView)
        addSubview(timeLabel)
        
        profileImageView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 34, heightConstant: 34)
        
        stackView.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: profileImageView.bottomAnchor, right: moreButton.leftAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        
        moreButton.anchor(profileImageView.topAnchor, left: nil, bottom: profileImageView.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 0)
        
        postImageView.anchor(profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 200)
        
        setupButtons()
        setupUsernameAndLocationLabels()
        
        numberOfLikesLabel.anchor(likeButton.bottomAnchor, left: likeButton.leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 4, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 20)
        
        postTextView.anchor(nil, left: likeButton.leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        
        postTextViewTopAnchor = postTextView.topAnchor.constraint(equalTo: numberOfLikesLabel.bottomAnchor, constant: 8)
        postTextViewTopAnchor?.isActive = true
        
        postTextViewAlternativeAnchor = postTextView.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 8)
        
        timeLabel.anchor(nil, left: likeButton.leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 20)
        
    }
    
    var isLiked = false {
        didSet {
            if isLiked {
                likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            } else {
                likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
            }
        }
    }
    
    func checkUserLiked(postId: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("post-likes").child(postId).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChildren() {
                self.isLiked = true
            } else {
                self.isLiked = false
            }
        }
    }
    
    func likeButtonAnimate() {
        
        self.likeButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.25) {
            self.likeButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    var postTextViewAlternativeAnchor: NSLayoutConstraint?
    
    var postTextViewTopAnchor: NSLayoutConstraint?
    
    fileprivate func adjustConstraints(post: Post) {
        
        if post.likeCount == 0 {
            postTextViewTopAnchor?.isActive = false
            postTextViewAlternativeAnchor?.isActive = true
            
        } else {
            postTextViewAlternativeAnchor?.isActive = false
            postTextViewTopAnchor?.isActive = true
        }
    }
    
    func setupButtons() {
        likeButton.anchor(postImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 34, heightConstant: 34)
        
        commentButton.anchor(postImageView.bottomAnchor, left: likeButton.rightAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 34, heightConstant: 34)
        
        sendButton.anchor(postImageView.bottomAnchor, left: commentButton.rightAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 34, heightConstant: 34)
        
        collectButton.anchor(postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 34, heightConstant: 34)
    }
    
    func setupUsernameAndLocationLabels() {
        
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(locationLabel)
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
    }
    
    @objc func handleCommentTapped() {
        controller?.navigationController?.pushViewController(CommentController(), animated: true)
    }
    
    @objc func handleImageZoom(sender: UIPinchGestureRecognizer) {
        imageZoomLauncher.handleImageZoom(sender: sender)
    }
    
    @objc func handleMoreButton() {
        (controller as? FeedController)?.handleMoreButton()
    }
}
