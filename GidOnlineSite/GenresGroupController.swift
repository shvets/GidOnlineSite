import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GenresGroupController: BaseCollectionViewController {
  static let SEGUE_IDENTIFIER = "GenresGroup"
  let CELL_IDENTIFIER = "GenreGroupCell"

  let GENRES_MENU = [
    "FAMILY",
    "CRIME",
    "FICTION",
    "EDUCATION"
  ]

  let service = GidOnlineService.shared

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 10.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    adapter = GidOnlineServiceAdapter()

    for name in GENRES_MENU {
      let item = MediaItem(name: name)

      items.append(item)
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
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath) as! MediaNameCell

    let item = items[indexPath.row]

    let localizedName = adapter?.languageManager?.localize(item.name!) ?? "Unknown"

    cell.configureCell(item: item, localizedName: localizedName, target: self, action: #selector(self.tapped(_:)))

    return cell
  }

  func tapped(_ gesture: UITapGestureRecognizer) {
    performSegue(withIdentifier: GOGenresController.SEGUE_IDENTIFIER, sender: gesture.view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GOGenresController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? GOGenresController,
             let selectedCell = sender as? MediaNameCell {
            adapter.requestType = "GENRES"
            adapter.parentId = selectedCell.item!.name
            adapter.parentName = selectedCell.item!.name

            destination.adapter = adapter
            destination.document = document
          }

        default: break
      }
    }
  }
}
