//
//  CoreDataManager.swift
//  NewsApp
//
//  Created by bjit on 13/1/23.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Get All Records
    
    func getAllRecords(category: String, search: String, fetchOffset: Int) -> [ArticleEntity] {
        var articlesArray = [ArticleEntity]()
        do {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<ArticleEntity>(entityName: "ArticleEntity")
            fetchRequest.fetchLimit = 5
            fetchRequest.fetchOffset = fetchOffset
            
            let predicate = NSPredicate(format: "category == %@ && title CONTAINS [c] %@", category, search)
            fetchRequest.predicate = predicate

            articlesArray = try context.fetch(fetchRequest)
            //print(articlesArray)
        }
        catch {
            print(error.localizedDescription)
        }
        return articlesArray
    }
    
    // MARK: - Add Records
    func addRecord(title: String, author: String, publishedAt: String, url: String, urlToImage: String, desc: String, content: String, category: String, context: NSManagedObjectContext) -> [ArticleEntity] {
    
        var item = ArticleEntity(context: context)
        var articlesArray = [ArticleEntity]()
  
        do {
            item.title = title
            item.author = author
            item.publishedAt = publishedAt
            item.url = url
            item.urlToImage = urlToImage
            item.category = category
            item.bookMarked = false
            item.desc = desc
            item.content = content
            
            try context.save()
            articlesArray.append(item)
        }
        catch {
            print(error)
        }
        return articlesArray
    }
    
    
    // MARK: - Update Records (Bookmark)
    func updateRecord(index: Int, val: Bool, articleArray: [ArticleEntity], context: NSManagedObjectContext) -> [ArticleEntity]{
        let item = articleArray[index]
        item.bookMarked = val
        
        do {
            try context.save()
        }
        catch {
            print(error)
        }
        
        return articleArray
    }
    
    // MARK: - Delete (BookMark)
    func deleteRecords(index: Int, bookMarkArray: inout [BookMark], context: NSManagedObjectContext) -> [BookMark]{
        
        let item = bookMarkArray[index]
        context.delete(item)
        
        do {
            try context.save()
            bookMarkArray.remove(at: index)
        }
        catch {
            print(error)
        }
        
        return bookMarkArray
    }
    
    // MARK: - Get All Records (Bookmark)
    func getAllRecordsBookMarked(category: String, search: String) -> [ArticleEntity] {
        var articlesArray = [ArticleEntity]()
        do {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<ArticleEntity>(entityName: "ArticleEntity")
            let predicate = NSPredicate(format: "category == %@ && bookMarked == 1 && title CONTAINS [c] %@", category, search)
            fetchRequest.predicate = predicate

            articlesArray = try context.fetch(fetchRequest)
            print(articlesArray)
        }
        catch {
            print(error.localizedDescription)
        }
        return articlesArray
    }
    
    // MARK: - Add Records (BookMarks)
    func addRecordBookMark(title: String, author: String, publishedAt: String, url: String, urlToImage: String, desc: String, content: String, category: String, context: NSManagedObjectContext) -> [BookMark] {
        
        var item = BookMark(context: context)
        var bookMarkArray = [BookMark]()
  
        do {
            item.title = title
            item.author = author
            item.publishedAt = publishedAt
            item.url = url
            item.urlToImage = urlToImage
            item.category = category
            item.desc = desc
            item.content = content
            
            try context.save()
            bookMarkArray.append(item)
        }
        catch {
            print(error)
        }
        return bookMarkArray
    }
    
    // MARK: - Get Records (BookMarks)
    
    func getAllRecordsBookMark(category: String, search: String) -> [BookMark] {
        var bookMarkArray = [BookMark]()
        do {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<BookMark>(entityName: "BookMark")
            let predicate = NSPredicate(format: "category == %@ && title CONTAINS [c] %@", category, search)
            fetchRequest.predicate = predicate

            bookMarkArray = try context.fetch(fetchRequest)
            print(bookMarkArray)
        }
        catch {
            print(error.localizedDescription)
        }
        return bookMarkArray
    }
    
    // MARK: - Deleting all the value with category
    
    func deleteWithCategory(category: String, context: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<ArticleEntity>(entityName: "ArticleEntity")
        let predicate = NSPredicate(format: "category = %@", category)
        fetchRequest.predicate = predicate

        let objects = try! context.fetch(fetchRequest) as! [NSManagedObject]
        for object in objects {
            context.delete(object)
        }

        try! context.save()
    }
    
    func deleteAll(context: NSManagedObjectContext) {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: ArticleEntity.fetchRequest())

            do {
                try context.execute(deleteRequest)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
    }
    
    func matchUrl(url: String, context: NSManagedObjectContext) -> Bool {
        var bool = false
        let fetchRequest = NSFetchRequest<BookMark>(entityName: "BookMark")
        let predicate = NSPredicate(format: "url = %@", url)
        fetchRequest.predicate = predicate
        
        let objects = try! context.fetch(fetchRequest) as! [NSManagedObject]
        if !objects.isEmpty {
            bool = true
        }
        return bool
    }
}
