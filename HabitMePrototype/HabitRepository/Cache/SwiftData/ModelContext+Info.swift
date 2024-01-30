//
//  ModelContext+Info.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/30/24.
//

import SwiftData




extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
