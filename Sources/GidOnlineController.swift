import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

open class GidOnlineController: BaseCollectionViewController {
  let CellIdentifier = "GidOnlineCell"

  let MainMenuItems = [
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
    let bundle = Bundle(identifier: "com.rubikon.GidOnlineSite")!

    return AppStoryboard.instantiateController("GidOnline", bundle: bundle, viewControllerClass: self)
  }

  override open func viewDidLoad() {
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

    for name in MainMenuItems {
      let item = MediaItem(name: name)

      items.append(item)
    }

    do {
      document = try service.fetchDocument(GidOnlineAPI.SiteUrl)
    }
    catch {
      print("Cannot load document")
    }
  }

  // MARK: UICollectionViewDataSource

  override open func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! MediaNameCell

    let item = items[indexPath.row]

    let localizedName = adapter?.languageManager?.localize(item.name!) ?? "Unknown"

    cell.configureCell(item: item, localizedName: localizedName, target: self, action: #selector(self.tapped(_:)))

    return cell
  }

  func tapped(_ gesture: UITapGestureRecognizer) {
    let selectedCell = gesture.view as! MediaNameCell

    let requestType = getItem(for: selectedCell).name

    if requestType == "GENRES" {
      performSegue(withIdentifier: GenresGroupController.SegueIdentifier, sender: gesture.view)
    }
    else if requestType == "THEMES" {
      performSegue(withIdentifier: ThemesController.SegueIdentifier, sender: gesture.view)
    }
    else if requestType == "FILTERS" {
      performSegue(withIdentifier: FiltersController.SegueIdentifier, sender: gesture.view)
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

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GenresGroupController.SegueIdentifier:
          if let destination = segue.destination as? GenresGroupController {
            destination.document = document
          }
        case ThemesController.SegueIdentifier:
          if let destination = segue.destination as? ThemesController {
            destination.document = document
          }
        case FiltersController.SegueIdentifier:
          if let destination = segue.destination as? FiltersController {
            destination.document = document
          }
        default: break
      }
    }
   }

}