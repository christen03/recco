//
//  Toast.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import Foundation
import SwiftUI

enum ToastStyle {
  case error
  case warning
  case success
  case info
}

extension ToastStyle {
  var themeColor: Color {
    switch self {
    case .error: return Color.red
    case .warning: return Color.orange
    case .info: return Color.blue
    case .success: return Color.green
    }
  }
  
  var iconFileName: String {
    switch self {
    case .info: return "info.circle.fill"
    case .warning: return "exclamationmark.triangle.fill"
    case .success: return "checkmark.circle.fill"
    case .error: return "xmark.circle.fill"
    }
  }
}

struct Toast: Equatable {
  var style: ToastStyle
  var message: String
  var duration: Double = 3
  var width: Double = .infinity
}
