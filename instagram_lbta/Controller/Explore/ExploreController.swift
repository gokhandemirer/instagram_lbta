//
//  ExploreController.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 5.06.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import LBTAComponents

class ExploreController: DatasourceController {
    
    lazy var searchController: UISearchController = {
        let resultController = SearchResultController(style: .plain)
        resultController.exploreController = self
        let sc = UISearchController(searchResultsController: resultController)
        sc.searchResultsUpdater = resultController
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.autocapitalizationType = .none
        sc.searchBar.autocorrectionType = .no
        return sc
    }()
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 3 - 1
        return CGSize(width: width, height: width)
    }
    
    func pushToUserProfileControllerWithUser(user: User) {
        let userController = UserController()
        userController.user = user
        
        navigationController?.pushViewController(userController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datasource = ExploreDatasource()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

class ExploreDatasource: Datasource {
    override func numberOfItems(_ section: Int) -> Int {
        return 5
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [ImageCell.self]
    }
}
