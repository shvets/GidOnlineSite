import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GidOnlineController: BaseCollectionViewController {
  let CELL_IDENTIFIER = "GidOnlineCell"

  let MAIN_MENU_ITEMS = [
    "BOOKMARKS",
    "HISTORY",
    "ALL_MOVIES",
    "GENRES",
    "THEMES",
    "FILTERS",
    "SEARCH",
    "SETTINGS"
  ]

  let service = GidOnlineService.shared

  var document: Document?

  static public func instantiate() -> Self {
    return AppStoryboard.instantiateController("GidOnline", bundle: Bundle.main, viewControllerClass: self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 150.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 20.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    adapter = GidOnlineServiceAdapter()

    self.clearsSelectionOnViewWillAppear = false

    for name in MAIN_MENU_ITEMS {
      let item = MediaItem(name: name)

      items.append(item)
    }

    do {
      document = try service.fetchDocument(GidOnlineAPI.SITE_URL)
    }
    catch {
      print("Cannot load document")
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

    let requestType = selectedCell.item!.name

    if requestType == "GENRES" {
      performSegue(withIdentifier: GenresGroupController.SEGUE_IDENTIFIER, sender: gesture.view)
    }
    else if requestType == "THEMES" {
      performSegue(withIdentifier: GOThemesController.SEGUE_IDENTIFIER, sender: gesture.view)
    }
    else if requestType == "FILTERS" {
      performSegue(withIdentifier: FiltersController.SEGUE_IDENTIFIER, sender: gesture.view)
    }
    else if requestType == "SETTINGS" {
      performSegue(withIdentifier: "Settings", sender: gesture.view)
    }
    else if requestType == "SEARCH" {
      let destination = SearchController.instantiate()

      adapter.requestType = "SEARCH"
      adapter.parentName = "SEARCH"

      destination.adapter = adapter

      self.present(destination, animated: false, completion: nil)
    }
    else {
      let destination = MediaItemsController.instantiate()

      adapter.requestType = requestType
      adapter.parentName = requestType

      destination.adapter = adapter

      destination.collectionView?.collectionViewLayout = adapter.buildLayout()!

      self.show(destination, sender: destination)
    }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GenresGroupController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? GenresGroupController {
            destination.document = document
          }
        case GOThemesController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? GOThemesController {
            destination.document = document
          }
        case FiltersController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? FiltersController {
            destination.document = document
          }
        default: break
      }
    }
   }

}
