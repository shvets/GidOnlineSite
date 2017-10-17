import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class FiltersController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  static let SegueIdentifier = "Filters"

  let CellIdentifier = "FilterCell"

  let FiltersMenu = [
    "By Actors",
    "By Directors",
    "By Countries",
    "By Years"
  ]

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  private var items = Items()

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    setupLayout()

    items.pageLoader.load = {
      return self.loadData()
    }

    items.loadInitialData(collectionView)

    //adapter = GidOnlineServiceAdapter()
  }

  func loadData() -> [Item] {
    var items = [Item]()

    for name in FiltersMenu {
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

  @objc open func tapped(_ gesture: UITapGestureRecognizer) {
    if let selectedCell = gesture.view as? MediaNameCell,
      let indexPath = collectionView?.indexPath(for: selectedCell) {
      let requestType = items.getItem(for: indexPath).name
      
      if requestType == "By Actors" {
        performSegue(withIdentifier: LettersController.SegueIdentifier, sender: gesture.view)
      }
      else if requestType == "By Directors" {
        performSegue(withIdentifier: LettersController.SegueIdentifier, sender: gesture.view)
      }
      else if requestType == "By Countries" {
        performSegue(withIdentifier: CountriesController.SegueIdentifier, sender: gesture.view)
      }
      else if requestType == "By Years" {
        performSegue(withIdentifier: YearsController.SegueIdentifier, sender: gesture.view)
      }
    }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case LettersController.SegueIdentifier:
          if let destination = segue.destination as? LettersController,
             let selectedCell = sender as? MediaNameCell,
             let indexPath = collectionView?.indexPath(for: selectedCell) {

            let requestType = items.getItem(for: indexPath).name

            destination.document = document
            destination.requestType = requestType
          }
        case CountriesController.SegueIdentifier:
          if let destination = segue.destination as? CountriesController {
            destination.document = document
          }
        case YearsController.SegueIdentifier:
          if let destination = segue.destination as? YearsController {
            destination.document = document
          }
        default: break
      }
    }
  }

}
