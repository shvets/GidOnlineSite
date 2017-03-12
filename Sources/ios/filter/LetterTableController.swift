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

    //adapter = GidOnlineServiceAdapter()

    do {
      var data: [Any]?

      if requestType == "BY_ACTORS" {
        data = try service.getActors(document!, letter: adapter.parentId!)
      }
      else if requestType == "BY_DIRECTORS" {
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

//  override open func navigate(from view: UITableViewCell) {
//
//  }

//  override open func tapped(_ gesture: UITapGestureRecognizer) {
//    let selectedCell = gesture.view as! MediaNameTableCell
//
//    let controller = MediaItemsController.instantiate(adapter).getActionController()
//    let destination = controller as! MediaItemsController
//
//    adapter.requestType = "MOVIES"
//
//    adapter.selectedItem =  getItem(for: selectedCell)
//
//    destination.adapter = adapter
//
//    destination.collectionView?.collectionViewLayout = adapter.buildLayout()!
//
//    show(controller!, sender: destination)
//  }
}
