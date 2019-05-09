//
//  BiographyController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 10.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit

class BiographyController: UIViewController {
    
    let characterCount = 150
    
    var bioText: String? {
        didSet {
            bioTextView.text = bioText
        }
    }
    
    lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.text = "\(characterCount)"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()
    
    lazy var bioTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(r: 230, g: 230, b: 230).cgColor
        textView.isScrollEnabled = false
        textView.delegate = self
        return textView
    }()
    
    var charactersLabelBottomAnchor: NSLayoutConstraint?
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowHide), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigationItem()
        
        setupTextViewAndLabel()
        
        textViewDidChange(bioTextView)
        
        setupObservers()
        
    }
    
    fileprivate func setupTextViewAndLabel() {
        view.addSubview(bioTextView)
        view.addSubview(characterCountLabel)
        
        bioTextView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        
        charactersLabelBottomAnchor = characterCountLabel.anchorWithReturnAnchors(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 12, rightConstant: 12, widthConstant: 0, heightConstant: 20)[1]
    }
    
    fileprivate func setupNavigationItem() {
        navigationItem.title = "Biyografi"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Bitti", style: .plain, target: self, action: #selector(handleFinish))
    }
    
    @objc fileprivate func keyboardWillShowHide(notification: Notification) {
        
        if notification.name == .UIKeyboardWillHide {
            charactersLabelBottomAnchor?.constant = 12
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            if let userInfo = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardFrame = userInfo.cgRectValue
                characterCountLabel.constraints.forEach({ (constraint) in
                    charactersLabelBottomAnchor?.constant = -keyboardFrame.height - 12
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.layoutIfNeeded()
                    })
                })
            }
        }
        
    }
    
    @objc fileprivate func handleFinish() {
        
        (navigationController?.viewControllers.first as? ProfileEditController)?.bioTextField.text = bioTextView.text
        navigationController?.popViewController(animated: true)
    }
}

extension BiographyController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
        characterCountLabel.text = "\(characterCount - textView.text.count)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= characterCount
    }
}







