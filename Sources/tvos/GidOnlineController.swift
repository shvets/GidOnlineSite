import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

open class GidOnlineController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  let CellIdentifier = "GidOnlineCell"

  let localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)

  let service = GidOnlineService.shared

  private var items = Items()
  var document: Document?

  override open func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    setupLayout()

    items.pageLoader.load = {
      return self.loadData()
    }

    items.loadInitialData(collectionView)
  }

  func loadData() -> [Item] {
    var items = [Item]()

    items.append(MediaName(name: "Bookmarks", imageName: "Star"))
    items.append(MediaName(name: "History", imageName: "Bookmark"))
    items.append(MediaName(name: "All Movies", imageName: "Retro TV"))
    items.append(MediaName(name: "Genres", imageName: "Comedy"))
    items.append(MediaName(name: "Themes", imageName: "Briefcase"))
    items.append(MediaName(name: "Filters", imageName: "Filter"))
    items.append(MediaName(name: "Settings", imageName: "Engineering"))
    items.append(MediaName(name: "Search", imageName: "Search"))

    do {
      document = try service.fetchDocument(GidOnlineAPI.SiteUrl)
    }
    catch {
      print("Cannot load document")
    }

    return items
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

  @objc func tapped(_ gesture: UITapGestureRecognizer) {
    if let location = gesture.view as? UICollectionViewCell {
      navigate(from: location)
    }
  }

  open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    if let indexPath = collectionView?.indexPath(for: view) {
      let mediaItem = items.getItem(for: indexPath)
      
      switch mediaItem.name! {
      case "Genres":
        performSegue(withIdentifier: GenresGroupController.SegueIdentifier, sender: view)
        
      case "Themes":
        performSegue(withIdentifier: ThemesController.SegueIdentifier, sender: view)
        
      case "Filters":
        performSegue(withIdentifier: FiltersController.SegueIdentifier, sender: view)
        
      case "Settings":
        performSegue(withIdentifier: "Settings", sender: view)
        
      case "Search":
        performSegue(withIdentifier: SearchController.SegueIdentifier, sender: view)
        
      default:
        performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
      }
    }
  }

  // MARK: - Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GenresGroupController.SegueIdentifier:
          if let destination = segue.destination as? GenresGroupController {
            destination.document = document
          }

        case ThemesController.SegueIdentifier:
          if let destination = segue.destination as? ThemesController {
            destination.document = document
          }

        case FiltersController.SegueIdentifier:
          if let destination = segue.destination as? FiltersController {
            destination.document = document
          }

        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameCell,
             let indexPath = collectionView?.indexPath(for: view) {

            let mediaItem = items.getItem(for: indexPath)

            let adapter = GidOnlineServiceAdapter()

            adapter.params["requestType"] = mediaItem.name
            adapter.params["parentName"] = localizer.localize(mediaItem.name!)

            destination.adapter = adapter
            destination.configuration = adapter.getConfiguration()
            destination.collectionView?.collectionViewLayout = adapter.buildLayout()!
          }

        case SearchController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? SearchController {

            let adapter = GidOnlineServiceAdapter()

            adapter.params["requestType"] = "Search"
            adapter.params["parentName"] = localizer.localize("Search Results")

            destination.adapter = adapter
          }

        default:
          break
      }
    }
   }

}
