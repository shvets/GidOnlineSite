import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class LettersController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  static let SegueIdentifier = "Letters"
  let CellIdentifier = "LettersCell"

  let service = GidOnlineService.shared

  var adapter = GidOnlineServiceAdapter()
  
  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  private var items: Items!

  var document: Document?
  var requestType: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    setupLayout()

    items = Items() {
      return self.loadData()
    }

    items.loadInitialData(collectionView)

//    adapter = GidOnlineServiceAdapter()
  }

   func loadData() -> [Item] {
    var items = [Item]()

    for letter in GidOnlineAPI.CyrillicLetters {
      if !["Ё", "Й", "Щ", "Ъ", "Ы", "Ь"].contains(letter) {
        items.append(Item(name: letter))
      }
    }

    return items
  }

  func setupLayout() {
    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 20.0
    layout.minimumLineSpacing = 50.0

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
    performSegue(withIdentifier: "Letter", sender: gesture.view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
      case LetterController.SegueIdentifier:
        if let destination = segue.destination as? LetterController,
           let selectedCell = sender as? MediaNameCell,
           let indexPath = collectionView?.indexPath(for: selectedCell) {
          adapter.params["requestType"] = "Letter"

          let mediaItem = items.getItem(for: indexPath)

          adapter.params["parentId"] = mediaItem.name
          adapter.params["parentName"] = localizer.localize(requestType!)

          destination.adapter = adapter
          destination.document = document
          destination.requestType = requestType
        }

      default: break
      }
    }
  }
}
