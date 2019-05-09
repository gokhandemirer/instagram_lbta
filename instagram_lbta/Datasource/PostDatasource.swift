//
//  PostDatasource.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 5.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents

class PostDatasource: Datasource {
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [FeedCell.self]
    }
    
}
