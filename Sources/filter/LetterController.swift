import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class LetterController: BaseCollectionViewController {
  static let SegueIdentifier = "Letter"
  let CellIdentifier = "LetterCell"

  let service = GidOnlineService.shared

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

      if requestType == "BY_ACTORS" {
        data = try service.getActors(document!, letter: adapter.parentId!)
      }
      else if requestType == "BY_DIRECTORS" {
        data = try service.getDirectors(document!, letter: adapter.parentId!)
      }

      for item in data! {
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

  // MARK: UICollectionViewDataSource

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! MediaNameCell

    let item = items[indexPath.row]

    let localizedName = adapter?.languageManager?.localize(item.name!) ?? "Unknown"

    cell.configureCell(item: item, localizedName: localizedName, target: self, action: #selector(self.tapped(_:)))

    return cell
  }

  func tapped(_ gesture: UITapGestureRecognizer) {
    let selectedCell = gesture.view as! MediaNameCell

    let destination = MediaItemsController.instantiate()

    adapter.requestType = "MOVIES"

    adapter.selectedItem =  getItem(for: selectedCell)

    destination.adapter = adapter

    destination.collectionView?.collectionViewLayout = adapter.buildLayout()!

    self.show(destination, sender: destination)
  }
}