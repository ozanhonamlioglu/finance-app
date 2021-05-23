//
//  SearchResults.swift
//  ios-dca-calculator
//
//  Created by ozan honamlioglu on 16.05.2021.
//

import Foundation

struct SearchResults: Decodable {
    let items: [ResultItems]
    
    enum CodingKeys: String, CodingKey {
        case items = "bestMatches"
    }
}

struct ResultItems: Decodable {
    let symbol: String
    let name: String
    let type: String
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
        case type = "3. type"
        case currency = "8. currency"
    }
}
