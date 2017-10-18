import UIKit
import SwiftSoup
import TVSetKit
import WebAPI

class YearsTableController: UITableViewController {
  static let SegueIdentifier = "Years"
  let CellIdentifier = "YearTableCell"

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  let service = GidOnlineService.shared

  private var items = Items()

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    items.pageLoader.load = {
      return self.loadData()
    }

    items.loadInitialData(tableView)
  }

  func loadData() -> [Item] {
    var items = [Item]()

    do {
      let data = try service.getYears(document!)

      for item in data {
        let elem = item as! [String: Any]

        let id = elem["id"] as! String
        let name = elem["name"] as! String

        items.append(MediaItem(name: name, id: id))
      }
    }
    catch {
      print("Error getting items")
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

            destination.adapter = adapter
            destination.configuration = adapter.getConfiguration()
          }

        default: break
      }
    }
  }

}
