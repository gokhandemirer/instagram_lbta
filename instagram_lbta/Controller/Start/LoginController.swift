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

class LoginController: UIViewController {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "gradient_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        return iv
    }()
    
    lazy var userTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Kullanıcı adı veya e-posta adresi", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .medium), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
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
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Giriş Yap", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor(r: 24, g: 145, b: 248)
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
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
        questionLabel.text = "Hesabın yok mu?"
        
        let signUpButton = UIButton(type: .system)
        signUpButton.setTitle("Kaydol.", for: .normal)
        signUpButton.setTitleColor(UIColor(r: 24, g: 145, b: 248), for: .normal)
        signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        signUpButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [questionLabel, signUpButton])
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
        if userTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
        } else {
            loginButton.isEnabled = true
            loginButton.alpha = 1
        }
    }
    
    @objc fileprivate func handleSignup() {
        let signupController = SignupController()
        signupController.loginController = self
        present(signupController, animated: true, completion: nil)
    }
    
    func dismissSelfViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handleLogin() {
        
        adjustButtonTitleAndIndicator(attemptStarted: true)
        
        let usernameOrEmail = userTextField.text!
        let password = passwordTextField.text!
        
        if isEmail(text: usernameOrEmail) {
            self.firebaseAuth(email: usernameOrEmail, password: password)
            return
        }
        
        Database.database().reference().child("usernames").child(usernameOrEmail).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChildren() {
                
                guard let dictionary = snapshot.value as? [String: AnyObject], let email = dictionary["email"] as? String else {
                    self.adjustButtonTitleAndIndicator(attemptStarted: false)
                    return
                }
                
                self.firebaseAuth(email: email, password: password)
                
            } else {
                self.alert(message: "No such user found")
                self.adjustButtonTitleAndIndicator(attemptStarted: false)
            }
        }
    }
    
    func firebaseAuth(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.alert(message: error!.localizedDescription)
                self.adjustButtonTitleAndIndicator(attemptStarted: false)
                return
            }
            
            self.dismissSelfViewController()
            
        })
    }
    
    func isEmail(text: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
    }
    
    fileprivate func alert(message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func adjustButtonTitleAndIndicator(attemptStarted: Bool) {
        if attemptStarted {
            loginButton.setTitleColor(.clear, for: .normal)
            loginActivityIndicator.startAnimating()
        } else {
            loginButton.setTitleColor(.white, for: .normal)
            loginActivityIndicator.stopAnimating()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        [imageView, logoImageView, userTextField, passwordTextField, loginButton].forEach{ view.addSubview($0) }
        
        imageView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 145)
        
        logoImageView.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 48, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 160, heightConstant: 60)
        
        logoImageView.anchorCenterXToSuperview()
        
        userTextField.anchor(imageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 32, leftConstant: 34, bottomConstant: 0, rightConstant: 34, widthConstant: 0, heightConstant: 45)
        
        passwordTextField.anchor(userTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 12, leftConstant: 34, bottomConstant: 0, rightConstant: 34, widthConstant: 0, heightConstant: 45)
        
        loginButton.anchor(passwordTextField.bottomAnchor, left: passwordTextField.leftAnchor, bottom: nil, right: passwordTextField.rightAnchor, topConstant: 24, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 45)
        
        loginButton.addSubview(loginActivityIndicator)

        loginActivityIndicator.anchorCenterSuperview()
        
        setupBottomBarView()
    }
}
