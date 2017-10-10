import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class ThemesController: GidOnlineBaseCollectionViewController {
  static let SegueIdentifier = "Themes"
  override open var CellIdentifier: String { return "ThemeCell" }

  let ThemesMenu = [
    "Top Seven",
    "New Movies",
    "Premiers"
  ]

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

    for name in ThemesMenu {
      let item = Item(name: name)

      items.append(item)
    }
  }

  override open func tapped(_ gesture: UITapGestureRecognizer) {
    if let destination = MediaItemsController.instantiateController(adapter),
       let selectedCell = gesture.view as? MediaNameCell {
      adapter.params["requestType"] = "Themes"

      adapter.params["selectedItem"] = getItem(for: selectedCell)

      destination.adapter = adapter

      if let layout = adapter.buildLayout() {
        destination.collectionView?.collectionViewLayout = layout
      }

      show(destination, sender: destination)
    }
  }

}
