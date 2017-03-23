import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

open class GidOnlineTableViewController: GidOnlineBaseTableViewController {
  override open var CellIdentifier: String { return "GidOnlineTableCell" }

  let MainMenuItems = [
    "Bookmarks",
    "History",
    "All Movies",
    "Genres",
    "Themes",
    "Filters",
    "Search",
    "Settings"
  ]

  var document: Document?

  override open func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("GidOnline")

    adapter = GidOnlineServiceAdapter(mobile: true)

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
    case "Genres":
      performSegue(withIdentifier: GenresGroupController.SegueIdentifier, sender: view)

    case "Themes":
      performSegue(withIdentifier: ThemesController.SegueIdentifier, sender: view)

    case "Filters":
      performSegue(withIdentifier: FiltersController.SegueIdentifier, sender: view)

    case "Settings":
      performSegue(withIdentifier: "Settings", sender: view)

    case "Search":
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

          let adapter = GidOnlineServiceAdapter(mobile: true)

          adapter.requestType = mediaItem.name
          adapter.parentName = localizer.localize(mediaItem.name!)

          destination.adapter = adapter
        }

      case SearchTableController.SegueIdentifier:
        if let destination = segue.destination.getActionController() as? SearchTableController {

          let adapter = GidOnlineServiceAdapter(mobile: true)

          adapter.requestType = "Search"
          adapter.parentName = localizer.localize("Search Results")

          destination.adapter = adapter
        }

      default:
        break
      }
    }
  }

}
