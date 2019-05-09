//
//  CommentCell.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 8.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents

class CommentCell: DatasourceCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "me")
        imageView.layer.cornerRadius = 16
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor(r: 219, g: 219, b: 219).cgColor
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let commentTextView: UITextView = {
        let textView = UITextView()
        
        let attributedText = NSMutableAttributedString(string: "gokhandemirerr", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)])

        attributedText.append(NSAttributedString(string: " You're cool bro!", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]))

        textView.attributedText = attributedText
        textView.textContainerInset = .zero
        return textView
    }()
    
    let elapsedTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "1s"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        [profileImageView, commentTextView, elapsedTimeLabel].forEach{ addSubview($0) }
        
        profileImageView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 32, heightConstant: 32)
        
        commentTextView.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: -3, leftConstant: 4, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 30)
        
        elapsedTimeLabel.anchor(nil, left: commentTextView.leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        
    }
}
