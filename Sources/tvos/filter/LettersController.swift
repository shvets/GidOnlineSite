import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class LettersController: GidOnlineCollectionViewController {
  static let SegueIdentifier = "Letters"

  override open var CellIdentifier: String { return "LettersCell" }

  var document: Document?
  var requestType: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 20.0
    layout.minimumLineSpacing = 50.0

    collectionView?.collectionViewLayout = layout

    adapter = GidOnlineServiceAdapter()

    for letter in GidOnlineAPI.CyrillicLetters {
      if !["Ё", "Й", "Щ", "Ъ", "Ы", "Ь"].contains(letter) {
        items.append(MediaItem(name: letter))
      }
    }
  }

  // MARK: UICollectionViewDataSource

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! MediaNameCell

    let item = items[indexPath.row]

    let localizedName = localizer.localize(item.name!)

    cell.configureCell(item: item, localizedName: localizedName, target: self)
    CellHelper.shared.addGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))

    return cell
  }

  override func tapped(_ gesture: UITapGestureRecognizer) {
    performSegue(withIdentifier: "Letter", sender: gesture.view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
      case LetterController.SegueIdentifier:
        if let destination = segue.destination as? LetterController,
           let selectedCell = sender as? MediaNameCell {
          adapter.requestType = "LETTER"

          let mediaItem =  getItem(for: selectedCell)

          adapter.parentId = mediaItem.name
          adapter.parentName = localizer.localize(requestType!)

          destination.adapter = adapter
          destination.document = document
          destination.requestType = requestType
        }

      default: break
      }
    }
  }
}
