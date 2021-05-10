//
//  APIService.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation

enum APIService {
    struct ErrorType: Identifiable {
        let id = UUID()
        let error: APIError
    }
    
        public enum APIError: Error {
             case error(_ errorString: String)
         }
         
         /// All Purpose API JSON Request
         /// - Parameters:
         ///   - urlString: The URL String for the API
         ///   - dateDecodingStategy: the JSONDecoder dateDecoding strategy if needed.  Default is .deferredToDate
         ///   - keyDecodingStrategy: the JSONDecoder keyDecoding Strategy if needed.  Default is .useDefaultKeys
         ///   - completion: Closure passed from the call location (Result<T,APIError>) -> Void
         public static func getJSON<T: Decodable>(urlString: String,
                                    dateDecodingStategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                                    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                                    completion: @escaping (Result<T,APIError>) -> Void) {
             guard let url = URL(string: urlString) else {
                completion(.failure(.error("Invalid URL")))
                 return
             }
             let request = URLRequest(url: url)
             URLSession.shared.dataTask(with: request) { (data, response, error) in
                 if let error = error {
                     completion(.failure(.error("URLError: \(error.localizedDescription)")))
                     return
                 }
                 guard let data = data else {
                     completion(.failure(.error("Error: Data is corrupt.")))
                     return
                 }
                 let decoder = JSONDecoder()
                 decoder.dateDecodingStrategy = dateDecodingStategy
                 decoder.keyDecodingStrategy = keyDecodingStrategy
                 
                 guard let decodedData = try? decoder.decode(T.self, from: data) else {
                     completion(.failure(.error("Error: decoding data.")))
                     return
                 }
                 completion(.success(decodedData))
             }.resume()
         }

    }

