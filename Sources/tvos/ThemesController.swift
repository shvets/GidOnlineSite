import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class ThemesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  static let SegueIdentifier = "Themes"
  let CellIdentifier = "ThemeCell"

  let ThemesMenu = [
    "Top Seven",
    "New Movies",
    "Premiers"
  ]

  var adapter = GidOnlineServiceAdapter()
  
  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  private var items = Items()

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    setupLayout()

    items.pageLoader.load = {
      return self.loadThemes()
    }

    items.loadInitialData(collectionView)

    //adapter = GidOnlineServiceAdapter()
  }

 func loadThemes() -> [Item] {
    var items = [Item]()

    for name in ThemesMenu {
      let item = Item(name: name)

      items.append(item)
    }

    return items
  }

  func setupLayout() {
    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 10.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout
  }

  override open func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? MediaNameCell {
      if let item = items[indexPath.row] as? MediaName {
         cell.configureCell(item: item, localizedName: localizer.getLocalizedName(item.name), target: self)
      }

      CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))

      return cell
    }
    else {
      return UICollectionViewCell()
    }
  }

  @objc func tapped(_ gesture: UITapGestureRecognizer) {
    if let destination = MediaItemsController.instantiateController(adapter),
       let selectedCell = gesture.view as? MediaNameCell,
       let indexPath = collectionView?.indexPath(for: selectedCell) {
      destination.params["requestType"] = "Themes"

      destination.params["selectedItem"] = items.getItem(for: indexPath)

      destination.adapter = adapter
      destination.configuration = adapter.getConfiguration()

      if let layout = adapter.buildLayout() {
        destination.collectionView?.collectionViewLayout = layout
      }

      show(destination, sender: destination)
    }
  }

}
