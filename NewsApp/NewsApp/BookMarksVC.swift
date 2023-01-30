//
//  BookMarksVC.swift
//  NewsApp
//
//  Created by bjit on 14/1/23.
//

import UIKit

class BookMarksVC: UIViewController {
  
    var articlesArray = [ArticleEntity]()
    var bookMarkArray = [BookMark]()
    var search = " "
    var category = CategoryData.categories[0]
    var desc = ""
    var content = ""
    var img = ""
    var url = ""
    var index = 0
    

    @IBOutlet weak var searchBar: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        SearchNews.shared.createSearchBar(searchBar: searchBar)
        bookMarkArray = CoreDataManager.shared.getAllRecordsBookMark(category: category, search: search)
        tableView.reloadData()

        tableView.delegate = self
        tableView.dataSource = self

        collectionView.delegate = self
        collectionView.dataSource = self

        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bookMarkArray = CoreDataManager.shared.getAllRecordsBookMark(category: category, search: search)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.BookMarksToDetail {
            let destinationVC = segue.destination as! DetailNewsViewController
            destinationVC.desc = desc
            destinationVC.content = content
            destinationVC.img = img
            destinationVC.url = url
        }
    }
}

extension BookMarksVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        if let desc1 = bookMarkArray[indexPath.row].desc, let content1 = bookMarkArray[indexPath.row].content, let img1 = bookMarkArray[indexPath.row].urlToImage, let url1 = bookMarkArray[indexPath.row].url {
            desc = desc1
            content = content1
            img = img1
            url = url1
        }
        performSegue(withIdentifier: Identifier.BookMarksToDetail, sender: nil)
    }
}

extension BookMarksVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookMarkArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.BookmarksTableViewCell, for: indexPath) as! CustomBookmarksTableViewCell
        
        let image = bookMarkArray[indexPath.row].urlToImage
        if let image = image {
            cell.imgView.sd_setImage(with: URL(string: image))
            print("SD Image: ", image)
        }
        else {
            cell.imgView.image = UIImage(systemName: "trash")
        }

        cell.titleLabel.text = bookMarkArray[indexPath.row].title
        cell.authorLabel.text = bookMarkArray[indexPath.row].author
        
        var hour = 0.0
        
        // publishedAt
        if let publishedAt = bookMarkArray[indexPath.row].publishedAt {
            hour = TimeConvertion.shared.timeSubtract(dateTimeString: publishedAt)
        }
        
        if Int(hour) == 0 {
            cell.dateLabel.text = "Recent News"
        }
        else {
            cell.dateLabel.text = "\(String(Int(hour))) hour(s) ago"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {[weak self] _,_,completed in
            guard let self = self else {return}
            
            self.bookMarkArray = CoreDataManager.shared.deleteRecords(index: indexPath.row, bookMarkArray: &self.bookMarkArray, context: self.context)
            self.tableView.reloadData()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        let swipAction = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipAction
    }
}

extension BookMarksVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        index = indexPath.row
        print(index)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomBookmarksCollectionViewCell {
            cell.categoryLabel.textColor = .black
        }
        
        category = CategoryData.categories[indexPath.row]
        print(category)

        bookMarkArray = CoreDataManager.shared.getAllRecordsBookMark(category: category, search: search)
        tableView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomBookmarksCollectionViewCell {
            cell.categoryLabel.textColor = .systemGray
        }
    }
}

extension BookMarksVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CategoryData.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.BookmarksCollectionViewCell, for: indexPath) as! CustomBookmarksCollectionViewCell
        cell.categoryLabel.text = CategoryData.categories[indexPath.row]
        cell.categoryLabel.textColor = .systemGray
        return cell
    }

}

extension BookMarksVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        search = searchBar.text!
        bookMarkArray = CoreDataManager.shared.getAllRecordsBookMark(category: category, search: search)
        tableView.reloadData()
        return true
    }
}
