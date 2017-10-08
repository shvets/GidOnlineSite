import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class FiltersTableController: GidOnlineBaseTableViewController {
  static let SegueIdentifier = "Filters"

  override open var CellIdentifier: String { return "FilterTableCell" }

  let FiltersMenu = [
    "By Actors",
    "By Directors",
    "By Countries",
    "By Years"
  ]

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    adapter = GidOnlineServiceAdapter(mobile: true)

    for name in FiltersMenu {
      let item = Item(name: name)

      items.append(item)
    }
  }

  override open func navigate(from view: UITableViewCell) {
    let mediaItem = getItem(for: view)

    switch mediaItem.name! {
      case "By Actors":
        performSegue(withIdentifier: LettersTableController.SegueIdentifier, sender: view)

      case "By Directors":
        performSegue(withIdentifier: LettersTableController.SegueIdentifier, sender: view)

      case "By Countries":
        performSegue(withIdentifier: CountriesTableController.SegueIdentifier, sender: view)

      case "By Years":
        performSegue(withIdentifier: YearsTableController.SegueIdentifier, sender: view)

      default:
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
