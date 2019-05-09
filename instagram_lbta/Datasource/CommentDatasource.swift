//
//  CommentDatasource.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 8.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents

class CommentDatasource: Datasource {
    override func numberOfItems(_ section: Int) -> Int {
        return 3
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [CommentCell.self]
    }
}
