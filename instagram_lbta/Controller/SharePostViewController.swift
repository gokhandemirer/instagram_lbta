//
//  ShareViewController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 2.06.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import ZVProgressHUD

class SharePostViewController: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage!
        }
    }
    
    var user: User?
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor(r: 239, g: 239, b: 239).cgColor
        iv.layer.borderWidth = 1
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = .lightGray
        tv.text = "Açıklama yaz..."
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    @objc fileprivate func handleShare() {
        
        ZVProgressHUD.show(title: "Paylaşılıyor...", state: ZVProgressHUD.StateType.indicator, on: .center)
        
        guard let image = selectedImage, let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let imageName = UUID().uuidString
        
        Storage.storage().reference().child("post_images").child("\(imageName).jpg").putData(uploadData, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error)
                return
            }
            
            guard let user = self.user, let username = user.username, let uid = user.id, let imageUrl = metadata?.downloadURL()?.absoluteString else {
                return
            }
            
            let dictionary: [String: Any] = ["postedById": uid, "postedByUsername": username, "imageUrl": imageUrl, "likeCount": 0, "imageWidth": imageWidth, "imageHeight": imageHeight, "comment": self.textView.text, "timestamp": Date().timeIntervalSince1970]
            
            Database.database().reference().child("posts").childByAutoId().updateChildValues(dictionary, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error)
                    return
                }
                
                let postId = ref.key
                
                Database.database().reference().child("user-posts").child(uid).updateChildValues([postId: 1], withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    self.updateUserPostCount(user: user)
                    
                    ZVProgressHUD.dismiss()
                    self.dismiss(animated: true, completion: nil)
                    
                })
            })
        }
    }
    
    fileprivate func updateUserPostCount(user: User) {
        if let id = user.id, let postCount = user.postCount {
            Database.database().reference().child("users").child(id).updateChildValues(["postCount": postCount.intValue + 1])
        }
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupNavigationItem() {
        navigationItem.title = "Yeni Gönderi"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "İptal", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(r: 0, g: 122, b: 255)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Paylaş", style: .plain, target: self, action: #selector(handleShare))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(r: 0, g: 122, b: 255)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        view.addSubview(textView)
        
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        textView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
    }
}
