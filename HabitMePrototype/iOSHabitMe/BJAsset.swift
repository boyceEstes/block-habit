//
//  BJAsset.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/9/24.
//

import Foundation
import SwiftUI


enum BJAsset: String, CustomStringConvertible {
    
    case numberSquare = "number.square" // Number Detail
    case characterBubble = "character.bubble" // Text Detail
    
    case minusCircle = "minus.circle"
    case checkmark = "checkmark"
    case tip = "info.circle" // Tip
    case restore = "arrow.up.bin.fill" // Unarchive/Restore
    case archive = "archivebox"
    case trash = "trash"
    case edit = "pencil.circle"
    case detail = "doc.text.magnifyingglass"
    
    /// access string by typecasting `AssetLibrary` instance.
    ///
    /// Example:
    /// ```String(AssetLibrary.numberSquare)```
    var description: String {
        return self.rawValue
    }
    
    
    func image() -> Image {
        Image(systemName: self.rawValue)
    }
}
