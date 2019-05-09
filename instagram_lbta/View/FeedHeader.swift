//
//  FeedHeader.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 3.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents

class FeedHeader: DatasourceCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hikayeler"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let watchAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tümünü İzle", for: .normal)
        button.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysOriginal), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let topBorderLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(r: 219, g: 219, b: 219)
        return lineView
    }()
    
    lazy var storyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 24
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = UIColor(r: 250, g: 250, b: 250)
        
        separatorLineView.isHidden = false
        
        separatorLineView.backgroundColor = UIColor(r: 219, g: 219, b: 219)
        
        addSubview(topBorderLineView)
        addSubview(titleLabel)
        addSubview(watchAllButton)
        
        topBorderLineView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
        
        titleLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)

        watchAllButton.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 4, widthConstant: 100, heightConstant: 20)
        
        setupCollectionView()
        
    }
    
    func setupCollectionView() {
        
        storyCollectionView.register(StoryCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(storyCollectionView)
        
        storyCollectionView.anchor(titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 57, height: collectionView.bounds.height)
    }
}

class StoryCell: DatasourceCell {
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "me")
        iv.layer.cornerRadius = frame.width / 2
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 0.5
        iv.layer.borderColor = UIColor(r: 219, g: 219, b: 219).cgColor
        iv.backgroundColor = .purple
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.text = "gokhandemirerr"
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addSubview(nameLabel)
        
        imageView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 57)
        
        nameLabel.anchor(imageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 15)
    }
}
