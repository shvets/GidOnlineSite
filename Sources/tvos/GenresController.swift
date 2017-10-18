import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GenresController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  static let SegueIdentifier = "Genres"
  let CellIdentifier = "GenreCell"

  var adapter = GidOnlineServiceAdapter()

  let service = GidOnlineService.shared

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  public var params = Parameters()
  
  private var items = Items()

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    setupLayout()

    items.pageLoader.load = {
      return self.loadGenres()
    }

    items.loadInitialData(collectionView)
  }

  func loadGenres() -> [Item] {
    var items = [Item]()

    do {
      let genres = try service.getGenres(document!, type: adapter.params["parentId"] as! String) as! [[String: String]]

      for genre in genres {
        let item = Item(name: localizer.localize(genre["name"]!), id: genre["id"]!)

        items.append(item)
      }
    }
    catch {
      print("Error getting document")
    }

    return items
  }

  func setupLayout() {
   let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 150.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 20.0
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

  @objc public func tapped(_ gesture: UITapGestureRecognizer) {
    if let destination = MediaItemsController.instantiateController(adapter),
       let selectedCell = gesture.view as? MediaNameCell,
       let indexPath = collectionView?.indexPath(for: selectedCell) {
      let adapter = GidOnlineServiceAdapter()

      destination.params["requestType"] = "Movies"
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
