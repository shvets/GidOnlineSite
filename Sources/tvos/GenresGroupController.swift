import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GenresGroupController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  static let SegueIdentifier = "Genres Group"
  let CellIdentifier = "GenreGroupCell"

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  let GENRES_MENU = [
    "Family",
    "Crime",
    "Fiction",
    "Education"
  ]

  private var items = Items()
  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    setupLayout()

    items.pageLoader.load = {
      return self.loadGenresMenu()
    }

    items.loadInitialData(collectionView)

    //adapter = GidOnlineServiceAdapter()
  }

 func loadGenresMenu() -> [Item] {
    var items = [Item]()

    for name in GENRES_MENU {
      let item = Item(name: name)

      items.append(item)
    }
    return items
  }

  func setupLayout() {
    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 10.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout
  }

  override open func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? MediaNameCell {
      if let item = items[indexPath.row] as? MediaName {
         cell.configureCell(item: item, localizedName: localizer.getLocalizedName(item.name), target: self)
      }

      CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))

      return cell
    }
    else {
      return UICollectionViewCell()
    }
  }

  @objc open func tapped(_ gesture: UITapGestureRecognizer) {
    performSegue(withIdentifier: GenresController.SegueIdentifier, sender: gesture.view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GenresController.SegueIdentifier:
          if let destination = segue.destination as? GenresController,
             let selectedCell = sender as? MediaNameCell,
             let indexPath = collectionView?.indexPath(for: selectedCell) {
            let adapter = GidOnlineServiceAdapter()

            destination.params["requestType"] = "Genres"

            let mediaItem = items.getItem(for: indexPath)

            adapter.params["parentId"] = mediaItem.name
            destination.params["parentName"] = localizer.localize(mediaItem.name!)

            destination.adapter = adapter
            destination.document = document
          }

        default: break
      }
    }
  }
}
