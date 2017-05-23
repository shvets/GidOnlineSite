import TVSetKit

open class GidOnlineBaseCollectionViewController: BaseCollectionViewController {
  let service = GidOnlineService.shared

  override open func viewDidLoad() {
    super.viewDidLoad()

    localizer = Localizer(GidOnlineServiceAdapter.BundleId)
  }
}
