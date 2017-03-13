import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class FiltersTableController: GidOnlineBaseTableViewController {
  static let SegueIdentifier = "Filters"

  override open var CellIdentifier: String { return "FilterTableCell" }

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

    adapter = GidOnlineServiceAdapter(mobile: true)

    for name in FiltersMenu {
      let item = MediaItem(name: name)

      items.append(item)
    }
  }

  override open func navigate(from view: UITableViewCell) {
    let mediaItem = getItem(for: view)

    switch mediaItem.name! {
      case "BY_ACTORS":
        performSegue(withIdentifier: LettersTableController.SegueIdentifier, sender: view)

      case "BY_DIRECTORS":
        performSegue(withIdentifier: LettersTableController.SegueIdentifier, sender: view)

      case "BY_COUNTRIES":
        performSegue(withIdentifier: CountriesTableController.SegueIdentifier, sender: view)

      case "BY_YEARS":
        performSegue(withIdentifier: YearsTableController.SegueIdentifier, sender: view)

//      case "SEARCH":
//        performSegue(withIdentifier: SearchTableController.SegueIdentifier, sender: view)

      default:
        //performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
        break
    }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case LettersTableController.SegueIdentifier:
          if let destination = segue.destination as? LettersTableController,
             let selectedCell = sender as? MediaNameTableCell {

            let requestType = getItem(for: selectedCell).name

            destination.document = document
            destination.requestType = requestType
          }
        case CountriesTableController.SegueIdentifier:
          if let destination = segue.destination as? CountriesTableController {
            destination.document = document
          }
        case YearsTableController.SegueIdentifier:
          if let destination = segue.destination as? YearsTableController {
            destination.document = document
          }
        default: break
      }
    }
  }

}
