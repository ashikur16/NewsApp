//
//  BookMark+CoreDataProperties.swift
//  NewsApp
//
//  Created by bjit on 19/1/23.
//
//

import Foundation
import CoreData


extension BookMark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookMark> {
        return NSFetchRequest<BookMark>(entityName: "BookMark")
    }

    @NSManaged public var author: String?
    @NSManaged public var category: String?
    @NSManaged public var content: String?
    @NSManaged public var desc: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var source_id: String?
    @NSManaged public var source_name: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var urlToImage: String?

}

extension BookMark : Identifiable {

}
