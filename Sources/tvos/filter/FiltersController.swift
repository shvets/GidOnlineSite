import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class FiltersController: GidOnlineCollectionViewController {
  static let SegueIdentifier = "Filters"

  override open var CellIdentifier: String { return "FilterCell" }

  let FiltersMenu = [
    "BY_ACTORS",
    "BY_DIRECTORS",
    "BY_COUNTRIES",
    "BY_YEARS"
  ]

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    adapter = GidOnlineServiceAdapter()

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 10.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    for name in FiltersMenu {
      let item = MediaItem(name: name)

      items.append(item)
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

    let localizedName = localizer.localize(item.name!)

    cell.configureCell(item: item, localizedName: localizedName, target: self)
    CellHelper.shared.addGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))

    return cell
  }

  override open func tapped(_ gesture: UITapGestureRecognizer) {
    let selectedCell = gesture.view as! MediaNameCell

    let requestType = getItem(for: selectedCell).name

    if requestType == "BY_ACTORS" {
      performSegue(withIdentifier: LettersController.SegueIdentifier, sender: gesture.view)
    }
    else if requestType == "BY_DIRECTORS" {
      performSegue(withIdentifier: LettersController.SegueIdentifier, sender: gesture.view)
    }
    else if requestType == "BY_COUNTRIES" {
      performSegue(withIdentifier: CountriesController.SegueIdentifier, sender: gesture.view)
    }
    else if requestType == "BY_Years" {
      performSegue(withIdentifier: YearsController.SegueIdentifier, sender: gesture.view)
    }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case LettersController.SegueIdentifier:
          if let destination = segue.destination as? LettersController,
             let selectedCell = sender as? MediaNameCell {

            let requestType = getItem(for: selectedCell).name

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
