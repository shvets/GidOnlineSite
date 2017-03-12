import TVSetKit

open class GidOnlineCollectionViewController: BaseCollectionViewController {
  let service = GidOnlineService.shared

  override open func viewDidLoad() {
    super.viewDidLoad()

    localizer = Localizer("com.rubikon.GidOnlineSite")
  }
}