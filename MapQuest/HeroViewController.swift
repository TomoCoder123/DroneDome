import UIKit

class HeroViewController: UIViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!

  // MARK: - View Life Cycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // swiftlint:disable:next discouraged_object_literal
    //avatarImageView.image = #imageLiteral(resourceName: "adventurer")
    
  }
}

// MARK: - UICollectionViewDataSource
extension HeroViewController: UICollectionViewDataSource {
  var inventory: [Item] { return Game.shared.adventurer?.inventory ?? [] }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return inventory.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    // swiftlint:disable force_cast
    let imageView = cell.viewWithTag(1) as! UIImageView
    let label = cell.viewWithTag(2) as! UILabel
    // swiftlint:enable force_cast

    let item = inventory[indexPath.row]
    imageView.image = Game.shared.image(for: item)

    if let weapon = item as? Weapon {
      label.text = "+\(weapon.strength)"
    }

    cell.layer.cornerRadius = 8
    cell.layer.borderColor = UIColor.black.cgColor
    cell.layer.borderWidth = 1

    return cell
  }
}
