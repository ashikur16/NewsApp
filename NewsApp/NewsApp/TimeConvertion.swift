//
//  TimeConvertion.swift
//  NewsApp
//
//  Created by bjit on 18/1/23.
//

import Foundation

class TimeConvertion {
    
    static let shared = TimeConvertion()
    
    private init() {}
    
    func timeSubtract(dateTimeString: String) -> Double {
        
        let removeT = cutTimeString(dateTimeString: dateTimeString, oldChar: "T", newChar: " ")
        let removeZ = cutTimeString(dateTimeString: removeT, oldChar: "Z", newChar: "")
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let date = dateFormatter.date(from: removeZ) else {
            print("Error: Invalid date and time format")
            return 0.0
        }

        let currentDate = Date()

        let timeInterval = currentDate.timeIntervalSince(date)

//        let days = timeInterval / (60 * 60 * 24)
        let hours = (timeInterval.truncatingRemainder(dividingBy: 86400)) / (60 * 60)
//        let minutes = (timeInterval.truncatingRemainder(dividingBy: 3600)) / 60
//        let seconds = timeInterval.truncatingRemainder(dividingBy: 60)

        return hours
    }
    
    func cutTimeString(dateTimeString: String, oldChar: String, newChar: String) -> String {
        
        let newString = dateTimeString.replacingOccurrences(of: oldChar, with: newChar)
        return newString
    }
    
    func timeSubtractForCertainTime(dateTimeString: String) -> Double {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let date = dateFormatter.date(from: dateTimeString) else {
            print("Error: Invalid date and time format")
            return 0.0
        }

        let currentDate = Date()

        let timeInterval = currentDate.timeIntervalSince(date)

//        let days = timeInterval / (60 * 60 * 24)
        //let hours = (timeInterval.truncatingRemainder(dividingBy: 86400)) / (60 * 60)
        let minutes = (timeInterval.truncatingRemainder(dividingBy: 3600)) / 60
//        let seconds = timeInterval.truncatingRemainder(dividingBy: 60)

        return minutes
    }
}
