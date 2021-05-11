//
//  Extension+String.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-11.
//

import Foundation

extension String {
    var removingSpaces: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}
