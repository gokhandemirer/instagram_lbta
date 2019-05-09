//
//  ProfileController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 5.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents
import FirebaseDatabase
import FirebaseStorage

import FirebaseAuth

class ProfileController: DatasourceController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.refreshControl = getRefreshControl()
        
        let profileDatasource = ProfileDatasource()
        datasource = profileDatasource
        
        if let user = (tabBarController as? CustomTabbarController)?.currentUser {
            setupNavigationItemWithUser(user: user)
        } else {
            fetchProfile()
        }
        
        observeProfile()
    }
    
    fileprivate func observeProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .childChanged) { (snapshot) in
            self.fetchProfile()
        }
    }
    
    fileprivate func fetchProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                
                (self.tabBarController as? CustomTabbarController)?.currentUser = user
                
                self.setupNavigationItemWithUser(user: user)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    func handleProfileImageLongPress() {
        let actionSheet = UIAlertController(title: "Profil Fotoğrafını Değiştir", message: nil, preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "Mevcut Fotoğrafı Kaldır", style: .destructive) { (_) in
            
        }
        
        let libraryAction = UIAlertAction(title: "Kütüphaneden Seç", style: .default) { (_) in
            self.handleChooseProfileImageFromLibrary()
        }
        
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        
        actionSheet.addAction(removeAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func handleChooseProfileImageFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setupNavigationItemWithUser(user: User) {
        (self.datasource as? ProfileDatasource)?.user = user
        
        let titleLabel = UILabel()
        titleLabel.text = user.username
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        
        navigationItem.titleView = titleLabel
        
        let optionsButton = UIButton(type: .system)
        optionsButton.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        optionsButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        optionsButton.addTarget(self, action: #selector(handleOptions), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: optionsButton)]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var estimatedHeight: CGFloat = 16 + 85
        
        if let user = (tabBarController as? CustomTabbarController)?.currentUser {
            if let name = user.name, !name.isEmpty {
                estimatedHeight += 8 + 30
            }
            
            if let bio = user.bio, !bio.isEmpty {
                let size = CGSize(width: view.frame.width - 32, height: .infinity)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                
                let estimatedFrame = NSString(string: bio).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)], context: nil)
                
                estimatedHeight += estimatedFrame.height + 16
            }
            
        }
        
        return CGSize(width: view.frame.width, height: estimatedHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func pushToPostViewController(post: Post) {
        
        let postController = PostController()
        postController.posts = [post]
        
        navigationController?.pushViewController(postController, animated: true)
    }
    
    @objc func handleOptions() {
//        navigationController?.pushViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
    }
    
    func handleProfileEdit() {
        let profileEditController = ProfileEditController(style: .plain)
        
        if let user = (tabBarController as? CustomTabbarController)?.currentUser {
            profileEditController.user = user
        }
        
        let profileEditNavigationController = UINavigationController(rootViewController: profileEditController)
        present(profileEditNavigationController, animated: true, completion: nil)
    }
    
    override func handleRefresh() {
        collectionView?.refreshControl?.endRefreshing()
    }
    
}

extension ProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage: UIImage?
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        }
        
        guard let image = selectedImage else { return }
        
        uploadProfileImageToFirebase(image: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func uploadProfileImageToFirebase(image: UIImage) {
        
        guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
        
        Storage.storage().reference().child("profile_images").child("image.jpg").putData(uploadData, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error)
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid, let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            Database.database().reference().child("users").child(uid).updateChildValues(["profileImageUrl": imageUrl], withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error)
                    return
                }
                
            })
            
        }
    }
}








