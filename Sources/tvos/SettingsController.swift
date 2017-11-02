import UIKit
import TVSetKit

class SettingsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  let CellIdentifier = "SettingCell"

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  private var items = Items()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    setupLayout()

    items.pageLoader.load = {
      return self.loadSettingsMenu()
    }

    items.pageLoader.loadData { result in
      if let items = result as? [Item] {
        self.items.items = items

        self.collectionView?.reloadData()
      }
    }
  }

  func loadSettingsMenu() -> [Item] {
    return [
      Item(name: "Reset History"),
      Item(name: "Reset Bookmarks")
    ]
  }

  func setupLayout() {
    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 150.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 20.0
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
      let settingsMode = items.getItem(for: indexPath).name
      
      if settingsMode == "Reset History" {
        self.present(buildResetHistoryController(), animated: false, completion: nil)
      }
      else if settingsMode == "Reset Bookmarks" {
        self.present(buildResetQueueController(), animated: false, completion: nil)
      }
    }
  }

  func buildResetHistoryController() -> UIAlertController {
    let title = localizer.localize("History Will Be Reset")
    let message = localizer.localize("Please Confirm Your Choice")

    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let adapter = GidOnlineServiceAdapter()

    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      let history = adapter.history

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

    let adapter = GidOnlineServiceAdapter()

    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      let bookmarks = adapter.bookmarks

      bookmarks.clear()
      bookmarks.save()
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alertController.addAction(cancelAction)
    alertController.addAction(okAction)

    return alertController
  }

}
