import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GenresGroupTableViewController: GidOnlineBaseTableViewController {
  static let SegueIdentifier = "GenresGroup"

  override open var CellIdentifier: String { return "GenreGroupTableCell" }

  let GENRES_MENU = [
    "FAMILY",
    "CRIME",
    "FICTION",
    "EDUCATION"
  ]

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    adapter = GidOnlineServiceAdapter()

    for name in GENRES_MENU {
      let item = MediaItem(name: name)

      items.append(item)
    }
  }

//  override open func navigate(from view: UITableViewCell) {
//
//  }

//  override open func tapped(_ gesture: UITapGestureRecognizer) {
//    performSegue(withIdentifier: GenresController.SegueIdentifier, sender: gesture.view)
//  }
//
//  // MARK: - Navigation
//
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    if let identifier = segue.identifier {
//      switch identifier {
//      case GenresController.SegueIdentifier:
//        if let destination = segue.destination as? GenresController,
//           let selectedCell = sender as? MediaNameTableCell {
//          adapter.requestType = "GENRES"
//
//          let mediaItem = getItem(for: selectedCell)
//
//          adapter.parentId = mediaItem.name
//          adapter.parentName = localizer.localize(mediaItem.name!)
//
//          destination.adapter = adapter
//          destination.document = document
//        }
//
//      default: break
//      }
//    }
//  }
}
