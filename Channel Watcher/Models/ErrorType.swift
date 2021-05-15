//
//  ErrorType.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-12.
//

import Foundation

struct ErrorType: Identifiable {
    let id = UUID()
    let error: APIService.APIError
}
