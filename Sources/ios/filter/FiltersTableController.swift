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

    adapter = GidOnlineServiceAdapter()

    for name in FiltersMenu {
      let item = MediaItem(name: name)

      items.append(item)
    }
  }

//  override open func navigate(from view: UITableViewCell) {
//
//  }

//  override open func tapped(_ gesture: UITapGestureRecognizer) {
//    let selectedCell = gesture.view as! MediaNameTableCell
//
//    let requestType = getItem(for: selectedCell).name
//
//    if requestType == "BY_ACTORS" {
//      performSegue(withIdentifier: LettersController.SegueIdentifier, sender: gesture.view)
//    }
//    else if requestType == "BY_DIRECTORS" {
//      performSegue(withIdentifier: LettersController.SegueIdentifier, sender: gesture.view)
//    }
//    else if requestType == "BY_COUNTRIES" {
//      performSegue(withIdentifier: CountriesController.SegueIdentifier, sender: gesture.view)
//    }
//    else if requestType == "BY_Years" {
//      performSegue(withIdentifier: YearsController.SegueIdentifier, sender: gesture.view)
//    }
//  }
//
//  // MARK: - Navigation
//
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    if let identifier = segue.identifier {
//      switch identifier {
//      case LettersController.SegueIdentifier:
//        if let destination = segue.destination as? LettersController,
//           let selectedCell = sender as? MediaNameTableCell {
//
//          let requestType = getItem(for: selectedCell).name
//
//          destination.document = document
//          destination.requestType = requestType
//        }
//      case CountriesController.SegueIdentifier:
//        if let destination = segue.destination as? CountriesController {
//          destination.document = document
//        }
//      case YearsController.SegueIdentifier:
//        if let destination = segue.destination as? YearsController {
//          destination.document = document
//        }
//      default: break
//      }
//    }
//  }

}
