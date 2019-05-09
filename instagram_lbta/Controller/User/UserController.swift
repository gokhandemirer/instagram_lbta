//
//  UserController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 11.06.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents

class UserController: DatasourceController {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.username
            
            datasource = UserDatasource()
            (datasource as? UserDatasource)?.user = user
            
            collectionView?.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

class UserDatasource: Datasource {
    
    var user: User?
    
    override func headerItem(_ section: Int) -> Any? {
        return user
    }
    
    override func headerClasses() -> [DatasourceCell.Type]? {
        return [ProfileHeader.self]
    }
}
