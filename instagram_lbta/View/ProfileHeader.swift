//
//  ProfileHeader.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 5.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents

class ProfileHeader: DatasourceCell {
    
    override var datasourceItem: Any? {
        didSet {
            if let user = datasourceItem as? User {
                self.setupDataWithUser(user: user)
            }
        }
    }
    
    lazy var profileImageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor(r: 219, g: 219, b: 219).cgColor
        imageView.layer.borderWidth = 0.5
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 42.5
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleProfileImageLongPress)))
        return imageView
    }()
    
    lazy var postCountLabel = UILabel()
    
    lazy var followerCountLabel = UILabel()
    
    lazy var followCountLabel = UILabel()
    
    lazy var profileEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Profili Düzenle", for: .normal)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(r: 225, g: 225, b: 225).cgColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleProfileEdit), for: .touchUpInside)
        
        return button
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    let bioTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isEditable = false
        return textView
    }()
    
    var stackView: UIStackView = {
        let sv = UIStackView()
        return sv
    }()
    
    var bioTextViewTopAnchor: NSLayoutConstraint?
    var bioTextViewAlternativeTopAnchor: NSLayoutConstraint?
    var bioTextViewHeightAnchor: NSLayoutConstraint?
    
    @objc fileprivate func handleProfileImageLongPress() {
        (controller as? ProfileController)?.handleProfileImageLongPress()
    }
    
    fileprivate func setupDataWithUser(user: User) {
        nameLabel.text = user.name
        bioTextView.text = user.bio
        
        if let name = user.name, !name.isEmpty {
            bioTextViewAlternativeTopAnchor?.isActive = false
            bioTextViewTopAnchor?.isActive = true
        } else {
            bioTextViewTopAnchor?.isActive = false
            bioTextViewAlternativeTopAnchor?.isActive = true
        }
        
        if let bio = user.bio, !bio.isEmpty {
            let size = CGSize(width: frame.width - 32, height: .infinity)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            
            let estimatedFrame = NSString(string: bio).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)], context: nil)
            
            bioTextViewHeightAnchor?.constant = estimatedFrame.height + 16
        }
        
        setAttributedText(count: user.postCount?.intValue ?? 0, subText: "gönderi", label: postCountLabel)
        setAttributedText(count: user.followerCount?.intValue ?? 0, subText: "takipçi", label: followerCountLabel)
        setAttributedText(count: user.followCount?.intValue ?? 0, subText: "takip", label: followCountLabel)
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImage(urlString: profileImageUrl)
        } else {
            profileImageView.image = nil
        }
        
    }
    
    override func setupViews() {
        super.setupViews()
        
        separatorLineView.isHidden = false
        
        separatorLineView.backgroundColor = UIColor(r: 219, g: 219, b: 219)
        
        addSubview(profileImageView)
        
        profileImageView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 85, heightConstant: 85)
        
        setupStackView()
        
        addSubview(profileEditButton)
        addSubview(nameLabel)
        addSubview(bioTextView)
        
        profileEditButton.anchor(stackView.bottomAnchor, left: stackView.leftAnchor, bottom: nil, right: stackView.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        
        nameLabel.anchor(profileImageView.bottomAnchor, left: profileImageView.leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 30)
        
        bioTextView.anchor(nil, left: nameLabel.leftAnchor, bottom: nil, right: nameLabel.rightAnchor, topConstant: 0, leftConstant: -4, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        bioTextViewHeightAnchor = bioTextView.heightAnchor.constraint(equalToConstant: 30)
        bioTextViewHeightAnchor?.isActive = true
        
        bioTextViewTopAnchor = bioTextView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: -8)
        bioTextViewTopAnchor?.isActive = true
        
        bioTextViewAlternativeTopAnchor = bioTextView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
    }
    
    func setupStackView() {
        
        let postCountContainerView = UIView()
        
        let followerCountContainerView = UIView()
        
        let followCountContainerView = UIView()
        
        stackView = UIStackView(arrangedSubviews: [postCountContainerView, followerCountContainerView, followCountContainerView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(postCountLabel)
        addSubview(followerCountLabel)
        addSubview(followCountLabel)
        
        stackView.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 40)
        
        postCountLabel.anchor(postCountContainerView.topAnchor, left: postCountContainerView.leftAnchor, bottom: postCountContainerView.bottomAnchor, right: postCountContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        followerCountLabel.anchor(followerCountContainerView.topAnchor, left: followerCountContainerView.leftAnchor, bottom: followerCountContainerView.bottomAnchor, right: followerCountContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        followCountLabel.anchor(followCountContainerView.topAnchor, left: followCountContainerView.leftAnchor, bottom: followCountContainerView.bottomAnchor, right: followCountContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    func setAttributedText(count:Int, subText:String, label: UILabel) {
        label.numberOfLines = 2
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "\(count)", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)])
        
        attributedText.append(NSAttributedString(string: "\n\(subText)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13), NSAttributedStringKey.foregroundColor : UIColor.gray]))
        
        label.attributedText = attributedText
    }
    
    @objc func handleProfileEdit() {
        (controller as? ProfileController)?.handleProfileEdit()
    }
}
