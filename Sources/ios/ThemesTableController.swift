import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class ThemesTableController: GidOnlineBaseTableViewController {
  static let SegueIdentifier = "Themes"
  override open var CellIdentifier: String { return "ThemeTableCell" }

  let ThemesMenu = [
    "TOP_SEVEN",
    "NEW_MOVIES",
    "PREMIERS"
  ]

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    adapter = GidOnlineServiceAdapter()

    for name in ThemesMenu {
      let item = MediaItem(name: name)

      items.append(item)
    }
  }

  override open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameTableCell {

            let adapter = GidOnlineServiceAdapter()

            adapter.requestType = "THEMES"
            adapter.selectedItem = getItem(for: view)

            destination.adapter = adapter
          }

        default: break
      }
    }
  }

}
