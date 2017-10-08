import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class YearsController: GidOnlineBaseCollectionViewController {
  static let SegueIdentifier = "Years"

  override open var CellIdentifier: String { return "YearCell" }

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 10.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    adapter = GidOnlineServiceAdapter()

    do {
      let data = try service.getYears(document!)

      for item in data {
        let elem = item as! [String: Any]

        let id = elem["id"] as! String
        let name = elem["name"] as! String

        items.append(Item(name: name, id: id))
      }
    }
    catch {
      print("Error getting items")
    }
  }

  override func tapped(_ gesture: UITapGestureRecognizer) {
    let selectedCell = gesture.view as! MediaNameCell

    let controller = MediaItemsController.instantiate(adapter).getActionController()
    let destination = controller as! MediaItemsController

    adapter.params["requestType"] = "Movies"

    adapter.params["selectedItem"] = getItem(for: selectedCell)

    destination.adapter = adapter

    destination.collectionView?.collectionViewLayout = adapter.buildLayout()!

    show(controller!, sender: destination)
  }
}
