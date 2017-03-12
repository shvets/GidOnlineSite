import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

open class GidOnlineTableViewController: GidOnlineBaseTableViewController {
  override open var CellIdentifier: String { return "GidOnlineTableCell" }

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

  var document: Document?

  override open func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("GidOnline")

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

  override open func navigate(from view: UITableViewCell) {
    let mediaItem = getItem(for: view)

    switch mediaItem.name! {
    case "GENRES":
      performSegue(withIdentifier: GenresGroupController.SegueIdentifier, sender: view)

    case "THEMES":
      performSegue(withIdentifier: ThemesController.SegueIdentifier, sender: view)

    case "FILTERS":
      performSegue(withIdentifier: FiltersController.SegueIdentifier, sender: view)

    case "SETTINGS":
      performSegue(withIdentifier: "Settings", sender: view)

    case "SEARCH":
      performSegue(withIdentifier: SearchController.SegueIdentifier, sender: view)

    default:
      performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
    }
  }

  // MARK: - Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
      case GenresGroupTableViewController.SegueIdentifier:
        if let destination = segue.destination as? GenresGroupTableViewController {
          destination.document = document
        }

      case ThemesTableController.SegueIdentifier:
        if let destination = segue.destination as? ThemesTableController {
          destination.document = document
        }

      case FiltersTableController.SegueIdentifier:
        if let destination = segue.destination as? FiltersTableController {
          destination.document = document
        }

      case MediaItemsController.SegueIdentifier:
        if let destination = segue.destination.getActionController() as? MediaItemsController,
           let view = sender as? MediaNameTableCell {

          let mediaItem = getItem(for: view)

          let adapter = GidOnlineServiceAdapter()

          adapter.requestType = mediaItem.name
          adapter.parentName = localizer.localize(mediaItem.name!)

          destination.adapter = adapter
          destination.collectionView?.collectionViewLayout = adapter.buildLayout()!
        }

      case SearchTableController.SegueIdentifier:
        if let destination = segue.destination.getActionController() as? SearchTableController {

          let adapter = GidOnlineServiceAdapter()

          adapter.requestType = "SEARCH"
          adapter.parentName = localizer.localize("SEARCH_RESULTS")

          destination.adapter = adapter
        }

      default:
        break
      }
    }
  }

}
