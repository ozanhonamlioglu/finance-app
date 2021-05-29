//
//  APIService.swift
//  ios-dca-calculator
//
//  Created by ozan honamlioglu on 16.05.2021.
//

import Foundation
import Combine

struct APIService {
    
    enum APIServiceError: Error {
        case encoding
        case badRequest
    }
    
    var API_KEY: String {
        return keys.randomElement()!
    }
    
    let keys = ["DPE9271SOKOR5X7V", "NQAR1PPKHWGO0S3Q", "23YU7MGBSDSOHHOE"]
    
    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchResults, Error> {
        
        let result = parseQueryString(text: keywords)
        
        var keyword = String()
        
        switch result {
        case .success(let query):
            keyword = query
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keyword)&apikey=\(API_KEY)"
        let parsedUrl = parseURL(urlString: urlString)
        
        switch parsedUrl {
        
        case .success(let data):
            guard let url = URL(dataRepresentation: data, relativeTo: nil) else { return Fail(error: APIServiceError.badRequest).eraseToAnyPublisher() }

            return URLSession.shared.dataTaskPublisher(for: url)
                .map{ $0.data }
                .decode(type: SearchResults.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
            
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
            
        }
        
        
        
    }
    
    func fetchTimeSeriesMonthlyAdjustedPublisher(keywords: String) -> AnyPublisher<TimeSeriesMonthlyAdjusted, Error> {
        
        let result = parseQueryString(text: keywords)
        
        var symbol = String()
        
        switch result {
        case .success(let query):
            symbol = query
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=\(symbol)&apikey=\(API_KEY)"
        let parsedUrl = parseURL(urlString: urlString)
        
        switch parsedUrl {
        
        case .success(let data):
            guard let url = URL(dataRepresentation: data, relativeTo: nil) else { return Fail(error: APIServiceError.badRequest).eraseToAnyPublisher() }

            return URLSession.shared.dataTaskPublisher(for: url)
                .map{ $0.data }
                .decode(type: TimeSeriesMonthlyAdjusted.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
            
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
            
        }
        
        
    }
    
    private func parseQueryString(text: String) -> Result<String, Error> {
        if let text = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return .success(text)
        } else {
            return .failure(APIServiceError.encoding)
        }
    }
    
    private func parseURL(urlString: String) -> Result<Data, Error> {
        
        if let data = urlString.data(using: String.Encoding.utf8) {
            return .success(data)
        } else {
            return .failure(APIServiceError.encoding)
        }
        
    }
    
}
 
