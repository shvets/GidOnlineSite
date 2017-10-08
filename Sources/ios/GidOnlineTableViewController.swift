import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

open class GidOnlineTableViewController: GidOnlineBaseTableViewController {
  override open var CellIdentifier: String { return "GidOnlineTableCell" }

  var document: Document?

  override open func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("GidOnline")

    adapter = GidOnlineServiceAdapter(mobile: true)

    self.clearsSelectionOnViewWillAppear = false

    loadData()

    do {
      document = try service.fetchDocument(GidOnlineAPI.SiteUrl)
    }
    catch {
      print("Cannot load document")
    }
  }

  func loadData() {
    items.append(MediaName(name: "Bookmarks", imageName: "Star"))
    items.append(MediaName(name: "History", imageName: "Bookmark"))
    items.append(MediaName(name: "All Movies", imageName: "Retro TV"))
    items.append(MediaName(name: "Genres", imageName: "Comedy"))
    items.append(MediaName(name: "Themes", imageName: "Briefcase"))
    items.append(MediaName(name: "Filters", imageName: "Filter"))
    items.append(MediaName(name: "Settings", imageName: "Engineering"))
    items.append(MediaName(name: "Search", imageName: "Search"))
  }

  override open func navigate(from view: UITableViewCell) {
    let mediaItem = getItem(for: view)

    switch mediaItem.name! {
      case "Genres":
        performSegue(withIdentifier: GenresGroupTableViewController.SegueIdentifier, sender: view)

      case "Themes":
        performSegue(withIdentifier: ThemesTableController.SegueIdentifier, sender: view)

      case "Filters":
        performSegue(withIdentifier: FiltersController.SegueIdentifier, sender: view)

      case "Settings":
        performSegue(withIdentifier: "Settings", sender: view)

      case "Search":
        performSegue(withIdentifier: SearchTableController.SegueIdentifier, sender: view)

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

          adapter.params["requestType"] = mediaItem.name
          adapter.params["parentName"] = localizer.localize(mediaItem.name!)

          destination.adapter = adapter
        }

      case SearchTableController.SegueIdentifier:
        if let destination = segue.destination.getActionController() as? SearchTableController {

          let adapter = GidOnlineServiceAdapter(mobile: true)

          adapter.params["requestType"] = "Search"
          adapter.params["parentName"] = localizer.localize("Search Results")

          destination.adapter = adapter
        }

      default:
        break
      }
    }
  }

}
