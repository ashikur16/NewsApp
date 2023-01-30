//
//  Search.swift
//  NewsApp
//
//  Created by bjit on 13/1/23.
//

import Foundation
import UIKit

class SearchNews {
    
    static let shared = SearchNews()
    
    private init () {}
    
    func createSearchBar(searchBar: UITextField) {
        let imageIcon = UIImageView()
        imageIcon.image = UIImage(systemName: "magnifyingglass")
        imageIcon.tintColor = .black
        
        let contentView = UIView()
        contentView.addSubview(imageIcon)
        
        contentView.frame = CGRect(x: 0, y: 0, width: UIImage(systemName: "magnifyingglass")!.size.width, height: UIImage(systemName: "magnifyingglass")!.size.height)
        
        imageIcon.frame = CGRect(x: 5, y: 0, width: UIImage(systemName: "magnifyingglass")!.size.width, height: UIImage(systemName: "magnifyingglass")!.size.height)
        
        searchBar.leftView = contentView
        searchBar.leftViewMode = .always
        searchBar.clearButtonMode = .whileEditing
    }
}
