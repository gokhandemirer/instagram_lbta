//
//  ProfileDatasource.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 5.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents

class ProfileDatasource: Datasource {
    
    var user: User?
    
    override func numberOfItems(_ section: Int) -> Int {
        return 1
    }
    
    override func headerItem(_ section: Int) -> Any? {
        return user
    }
    
    override func headerClasses() -> [DatasourceCell.Type]? {
        return [ProfileHeader.self]
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [ProfileCollectionCell.self]
    }
    
}
