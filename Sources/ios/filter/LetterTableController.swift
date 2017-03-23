import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class LetterTableController: GidOnlineBaseTableViewController {
  static let SegueIdentifier = "Letter"

  override open var CellIdentifier: String { return "LetterTableCell" }

  var document: Document?
  var requestType: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    do {
      var data: [Any]?

      if requestType == "By Actors" {
        data = try service.getActors(document!, letter: adapter.parentId!)
      }
      else if requestType == "By Directors" {
        data = try service.getDirectors(document!, letter: adapter.parentId!)
      }

      for item in data! {
        let elem = item as! [String: Any]

        let id = elem["id"] as! String
        let name = elem["name"] as! String

        items.append(MediaItem(name: name, id: id))
      }
    }
    catch {
      print("Error getting items")
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

          let adapter = GidOnlineServiceAdapter(mobile: true)

          adapter.requestType = "Movies"
          adapter.selectedItem = getItem(for: view)

          destination.adapter = adapter
        }

      default: break
      }
    }
  }

}
