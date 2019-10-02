//
//  UITableView+Scroll.swift
//  AUIKit
//
//  Created by Ihor Myroniuk on 10/2/19.
//

import UIKit

public extension UITableView {
  func scrollToTop(animated: Bool) {
    if numberOfRows(inSection: 0) > 0 {
      let indexPath = IndexPath()
      scrollToRow(at: indexPath, at: .top, animated: false)
    }
  }
}
