
import Foundation
import UIKit

class ShopViewController: UIViewController {
  // MARK: - Properties
  // swiftlint:disable:next implicitly_unwrapped_optional
  var shop: Store!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    title = shop?.name
  }
}

// MARK: - UICollectionViewDataSource
extension ShopViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return shop.inventory.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    // swiftlint:disable force_cast
    let imageView = cell.viewWithTag(1) as! UIImageView
    let label = cell.viewWithTag(2) as! UILabel
    // swiftlint:enable force_cast

    let item = shop.inventory[indexPath.row]
    imageView.image = Game.shared.image(for: item)

    let price = item.cost
    label.text = "💰\(price)"

    cell.layer.cornerRadius = 8
    cell.layer.borderColor = UIColor.black.cgColor
    cell.layer.borderWidth = 1

    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension ShopViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = shop.inventory[indexPath.row]
    _ = Game.shared.purchaseItem(item: item)
    _ = navigationController?.popViewController(animated: true)
  }
}
