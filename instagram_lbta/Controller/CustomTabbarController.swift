//
//  CustomTabbarController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 3.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CustomTabbarController: UITabBarController {
    
    var currentUser: User?
    
    let menuButton = UIButton(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let feedNavigationController = UINavigationController(rootViewController: FeedController())
        
        feedNavigationController.tabBarItem.image = #imageLiteral(resourceName: "home").withRenderingMode(.alwaysOriginal)
        feedNavigationController.tabBarItem.selectedImage = #imageLiteral(resourceName: "home_selected").withRenderingMode(.alwaysOriginal)
        feedNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        let exploreController = UINavigationController(rootViewController: ExploreController())
        exploreController.tabBarItem.image = #imageLiteral(resourceName: "search").withRenderingMode(.alwaysOriginal)
        exploreController.tabBarItem.selectedImage = #imageLiteral(resourceName: "search_selected").withRenderingMode(.alwaysOriginal)
        exploreController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        let dummyViewController = UIViewController()
        
        let activityNavigationController = UINavigationController()
        activityNavigationController.tabBarItem.image = #imageLiteral(resourceName: "activity").withRenderingMode(.alwaysOriginal)
        activityNavigationController.tabBarItem.selectedImage = #imageLiteral(resourceName: "activity_selected").withRenderingMode(.alwaysOriginal)
        activityNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        let profileNavigationController = UINavigationController(rootViewController: ProfileController())
        profileNavigationController.tabBarItem.image = #imageLiteral(resourceName: "profile").withRenderingMode(.alwaysOriginal)
        profileNavigationController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected").withRenderingMode(.alwaysOriginal)
        profileNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        viewControllers = [feedNavigationController, exploreController, dummyViewController, activityNavigationController, profileNavigationController]
        
        setupMiddleButton()
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        if let uid = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    user.id = snapshot.key
                    self.currentUser = user
                }
                
            })
        }
    }
    
    func setupMiddleButton() {
        
        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
        menuButton.frame = CGRect(x: 0, y: 0, width: tabBarItemSize.width, height: tabBar.frame.size.height)
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = self.view.bounds.height - menuButtonFrame.height - self.view.safeAreaInsets.bottom
        menuButtonFrame.origin.x = self.view.bounds.width / 2 - menuButtonFrame.size.width / 2
        menuButton.frame = menuButtonFrame
        menuButton.setImage(#imageLiteral(resourceName: "Upload"), for: .normal)
        menuButton.setImage(#imageLiteral(resourceName: "Upload_Selected"), for: .highlighted)
        menuButton.addTarget(self, action: #selector(handleButtonClicked), for: .touchUpInside)
        self.view.addSubview(menuButton)
        self.view.layoutIfNeeded()
    }
    
    @objc func handleButtonClicked() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuButton.frame.origin.y = self.view.bounds.height - menuButton.frame.height - self.view.safeAreaInsets.bottom
    }
    
}

extension CustomTabbarController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage: UIImage?
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        }
        
        guard let image = selectedImage else { return }
        
        let sharePostController = SharePostViewController()
        sharePostController.selectedImage = image
        sharePostController.user = currentUser
        
        let navigationController = UINavigationController(rootViewController: sharePostController)
        
        picker.dismiss(animated: true) {
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}
