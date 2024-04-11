//
//  DateTrans.swift
//  stocksApp
//
//  Created by 史导的Mac on 4/11/24.
//

import Foundation

func StringToDate(str: String, format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: str)
}

func DateToString(t: Date, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: "en_US")
    return dateFormatter.string(from: t)
}

func DateFromNow(t: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    let components = calendar.dateComponents([.day, .hour, .minute], from: t, to: now)
    
    guard let days = components.day, let hours = components.hour, let minutes = components.minute else {
        return "0 min"
    }
    
    var result = ""
    if days > 0 {
        result += "\(days) day" + (days > 1 ? "s" : "")
    }
    if !result.isEmpty || days > 0 {
        result += result.isEmpty ? "" : ", "
        result += "\(hours) hr"
    }
    
    if minutes > 0 || result.isEmpty {
        if !result.isEmpty {
            result += ", "
        }
        result += "\(minutes) min"
    }
    if result.isEmpty {
        return "0 min"
    }
    return result
}
