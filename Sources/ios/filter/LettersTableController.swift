import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class LettersTableController: UITableViewController {
  static let SegueIdentifier = "Letters"
  let CellIdentifier = "LettersTableCell"

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  let service = GidOnlineService.shared

  private var items = Items()

  var document: Document?
  var requestType: String?

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

    for letter in GidOnlineAPI.CyrillicLetters {
      if !["Ё", "Й", "Щ", "Ъ", "Ы", "Ь"].contains(letter) {
        items.append(Item(name: letter))
      }
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
    performSegue(withIdentifier: LetterTableController.SegueIdentifier, sender: tableView)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case LetterTableController.SegueIdentifier:
          if let destination = segue.destination as? LetterTableController,
             let selectedCell = sender as? MediaNameTableCell,
            let indexPath = tableView.indexPath(for: selectedCell) {
            let adapter = GidOnlineServiceAdapter(mobile: true)
            destination.params["requestType"] = "Letter"

            let mediaItem = items.getItem(for: indexPath)

            destination.params["parentId"] = mediaItem.name
            destination.params["parentName"] = localizer.localize(requestType!)

            destination.adapter = adapter
            destination.document = document
            destination.requestType = requestType
          }

        default: break
      }
    }
  }
}
