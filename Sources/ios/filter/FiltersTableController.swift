import UIKit
import SwiftSoup
import TVSetKit

class FiltersTableController: UITableViewController {
  static let SegueIdentifier = "Filters"
  let CellIdentifier = "FilterTableCell"

  let FiltersMenu = [
    "By Actors",
    "By Directors",
    "By Countries",
    "By Years"
  ]

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  private var items = Items()

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    //adapter = GidOnlineServiceAdapter(mobile: true)

    items.pageLoader.load = {
      return self.loadData()
    }

    self.items.pageLoader.loadData { result in
      if let items = result as? [Item] {
        self.items.items = items

        self.tableView?.reloadData()
      }
    }
  }

  func loadData() -> [Item] {
    var items = [Item]()

    for name in FiltersMenu {
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
      let mediaItem = items.getItem(for: indexPath)

      switch mediaItem.name! {
        case "By Actors":
          performSegue(withIdentifier: LettersTableController.SegueIdentifier, sender: view)

        case "By Directors":
          performSegue(withIdentifier: LettersTableController.SegueIdentifier, sender: view)

        case "By Countries":
          performSegue(withIdentifier: CountriesTableController.SegueIdentifier, sender: view)

        case "By Years":
          performSegue(withIdentifier: YearsTableController.SegueIdentifier, sender: view)

        default:
          break
      }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case LettersTableController.SegueIdentifier:
          if let destination = segue.destination as? LettersTableController,
             let selectedCell = sender as? MediaNameTableCell,
             let indexPath = tableView.indexPath(for: selectedCell) {

            let requestType = items.getItem(for: indexPath).name

            destination.document = document
            destination.requestType = requestType
          }
        case CountriesTableController.SegueIdentifier:
          if let destination = segue.destination as? CountriesTableController {
            destination.document = document
          }
        case YearsTableController.SegueIdentifier:
          if let destination = segue.destination as? YearsTableController {
            destination.document = document
          }
        default: break
      }
    }
  }

}
