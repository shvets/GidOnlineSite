import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GenresController: GidOnlineBaseCollectionViewController {
  static let SegueIdentifier = "Genres"

  override public var CellIdentifier: String { return "GenreCell" }

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 150.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 20.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    do {
      let genres = try service.getGenres(document!, type: adapter.params["parentId"] as! String) as! [[String: String]]

      for genre in genres {
        let item = Item(name: localizer!.localize(genre["name"]!), id: genre["id"]!)

        items.append(item)
      }
    }
    catch {
      print("Error getting document")
    }
  }

  override public func tapped(_ gesture: UITapGestureRecognizer) {
    if let destination = MediaItemsController.instantiateController(adapter),
       let selectedCell = gesture.view as? MediaNameCell {
      adapter.params["requestType"] = "Movies"

      adapter.params["selectedItem"] = getItem(for: selectedCell)

      destination.adapter = adapter

      if let layout = adapter.buildLayout() {
        destination.collectionView?.collectionViewLayout = layout
      }

      show(destination, sender: destination)
    }
  }

}
