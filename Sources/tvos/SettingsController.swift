import UIKit
import TVSetKit

class SettingsController: GidOnlineBaseCollectionViewController {
  override open var CellIdentifier: String { return "SettingCell" }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 150.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 20.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    adapter = GidOnlineServiceAdapter()

    loadSettingsMenu()
  }

  func loadSettingsMenu() {
    let resetHistory = MediaItem(name: "Reset History")
    let resetQueue = MediaItem(name: "Reset Bookmarks")

    items = [
      resetHistory, resetQueue
    ]
  }

  override open func tapped(_ gesture: UITapGestureRecognizer) {
    let selectedCell = gesture.view as! MediaNameCell

    let settingsMode = (getItem(for: selectedCell) as! MediaName).name

    if settingsMode == "Reset History" {
      self.present(buildResetHistoryController(), animated: false, completion: nil)
    }
    else if settingsMode == "Reset Bookmarks" {
      self.present(buildResetQueueController(), animated: false, completion: nil)
    }
  }

  func buildResetHistoryController() -> UIAlertController {
    let title = localizer.localize("History Will Be Reset")
    let message = localizer.localize("Please Confirm Your Choice")

    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      let history = (self.adapter as! GidOnlineServiceAdapter).history

      history.clear()
      history.save()
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alertController.addAction(cancelAction)
    alertController.addAction(okAction)

    return alertController
  }

  func buildResetQueueController() -> UIAlertController {
    let title = localizer.localize("Bookmarks Will Be Reset")
    let message = localizer.localize("Please Confirm Your Choice")

    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      let bookmarks = (self.adapter as! GidOnlineServiceAdapter).bookmarks

      bookmarks.clear()
      bookmarks.save()
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alertController.addAction(cancelAction)
    alertController.addAction(okAction)

    return alertController
  }

}
