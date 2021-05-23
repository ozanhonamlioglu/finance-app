//
//  APIService.swift
//  ios-dca-calculator
//
//  Created by ozan honamlioglu on 16.05.2021.
//

import Foundation
import Combine

struct APIService {
    var API_KEY: String {
        return keys.randomElement()!
    }
    
    let keys = ["DPE9271SOKOR5X7V", "NQAR1PPKHWGO0S3Q", "23YU7MGBSDSOHHOE"]
    
    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchResults, Error> {
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(API_KEY)"
        
        // utf8 character problem solver
        let data = urlString.data(using: String.Encoding.utf8)
        let url = URL(dataRepresentation: data!, relativeTo: nil)!

        // let url = URL(string: urlString)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map{ $0.data }
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
 
