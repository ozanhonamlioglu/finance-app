//
//  Date+Extensions.swift
//  ios-dca-calculator
//
//  Created by ozan honamlioglu on 8.06.2021.
//

import Foundation

extension Date {
    
    var MMYYFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
}
