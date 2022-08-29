//
//  Numeric+Extension.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Foundation

// MARK: - Format number space between thousands
extension Formatter {
  static let withSeparator: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.groupingSeparator = " "
    formatter.numberStyle = .decimal
    return formatter
  }()
}
extension Numeric {
  var formattedWithSeparator: String {
    return Formatter.withSeparator.string(for: self) ?? ""
  }
}
