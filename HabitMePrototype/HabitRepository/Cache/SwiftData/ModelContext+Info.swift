//
//  ModelContext+Info.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/30/24.
//

import SwiftData
import Foundation



extension ModelContext {
    
    var sqliteStore: URL? {
        return container.configurations.first?.url
    }
    
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
