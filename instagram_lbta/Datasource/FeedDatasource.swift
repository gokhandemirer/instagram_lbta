//
//  FeedDatasource.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 2.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents

class FeedDatasource: Datasource {
    
    var posts = [Post]()
    
    override func numberOfItems(_ section: Int) -> Int {
        return posts.count
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        return posts[indexPath.item]
    }

    override func cellClasses() -> [DatasourceCell.Type] {
        return [FeedCell.self]
    }

    override func headerClasses() -> [DatasourceCell.Type]? {
        return [FeedHeader.self]
    }
    
}
