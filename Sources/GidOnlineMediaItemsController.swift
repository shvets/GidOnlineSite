import TVSetKit

open class GidOnlineMediaItemsController: MediaItemsController {
  override open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    if let indexPath = collectionView?.indexPath(for: view),
       let mediaItem = items.getItem(for: indexPath) as? MediaItem {

      if mediaItem.isContainer() {
        if let destination = MediaItemsController.instantiateController(configuration?["storyboardId"] as! String) {
          destination.configuration = configuration

          for (key, value) in self.params {
            destination.params[key] = value
          }

          destination.params["selectedItem"] = mediaItem
          destination.params["parentId"] = mediaItem.id
          destination.params["parentName"] = mediaItem.name
          destination.params["isContainer"] = true

          if !mobile {
            if let layout = configuration?["buildLayout"] {
              destination.collectionView?.collectionViewLayout = layout as! UICollectionViewLayout
            }

            present(destination, animated: true)
          }
          else {
            navigationController?.pushViewController(destination, animated: true)
          }
        }
      }
      else {
        super.navigate(view: view, playImmediately: playImmediately)
      }
    }
  }

}
