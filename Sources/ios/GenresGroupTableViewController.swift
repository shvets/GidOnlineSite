import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GenresGroupTableViewController: GidOnlineBaseTableViewController {
  static let SegueIdentifier = "Genres Group"

  override open var CellIdentifier: String { return "GenreGroupTableCell" }

  let GENRES_MENU = [
    "Family",
    "Crime",
    "Fiction",
    "Education"
  ]

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    adapter = GidOnlineServiceAdapter(mobile: true)

    for name in GENRES_MENU {
      let item = MediaItem(name: name)

      items.append(item)
    }
  }

  override open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: GenresController.SegueIdentifier, sender: view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GenresController.SegueIdentifier:
          if let destination = segue.destination as? GenresTableViewController,
             let selectedCell = sender as? MediaNameTableCell {
            adapter.params["requestType"] = "Genres"

            let mediaItem = getItem(for: selectedCell)

            adapter.params["parentId"] = mediaItem.name
            adapter.params["parentName"] = localizer.localize(mediaItem.name!)

            destination.adapter = adapter
            destination.document = document
          }

        default: break
      }
    }
  }
}
