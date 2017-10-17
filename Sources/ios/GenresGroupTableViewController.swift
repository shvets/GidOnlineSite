import UIKit
import TVSetKit
import SwiftSoup

class GenresGroupTableViewController: UITableViewController {
  static let SegueIdentifier = "Genres Group"
  let CellIdentifier = "GenreGroupTableCell"

  let GENRES_MENU = [
    "Family",
    "Crime",
    "Fiction",
    "Education"
  ]

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  private var items = Items()
  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    items.pageLoader.load = {
      return self.loadGenresMenu()
    }

    items.loadInitialData(tableView)
  }

  func loadGenresMenu() -> [Item] {
    var items = [Item]()

    for name in GENRES_MENU {
      let item = Item(name: name)

      items.append(item)
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
    performSegue(withIdentifier: GenresController.SegueIdentifier, sender: tableView)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GenresController.SegueIdentifier:
          if let destination = segue.destination as? GenresTableViewController,
             let selectedCell = sender as? MediaNameTableCell,
             let indexPath = tableView.indexPath(for: selectedCell) {

            let adapter = GidOnlineServiceAdapter(mobile: true)
            destination.params["requestType"] = "Genres"

            let mediaItem = items.getItem(for: indexPath)

            adapter.params["parentId"] = mediaItem.name
            destination.params["parentName"] = localizer.localize(mediaItem.name!)

            //destination.adapter = adapter
            destination.document = document
          }

        default: break
      }
    }
  }
}
