//
//  API.swift
//  NewsApp
//
//  Created by bjit on 15/1/23.
//

import Foundation
import UIKit
import CoreData

class API {
    
    static let shared = API()
    
    private init() {}
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getDataFromApi(category: String, completion: @escaping (News?) -> Void){
        
        var result: News?
        
        //let url = "https://newsapi.org/v2/top-headlines?country=us&\(category)&apiKey=07b73d94f9564ad8bcec73410149b399"
        //let url = "https://newsapi.org/v2/top-headlines?country=us&\(category)&apiKey=da016b89a32e44a2b3716f2089ceedf3"
        //let url = "https://newsapi.org/v2/top-headlines?country=us&category=\(category)&apiKey=fd855bda16fe43e0b09265b79e3b388f"
        let url = "https://newsapi.org/v2/top-headlines?country=us&category=\(category)&apiKey=135c59f5fc124d3abaa8839e92906a5b"
        
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            
            print("\n\n\nURLSession.shared.dataTask Started\n\n\n")
            
            guard let data = data, error == nil else {
                print("Error: ", error)
                return
            }
            print(data)
            do {
                let decoder = JSONDecoder()
                //decoder.dateDecodingStrategy = .iso8601
                result = try decoder.decode(News.self, from: data)
            }
            catch {
                print(error.localizedDescription)
                return
            }

            guard let json = result else {
                print("Error :(")
                return
            }
            completion(json)
            
        }
        task.resume()
    }
}
