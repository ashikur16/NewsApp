//
//  ViewController.swift
//  NewsApp
//
//  Created by bjit on 12/1/23.
//

import UIKit
import CoreData
import SDWebImage

class ViewController: UIViewController {
    
    var result: News?
    var totNumOfRows: Int!
    //var flag: Bool!
    var search = " "
    var category = (CategoryData.categories[0])
    var desc = ""
    var content = ""
    var img = ""
    var url = ""
    var previousTime: Date!
    var index = 0
    var catIndex = 0
    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var articlesArray = [ArticleEntity]()
    var bookMarkArray = [BookMark]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        collectionView.delegate = self
        collectionView.dataSource = self

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        SearchNews.shared.createSearchBar(searchBar: searchBar)
        
        articlesArray = CoreDataManager.shared.getAllRecords(category: (CategoryData.categories[0]), search: search, fetchOffset: 0)
        
        // MARK: - When CoreData is Empty
        if articlesArray.count == 0 {
            
            print("articlesArray.count: ", articlesArray.count)
            activityIndicator.startAnimating()
            getApiAndSaveCoreData(index: 0, category: "") { [weak self] in
                if let self = self {
                    self.articlesArray = CoreDataManager.shared.getAllRecords(category: CategoryData.categories[0], search: self.search, fetchOffset: 0)
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
        else {
            tableView.reloadData()
        }
        //tableView.reloadData()
        
        
        // MARK: - Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        
        // MARK: - Auto refresh
        let timeBool = UserDefaults.standard.bool(forKey: Identifier.timeKeyBool)
        
        if timeBool == false {
            UserDefaults.standard.set(Date(), forKey: Identifier.timeKey)
            UserDefaults.standard.set(true, forKey: Identifier.timeKeyBool)
        }

        autoRefreshAfterCertainTime()
    }
    
    @objc func refresh() {
        CoreDataManager.shared.deleteWithCategory(category: category, context: context)
        
        if index == 0 {
            getApiAndSaveCoreData(index: index, category: "") { [weak self] in
                if let self = self {
                    self.tableView.refreshControl?.endRefreshing()
                    self.articlesArray = CoreDataManager.shared.getAllRecords(category: self.category, search: self.search, fetchOffset: 0)
                    self.tableView.reloadData()
                    print("\n\n\n\nUpdate Completed\n\n\n\n")
                }
            }
        }
        else {
            getApiAndSaveCoreData(index: index, category: category) { [weak self] in
                if let self = self {
                    self.tableView.refreshControl?.endRefreshing()
                    self.articlesArray = CoreDataManager.shared.getAllRecords(category: self.category, search: self.search, fetchOffset: 0)
                    self.tableView.reloadData()
                    print("\n\n\n\nUpdate Completed\n\n\n\n")
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.HomeToDetail {
            let destinationVC = segue.destination as! DetailNewsViewController
            destinationVC.desc = desc
            destinationVC.content = content
            destinationVC.img = img
            destinationVC.url = url
        }
    }
}

// MARK: - Collection View
extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.row
        category = CategoryData.categories[indexPath.row]
        
        print(indexPath)
        print(searchBar.text!)
        print(category)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            cell.categoryLabel.textColor = .black
            
        }
        articlesArray = CoreDataManager.shared.getAllRecords(category: category, search: search, fetchOffset: 0)
        
        if articlesArray.count == 0 {
            activityIndicator.startAnimating()
            getApiAndSaveCoreData(index: indexPath.row, category: category) { [weak self] in
                if let self = self {
                    self.articlesArray = CoreDataManager.shared.getAllRecords(category: self.category, search: self.search, fetchOffset: 0)
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            cell.categoryLabel.textColor = .systemGray
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CategoryData.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.collectionViewCell, for: indexPath) as! CustomCollectionViewCell
        cell.categoryLabel.text = CategoryData.categories[indexPath.row]
        
        cell.categoryLabel.textColor = .gray
        return cell
    }
}

// MARK: - Table View
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        if let desc1 = articlesArray[indexPath.row].desc, let content1 = articlesArray[indexPath.row].content, let img1 = articlesArray[indexPath.row].urlToImage, let url1 = articlesArray[indexPath.row].url {
            desc = desc1
            content = content1
            img = img1
            url = url1
        }
        performSegue(withIdentifier: Identifier.HomeToDetail, sender: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.tableViewCell, for: indexPath) as! CustomTableViewCell
        
        if !articlesArray.isEmpty {
            let image = articlesArray[indexPath.row].urlToImage
            if let image = image {
                cell.imgView.sd_setImage(with: URL(string: image))
                //print("SD Image: ", image)
            }
            else {
                cell.imgView.image = UIImage(systemName: "trash")
            }

            cell.titleLabel.text = articlesArray[indexPath.row].title
            cell.authorLabel.text = articlesArray[indexPath.row].author
            
            var hour = 0.0
            
            if let publishedAt = articlesArray[indexPath.row].publishedAt {
                hour = TimeConvertion.shared.timeSubtract(dateTimeString: publishedAt)
            }
            
            if Int(hour) == 0 {
                cell.dateLabel.text = "Recent News"
            }
            else if Int(hour) > 0 && Int(hour) < 24 {
                cell.dateLabel.text = "\(String(Int(hour))) hour(s) ago"
            }
            
            else {
                cell.dateLabel.text = "\(String(Int(hour))) day(s) ago"
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var paginationArray = [ArticleEntity]()
        if indexPath.row == articlesArray.count - 1 {
            paginationArray = CoreDataManager.shared.getAllRecords(category: category, search: search, fetchOffset: articlesArray.count)
            articlesArray.append(contentsOf: paginationArray)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        category = articlesArray[indexPath.row].category!
        
        let bookMarkAction = UIContextualAction(style: .destructive, title: nil) {[weak self] _,_,completed in
            guard let self = self else {return}

//            self.articlesArray = CoreDataManager.shared.updateRecord(index: indexPath.row, val: true , articleArray: self.articlesArray, context: self.context)
            
            if CoreDataManager.shared.matchUrl(url: self.articlesArray[indexPath.row].url ?? "", context: self.context) {
                self.alertFunc(title: "Book Mark Status", message: "Already BookMarked")
            }
            else {
                self.addRecordBookMark(title: (self.articlesArray[indexPath.row].title) ?? "", author: (self.articlesArray[indexPath.row].author) ?? "", publishedAt: (self.articlesArray[indexPath.row].publishedAt) ?? "", url: (self.articlesArray[indexPath.row].url) ?? "", urlToImage: self.articlesArray[indexPath.row].urlToImage ?? "", desc: (self.articlesArray[indexPath.row].desc) ?? "", content: (self.articlesArray[indexPath.row].content) ?? "", category: self.category)
                
                tableView.reloadData()
                self.alertFunc(title: "Book Mark Status", message: "Successfully BookMarked")
            }
            
        }
        bookMarkAction.image = UIImage(systemName: "bookmark")
        bookMarkAction.backgroundColor = .systemBlue
        
        let swipAction = UISwipeActionsConfiguration(actions: [bookMarkAction])
        return swipAction
    }
}


// MARK: - TextField Delegate
extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        search = searchBar.text!
        articlesArray = CoreDataManager.shared.getAllRecords(category: category, search: search, fetchOffset: 0)
        tableView.reloadData()
        return true
    }
}

// MARK: - Functions
extension ViewController {
    func getAllRecords(category: String) {
        articlesArray = CoreDataManager.shared.getAllRecords(category: category, search: search, fetchOffset: 0)
        tableView.reloadData()
    }
    
    func addRecord(title: String, author: String, publishedAt: String, url: String, urlToImage: String, desc: String, content: String, category: String) {
        articlesArray = CoreDataManager.shared.addRecord(title: title, author: author, publishedAt: publishedAt, url: url, urlToImage: urlToImage, desc: desc, content: content, category: category, context: context)
    }
    
    func addRecordBookMark(title: String, author: String, publishedAt: String, url: String, urlToImage: String, desc: String, content: String, category: String) {
        bookMarkArray = CoreDataManager.shared.addRecordBookMark(title: title, author: author, publishedAt: publishedAt, url: url, urlToImage: urlToImage, desc: desc, content: content, category: category, context: context)
    }
    
    func getApiAndSaveCoreData(index: Int, category: String, comletion: @escaping () -> ()) {
        let group = DispatchGroup()
        
        group.enter()
        API.shared.getDataFromApi(category: category) { [weak self] x in
             if let self = self {
                 self.result = x
                 for j in 0..<(self.result!.articles.count) {
                     self.addRecord(title: (self.result?.articles[j].title) ?? " ", author: (self.result?.articles[j].author) ?? " ", publishedAt: (self.result?.articles[j].publishedAt) ?? " ", url: (self.result?.articles[j].url) ?? " ", urlToImage: self.result?.articles[j].urlToImage ?? " ", desc: (self.result?.articles[j].description) ?? " ", content: (self.result?.articles[j].content) ?? "", category: CategoryData.categories[index])
                 }
                 print("Category: ",category)
                 print("self.result?.articles", self.result?.articles)
             }
            group.leave()
         }
        group.notify(queue: DispatchQueue.main) {
            comletion()
        }
    }
    
    func autoRefreshAfterCertainTime() {
        
        let time = UserDefaults.standard.object(forKey: "timeKey") as? Date
        print(time)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: time!)
        
        let calculatedTime = TimeConvertion.shared.timeSubtractForCertainTime(dateTimeString: dateString) // calculatedTime is in minute

        if Int(calculatedTime) >= 30 {

            print("Delete all data from entity")
            CoreDataManager.shared.deleteAll(context: context)

            print("autoRefreshAfterCertainTime")
            activityIndicator.startAnimating()
            getApiAndSaveCoreData(index: 0, category: "") { [weak self] in
                if let self = self {
                    self.articlesArray = CoreDataManager.shared.getAllRecords(category: CategoryData.categories[0], search: self.search, fetchOffset: 0)
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
            print("Print calculatedTime: ", Int(calculatedTime))
            UserDefaults.standard.set(Date(), forKey: Identifier.timeKey) // Updating the time agaain
        }
    }
    
    func alertFunc(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
}
