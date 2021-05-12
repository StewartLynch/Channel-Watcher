//
//  DateFormatter+Extension.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-12.
//

import Foundation

extension DateFormatter {
    static let mediumDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none

        return df
    }()

    static let mediumTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .medium

        return df
    }()

    static let mediumDateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium

        return df
    }()

    static let ytDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}


