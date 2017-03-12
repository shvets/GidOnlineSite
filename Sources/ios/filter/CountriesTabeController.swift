import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class CountriesTableController: GidOnlineBaseTableViewController {
  static let SegueIdentifier = "Countries"

  override open var CellIdentifier: String { return "CountryTableCell" }

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    adapter = GidOnlineServiceAdapter()

    do {
      let data = try service.getCountries(document!)

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
//    adapter.selectedItem = getItem(for: selectedCell)
//
//    destination.adapter = adapter
//
//    destination.collectionView?.collectionViewLayout = adapter.buildLayout()!
//
//    show(controller!, sender: destination)
//  }
}
