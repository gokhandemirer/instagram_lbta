//
//  LoginController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 9.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignupController: UIViewController {
    
    var loginController: LoginController?
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "gradient_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        return iv
    }()
    
    lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Ad Soyadı", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .medium), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        textField.addTarget(self, action: #selector(handleTextFields), for: .editingChanged)
        return textField
    }()
    
    lazy var emailTextField: CustomTextField = {
        let textField = CustomTextField()
        
        textField.keyboardType = .emailAddress
        textField.attributedPlaceholder = NSAttributedString(string: "E-posta Adresi", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .medium), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        textField.addTarget(self, action: #selector(handleTextFields), for: .editingChanged)
        return textField
    }()
    
    lazy var userTextField: CustomTextField = {
        let textField = CustomTextField()
        
        textField.attributedPlaceholder = NSAttributedString(string: "Kullanıcı Adı", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .medium), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        textField.addTarget(self, action: #selector(handleTextFields), for: .editingChanged)
        return textField
    }()
    
    lazy var passwordTextField: CustomTextField = {
        let textField = CustomTextField()
        
        textField.isSecureTextEntry = true
        textField.attributedPlaceholder = NSAttributedString(string: "Şifre", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .medium), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        textField.addTarget(self, action: #selector(handleTextFields), for: .editingChanged)
        return textField
    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "logo_big").withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kayıt Ol", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor(r: 24, g: 145, b: 248)
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return button
    }()
    
    let loginActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setupBottomBarView() {
        
        let bottomBarView = UIView()
        bottomBarView.backgroundColor = .white
        
        let bottomBarTopBorderView = UIView()
        bottomBarTopBorderView.backgroundColor = UIColor(r: 227, g: 227, b: 227)
        
        let questionLabel = UILabel()
        questionLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        questionLabel.textColor = .lightGray
        questionLabel.text = "Hesabın var mı?"
        
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Giriş Yap.", for: .normal)
        loginButton.setTitleColor(UIColor(r: 24, g: 145, b: 248), for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [questionLabel, loginButton])
        stackView.backgroundColor = .purple
        stackView.axis = .horizontal
        stackView.spacing = 4
        
        view.addSubview(bottomBarView)
        view.addSubview(bottomBarTopBorderView)
        bottomBarView.addSubview(stackView)
        
        bottomBarView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 45)
        
        bottomBarTopBorderView.anchor(bottomBarView.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
        
        stackView.anchorCenterSuperview()
    }
    
    @objc fileprivate func handleTextFields() {
        if nameTextField.text!.isEmpty || passwordTextField.text!.isEmpty || nameTextField.text!.isEmpty || emailTextField.text!.isEmpty {
            signupButton.isEnabled = false
            signupButton.alpha = 0.5
        } else {
            signupButton.isEnabled = true
            signupButton.alpha = 1
        }
    }
    
    @objc fileprivate func handleLogin() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handleSignup() {
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.present(CustomTabbarController(), animated: true, completion: nil)
//        }
        
        let username = userTextField.text!
        let name = nameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        adjustButtonTitleAndIndicator(attemptStarted: true)
        
        checkUsernameExists(username: userTextField.text!) { (userExists) in
            if !userExists {
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if error != nil {
                        self.alert(message: error!.localizedDescription)
                        self.adjustButtonTitleAndIndicator(attemptStarted: false)
                        return
                    }
                    
                    guard let uid = user?.uid else { return }
                    self.saveUserToDatabase(name: name, username: username, email: email, id: uid)
                }
            } else {
                self.alert(message: "This username is already in use, please try another username.")
                self.adjustButtonTitleAndIndicator(attemptStarted: false)
            }
        }
        
    }
    
    fileprivate func adjustButtonTitleAndIndicator(attemptStarted: Bool) {
        if attemptStarted {
            signupButton.setTitleColor(.clear, for: .normal)
            loginActivityIndicator.startAnimating()
        } else {
            signupButton.setTitleColor(.white, for: .normal)
            loginActivityIndicator.stopAnimating()
        }
    }
    
    fileprivate func alert(message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func saveUserToDatabase(name: String, username: String, email: String, id: String) {
        
        Database.database().reference().child("usernames").child(username).updateChildValues(["email": email]) { (error, ref) in
            if error != nil {
                self.alert(message: error!.localizedDescription)
                self.adjustButtonTitleAndIndicator(attemptStarted: false)
                return
            }
            
            let dictionary = ["name": name, "username": username, "email": email]
            Database.database().reference().child("users").child(id).updateChildValues(dictionary) { (error, ref) in
                if error != nil {
                    self.alert(message: error!.localizedDescription)
                    self.adjustButtonTitleAndIndicator(attemptStarted: false)
                    return
                }
                
                self.dismiss(animated: true, completion: {
                    self.loginController?.dismissSelfViewController()
                })
                
            }
        }
    }
    
    fileprivate func checkUsernameExists(username: String, completion: @escaping (Bool) -> Void) {
        let usernamesRef = Database.database().reference().child("usernames").child(username)
        
        usernamesRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChildren() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUsernameExists(username: "azerden") { (bool) in
            
        }
        
        view.backgroundColor = .white
        
        [imageView, logoImageView, nameTextField, emailTextField, userTextField, passwordTextField, signupButton].forEach{ view.addSubview($0) }
        
        imageView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 145)
        
        logoImageView.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 48, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 160, heightConstant: 60)
        
        logoImageView.anchorCenterXToSuperview()
        
        nameTextField.anchor(imageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 32, leftConstant: 34, bottomConstant: 0, rightConstant: 34, widthConstant: 0, heightConstant: 45)
        
        emailTextField.anchor(nameTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 12, leftConstant: 34, bottomConstant: 0, rightConstant: 34, widthConstant: 0, heightConstant: 45)
        
        userTextField.anchor(emailTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 12, leftConstant: 34, bottomConstant: 0, rightConstant: 34, widthConstant: 0, heightConstant: 45)
        
        passwordTextField.anchor(userTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 12, leftConstant: 34, bottomConstant: 0, rightConstant: 34, widthConstant: 0, heightConstant: 45)
        
        signupButton.anchor(passwordTextField.bottomAnchor, left: emailTextField.leftAnchor, bottom: nil, right: emailTextField.rightAnchor, topConstant: 24, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 45)
        
        signupButton.addSubview(loginActivityIndicator)
        
        loginActivityIndicator.anchorCenterSuperview()
        
        setupBottomBarView()
    }
}

