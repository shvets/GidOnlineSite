import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GenresTableViewController: GidOnlineBaseTableViewController {
  static let SegueIdentifier = "Genres"

  override public var CellIdentifier: String { return "GenreTableCell" }

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    do {
      let genres = try service.getGenres(document!, type: adapter.parentId!) as! [[String: String]]

      for genre in genres {
        let item = MediaItem(name: localizer.localize(genre["name"]!), id: genre["id"]!)

        items.append(item)
      }
    }
    catch {
      print("Error getting document")
    }
  }

//  override open func navigate(from view: UITableViewCell) {
//
//  }

//  override public func tapped(_ gesture: UITapGestureRecognizer) {
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
