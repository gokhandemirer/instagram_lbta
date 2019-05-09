//
//  ProfileEditController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 5.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents
import FirebaseDatabase
import FirebaseAuth
import ZVProgressHUD

struct Input {
    var title:String
    var titleFontSize: CGFloat
    var inputView: UIView
    var selection: Bool
}

class ProfileEditController: UITableViewController {
    
    var user: User? {
        didSet {
            usernameTextField.text = user?.username
            nameTextField.text = user?.name
            bioTextField.text = user?.bio
            
            if let profileImageUrl = user?.profileImageUrl {
                profileImageView.loadImage(urlString: profileImageUrl)
            }
        }
    }
    
    lazy var nameTextField: UITextField = {
        let textField = createTextField(placeholder: "Adı")
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    lazy var usernameTextField: UITextField = {
        let textField = createTextField(placeholder: "Kullanıcı Adı")
        textField.clearButtonMode = .whileEditing
        textField.isEnabled = false
        return textField
    }()
    
    lazy var siteTextField: UITextField = {
        let textField = createTextField(placeholder: "İnternet Sitesi")
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    lazy var bioTextField: UITextField = {
        let textField = createTextField(placeholder: "Biyografi")
        textField.isEnabled = false
        return textField
    }()
    
    lazy var profileImageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 47.5
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var inputs = [Input]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        navigationItem.title = "Profili Düzenle"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "İptal", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kaydet", style: .plain, target: self, action: #selector(handleSave))
        
        setupHeaderView()
        tableView.tableFooterView = UIView()
        
        setupInputs()
        
    }
    
    @objc fileprivate func handleSave() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ZVProgressHUD.show(title: "Kaydediliyor...", state: ZVProgressHUD.StateType.indicator, on: .center)

        if !usernameTextField.text!.isEmpty {
            
            let values: [String: String?] = ["name": nameTextField.text, "username": usernameTextField.text!, "bio": bioTextField.text, "website": siteTextField.text]

            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error)
                    return
                }
                
                ZVProgressHUD.dismiss()
                self.dismiss(animated: true, completion: nil)
            })
        }
        
    }
    
    fileprivate func checkUsernameExists(username: String) {
        
    }
    
    @objc fileprivate func handleChangeProfileImage() {
        print(1234)
    }
    
    fileprivate func setupInputs() {
        let nameInput = Input(title: "Adı", titleFontSize: 18, inputView: nameTextField, selection: false)
        let usernameInput = Input(title: "Kullanıcı adı", titleFontSize: 16, inputView: usernameTextField, selection: false)
        let siteInput = Input(title: "İnternet Sitesi", titleFontSize: 14, inputView: siteTextField, selection: false)
        let bioInput = Input(title: "Biyografi", titleFontSize: 18, inputView: bioTextField, selection: true)
        
        inputs = [nameInput, usernameInput, siteInput, bioInput]
    }
    
    func setupHeaderView() {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 160)
        
        let changeProfileImageButton = UIButton(type: .system)
        changeProfileImageButton.setTitle("Profil Fotoğrafını Değiştir", for: .normal)
        changeProfileImageButton.addTarget(self, action: #selector(handleChangeProfileImage), for: .touchUpInside)
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = UIColor(r: 227, g: 227, b: 227)
        
        headerView.addSubview(profileImageView)
        headerView.addSubview(changeProfileImageButton)
        headerView.addSubview(bottomSeperatorView)
        
        profileImageView.anchor(headerView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 95, heightConstant: 95)
        
        profileImageView.anchorCenterXToSuperview()
        
        changeProfileImageButton.anchor(profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 20)
        
        changeProfileImageButton.anchorCenterXToSuperview()
        
        bottomSeperatorView.anchor(nil, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        
        tableView.tableHeaderView = headerView
    }
    
    fileprivate func createCellWithOptions(input: Input) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = input.selection ? .default : .none
        
        let inputView = input.inputView
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: input.titleFontSize)
        label.text = input.title
        
        let bottomBorderLineView = UIView()
        bottomBorderLineView.backgroundColor = UIColor(r: 236, g: 236, b: 236)
        
        cell.addSubview(label)
        cell.addSubview(inputView)
        cell.addSubview(bottomBorderLineView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        inputView.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderLineView.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 14).isActive = true
        label.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: cell.widthAnchor, multiplier: 0.3).isActive = true
        
        inputView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        inputView.leadingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
        inputView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16).isActive = true
        inputView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        
        bottomBorderLineView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        bottomBorderLineView.leadingAnchor.constraint(equalTo: inputView.leadingAnchor).isActive = true
        bottomBorderLineView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16).isActive = true
        bottomBorderLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        return cell
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ProfileEditController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            let biograpyController = BiographyController()
            biograpyController.bioText = bioTextField.text
            navigationController?.pushViewController(biograpyController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 50
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let sectionView = UIView()
            
            let label  = UILabel()
            label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            label.text = "Gizli Bilgiler"
            
            sectionView.addSubview(label)
            
            label.anchor(sectionView.topAnchor, left: sectionView.leftAnchor, bottom: sectionView.bottomAnchor, right: sectionView.rightAnchor, topConstant: 0, leftConstant: 14, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            return sectionView
        }
        return UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return inputs.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createCellWithOptions(input: inputs[indexPath.row])
    }
    
    fileprivate func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 18)
        return textField
    }
}
