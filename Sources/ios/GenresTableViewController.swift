import UIKit
import TVSetKit
import SwiftSoup
import WebAPI

class GenresTableViewController: UITableViewController {
  static let SegueIdentifier = "Genres"
  let CellIdentifier = "GenreTableCell"

  let service = GidOnlineService.shared

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  let adapter = GidOnlineServiceAdapter(mobile: true)

  public var params = Parameters()
  private var items = Items()
  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    items.pageLoader.load = {
      return self.loadGenres()
    }

    self.items.pageLoader.loadData { result in
      if let items = result as? [Item] {
        self.items.items = items

        self.tableView?.reloadData()
      }
    }
  }

  func loadGenres() -> [Item] {
    var items = [Item]()

    do {
      let genres = try service.getGenres(document!, type: adapter.params["parentId"] as! String) as! [[String: String]]

      for genre in genres {
        let item = Item(name: localizer.localize(genre["name"]!), id: genre["id"]!)

        items.append(item)
      }
    }
    catch {
      print("Error getting document")
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
    performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: tableView)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
      case MediaItemsController.SegueIdentifier:
        if let destination = segue.destination.getActionController() as? MediaItemsController,
           let view = sender as? MediaNameTableCell,
           let indexPath = tableView.indexPath(for: view) {

          let adapter = GidOnlineServiceAdapter(mobile: true)

          destination.params["requestType"] = "Movies"
          destination.params["selectedItem"] = items.getItem(for: indexPath)

          destination.configuration = adapter.getConfiguration()
        }

      default: break
      }
    }
  }

}
