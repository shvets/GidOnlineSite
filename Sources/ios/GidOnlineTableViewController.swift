import UIKit
import SwiftSoup
import TVSetKit
import WebAPI

open class GidOnlineTableViewController: UITableViewController {
 let CellIdentifier = "GidOnlineTableCell"

  let service = GidOnlineService.shared

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  private var items = Items()
  var document: Document?

  override open func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("GidOnline")

    items.pageLoader.load = {
      return self.loadData()
    }

    items.loadInitialData(tableView)
  }

  func loadData() -> [Item] {
    var items = [Item]()

    items.append(MediaName(name: "Bookmarks", imageName: "Star"))
    items.append(MediaName(name: "History", imageName: "Bookmark"))
    items.append(MediaName(name: "All Movies", imageName: "Retro TV"))
    items.append(MediaName(name: "Genres", imageName: "Comedy"))
    items.append(MediaName(name: "Themes", imageName: "Briefcase"))
    items.append(MediaName(name: "Filters", imageName: "Filter"))
    items.append(MediaName(name: "Settings", imageName: "Engineering"))
    items.append(MediaName(name: "Search", imageName: "Search"))


    do {
      document = try service.fetchDocument(GidOnlineAPI.SiteUrl)
    }
    catch {
      print("Cannot load document")
    }

    return items
  }

 // MARK: UITableViewDataSource

  override open func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as? MediaNameTableCell {
      let item = items[indexPath.row]

      cell.configureCell(item: item, localizedName: localizer.getLocalizedName(item.name))

      return cell
    }
    else {
      return UITableViewCell()
    }
  }

  override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let mediaItem = items.getItem(for: indexPath)

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

//      case ThemesTableController.SegueIdentifier:
//        if let destination = segue.destination as? ThemesTableController {
//          destination.document = document
//        }

      case FiltersTableController.SegueIdentifier:
        if let destination = segue.destination as? FiltersTableController {
          destination.document = document
        }

      case MediaItemsController.SegueIdentifier:
        if let destination = segue.destination.getActionController() as? MediaItemsController,
           let view = sender as? MediaNameTableCell,
           let indexPath = tableView.indexPath(for: view) {

          let mediaItem = items.getItem(for: indexPath)

          let adapter = GidOnlineServiceAdapter(mobile: true)

          destination.params["requestType"] = mediaItem.name
          destination.params["parentName"] = localizer.localize(mediaItem.name!)

          destination.adapter = adapter
          destination.configuration = adapter.getConfiguration()
        }

      case SearchTableController.SegueIdentifier:
        if let destination = segue.destination.getActionController() as? SearchTableController {

          let adapter = GidOnlineServiceAdapter(mobile: true)

          destination.params["requestType"] = "Search"
          destination.params["parentName"] = localizer.localize("Search Results")
          
          destination.configuration = adapter.getConfiguration()
        }

      default:
        break
      }
    }
  }

}
