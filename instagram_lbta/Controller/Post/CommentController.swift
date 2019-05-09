//
//  CommentController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 8.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents

class CommentController: DatasourceController {
    
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Paylaş", for: .normal)
        button.isEnabled = false
        button.isHidden = true
        return button
    }()
    
    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor(r: 219, g: 219, b: 219).cgColor
        tv.layer.cornerRadius = 20
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 0, right: 64)
        tv.font = UIFont.systemFont(ofSize: 13)
        tv.isScrollEnabled = false
        tv.text = "Yorum ekle..."
        tv.delegate = self
        return tv
    }()
    
    var inputContainerBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datasource = CommentDatasource()
        
        navigationItem.title = "Yorumlar"
        collectionView?.backgroundColor = .white
        
        setupInputContainerView()
        
        textViewDidChange(textView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowHide), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    @objc func keyboardWillShowHide(notification: Notification) {
        
        if notification.name == .UIKeyboardWillHide {
            sendButton.isHidden = true
            inputContainerBottomAnchor?.constant = 0
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            if let userInfo = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                sendButton.isHidden = false
                
                let keyboardFrame = userInfo.cgRectValue
                inputContainerBottomAnchor?.constant = -keyboardFrame.height
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
        
    }
    
    func setupInputContainerView() {
        
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        
        let profileImageView = UIImageView()
        profileImageView.image = #imageLiteral(resourceName: "me")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.borderWidth = 0.5
        profileImageView.layer.borderColor = UIColor(r: 219, g: 219, b: 219).cgColor
        profileImageView.layer.masksToBounds = true
        
        view.addSubview(inputContainerView)
        [topBorderView, profileImageView, textView, sendButton].forEach{ inputContainerView.addSubview($0) }
        
        inputContainerBottomAnchor = inputContainerView.anchorWithReturnAnchors(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 60)[1]
        
        topBorderView.anchor(inputContainerView.topAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: inputContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        
        profileImageView.anchor(nil, left: inputContainerView.leftAnchor, bottom: inputContainerView.bottomAnchor, right: nil, topConstant: 4, leftConstant: 16, bottomConstant: 8, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        
        
        textView.anchor(nil, left: profileImageView.rightAnchor, bottom: nil, right: inputContainerView.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 40)
        
        textView.anchorCenterYToSuperview()
        
        sendButton.anchor(nil, left: nil, bottom: textView.bottomAnchor, right: textView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 12, widthConstant: 50, heightConstant: 20)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
}

extension CommentController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if !textView.text.isEmpty {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
        
        let size = CGSize(width: view.frame.width - 16 - 40 - 8 - 16 - 8, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height + 10
            }
        }
        
        inputContainerView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height + 10 + 18
            }
        }
        
    }
}
