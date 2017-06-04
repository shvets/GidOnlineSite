import TVSetKit

open class GidOnlineBaseTableViewController: BaseTableViewController {
  let service = GidOnlineService.shared

  override open func viewDidLoad() {
    super.viewDidLoad()

    localizer = Localizer(GidOnlineServiceAdapter.BundleId, bundleClass: GidOnlineSite.self)
  }

}
