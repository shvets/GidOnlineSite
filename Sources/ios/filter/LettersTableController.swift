import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class LettersTableController: GidOnlineBaseTableViewController {
  static let SegueIdentifier = "Letters"

  override open var CellIdentifier: String { return "LettersTableCell" }

  var document: Document?
  var requestType: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    adapter = GidOnlineServiceAdapter()

    for letter in GidOnlineAPI.CyrillicLetters {
      if !["Ё", "Й", "Щ", "Ъ", "Ы", "Ь"].contains(letter) {
        items.append(MediaItem(name: letter))
      }
    }
  }

  override open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: LetterTableController.SegueIdentifier, sender: view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case LetterTableController.SegueIdentifier:
          if let destination = segue.destination as? LetterTableController,
             let selectedCell = sender as? MediaNameTableCell {
            adapter.requestType = "LETTER"

            let mediaItem =  getItem(for: selectedCell)

            adapter.parentId = mediaItem.name
            adapter.parentName = localizer.localize(requestType!)

            destination.adapter = adapter
            destination.document = document
            destination.requestType = requestType
          }

        default: break
      }
    }
  }
}
