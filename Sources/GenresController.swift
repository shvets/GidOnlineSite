import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GenresController: BaseCollectionViewController {
  static let SEGUE_IDENTIFIER = "Genres"
  let CELL_IDENTIFIER = "GenreCell"

  let service = GidOnlineService.shared

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 150.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 20.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    //adapter = GidOnlineServiceAdapter()

    do {
      let genres = try service.getGenres(document!, type: adapter.parentId!) as! [[String: String]]

      for genre in genres {
//        if adapter?.languageManager?.getLocale() == "en" {
//          name = (GENRES_MAP[name] != nil) ? GENRES_MAP[name]! : name
//        }

        let item = MediaItem(name: genre["name"]!, id: genre["id"]!)

        items.append(item)
      }
    }
    catch {
      print("Error getting document")
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
    let selectedCell = gesture.view as! MediaNameCell

    let destination = MediaItemsController.instantiate()

    adapter.requestType = "MOVIES"

    adapter.selectedItem = getItem(for: selectedCell)

    destination.adapter = adapter

    destination.collectionView?.collectionViewLayout = adapter.buildLayout()!

    self.show(destination, sender: destination)
  }

}
