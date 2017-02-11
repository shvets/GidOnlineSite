import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class FiltersController: BaseCollectionViewController {
  static let SEGUE_IDENTIFIER = "Filters"
  let CELL_IDENTIFIER = "FilterCell"

  let FILTERS_MENU = [
    "BY_ACTORS",
    "BY_DIRECTORS",
    "BY_COUNTRIES",
    "BY_YEARS"
  ]

  let service = GidOnlineService.shared

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

    for name in FILTERS_MENU {
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
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath) as! MediaNameCell

    let item = items[indexPath.row]

    let localizedName = adapter?.languageManager?.localize(item.name!) ?? "Unknown"

    cell.configureCell(item: item, localizedName: localizedName, target: self, action: #selector(self.tapped(_:)))

    return cell
  }

  func tapped(_ gesture: UITapGestureRecognizer) {
    let selectedCell = gesture.view as! MediaNameCell

    let requestType = selectedCell.item!.name

    if requestType == "BY_ACTORS" {
      performSegue(withIdentifier: LettersController.SEGUE_IDENTIFIER, sender: gesture.view)
    }
    else if requestType == "BY_DIRECTORS" {
      performSegue(withIdentifier: LettersController.SEGUE_IDENTIFIER, sender: gesture.view)
    }
    else if requestType == "BY_COUNTRIES" {
      performSegue(withIdentifier: CountriesController.SEGUE_IDENTIFIER, sender: gesture.view)
    }
    else if requestType == "BY_Years" {
      performSegue(withIdentifier: YearsController.SEGUE_IDENTIFIER, sender: gesture.view)
    }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case LettersController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? LettersController,
             let selectedCell = sender as? MediaNameCell {
            let requestType = selectedCell.item!.name

            destination.document = document
            destination.requestType = requestType
          }
        case CountriesController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? CountriesController {
            destination.document = document
          }
        case YearsController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? YearsController {
            destination.document = document
          }
        default: break
      }
    }
  }

}
