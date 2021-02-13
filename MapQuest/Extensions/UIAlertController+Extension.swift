
import UIKit

extension UIAlertController {
  func addActions(actions: [UIAlertAction]) {
    actions.forEach { action in
      self.addAction(action)
    }
  }
}
