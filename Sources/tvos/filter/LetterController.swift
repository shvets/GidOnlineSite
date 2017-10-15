import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class LetterController: GidOnlineBaseCollectionViewController {
  static let SegueIdentifier = "Letter"

  override open var CellIdentifier: String { return "LetterCell" }

  var document: Document?
  var requestType: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 10.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    //adapter = GidOnlineServiceAdapter()

    do {
      var data: [Any]?

      if requestType == "By Actors" {
        data = try service.getActors(document!, letter: adapter.params["parentId"] as! String)
      }
      else if requestType == "By Directors" {
        data = try service.getDirectors(document!, letter: adapter.params["parentId"] as! String)
      }

      for item in data! {
        let elem = item as! [String: Any]

        let id = elem["id"] as! String
        let name = elem["name"] as! String

        items.append(MediaName(name: name, id: id))
      }
    }
    catch {
      print("Error getting items")
    }
  }

  override open func tapped(_ gesture: UITapGestureRecognizer) {
    if let destination = MediaItemsController.instantiateController(adapter),
       let selectedCell = gesture.view as? MediaNameCell {
      adapter.params["requestType"] = "Movies"

      adapter.params["selectedItem"] = getItem(for: selectedCell)

      destination.adapter = adapter
      //destination.configuration = adapter.getConfiguration()

      if let layout = adapter.buildLayout() {
        destination.collectionView?.collectionViewLayout = layout
      }

      show(destination, sender: destination)
    }
  }
}
