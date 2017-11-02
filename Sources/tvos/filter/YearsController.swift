import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class YearsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  static let SegueIdentifier = "Years"
  let CellIdentifier = "YearCell"
  let StoryboardId = "GidOnline"

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  var adapter = GidOnlineServiceAdapter()
  let service = GidOnlineService.shared

  private var items = Items()

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    setupLayout()

    items.pageLoader.load = {
      return self.loadData()
    }

    items.pageLoader.loadData { result in
      if let items = result as? [Item] {
        self.items.items = items

        self.collectionView?.reloadData()
      }
    }
  }

 func loadData() -> [Item] {
    var items = [Item]()

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
    if let destination = MediaItemsController.instantiateController(StoryboardId),
       let selectedCell = gesture.view as? MediaNameCell,
       let indexPath = collectionView?.indexPath(for: selectedCell) {

      let adapter = GidOnlineServiceAdapter()

      destination.params["requestType"] = "Movies"
      destination.params["selectedItem"] = items.getItem(for: indexPath)

      destination.configuration = adapter.getConfiguration()

      if let layout = adapter.buildLayout() {
        destination.collectionView?.collectionViewLayout = layout
      }

      show(destination, sender: destination)
    }
  }
}
