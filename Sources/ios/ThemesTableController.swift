import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class ThemesTableController: GidOnlineBaseTableViewController {
  static let SegueIdentifier = "Themes"
  override open var CellIdentifier: String { return "ThemeTableCell" }

  let ThemesMenu = [
    "TOP_SEVEN",
    "NEW_MOVIES",
    "PREMIERS"
  ]

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

//    let layout = UICollectionViewFlowLayout()
//
//    layout.itemSize = CGSize(width: 450, height: 150)
//    layout.sectionInset = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
//    layout.minimumInteritemSpacing = 10.0
//    layout.minimumLineSpacing = 100.0
//
//    collectionView?.collectionViewLayout = layout

    adapter = GidOnlineServiceAdapter()

    for name in ThemesMenu {
      let item = MediaItem(name: name)

      items.append(item)
    }
  }

  // MARK: UICollectionViewDataSource

//  override func numberOfSections(in collectionView: UICollectionView) -> Int {
//    return 1
//  }
//
//  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//    return items.count
//  }
//
//  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! MediaNameTableCell
//
//    let item = items[indexPath.row]
//
//    let localizedName = localizer.localize(item.name!)
//
//    cell.configureCell(item: item, localizedName: localizedName, target: self)
//    CellHelper.shared.addGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))
//
//    return cell
//  }

//  override open func tapped(_ gesture: UITapGestureRecognizer) {
//    let selectedCell = gesture.view as! MediaNameTableCell
//
//    let controller = MediaItemsController.instantiate(adapter).getActionController()
//    let destination = controller as! MediaItemsController
//
//    adapter.requestType = "THEMES"
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
