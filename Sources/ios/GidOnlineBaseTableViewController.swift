import TVSetKit

open class GidOnlineBaseTableViewController: BaseTableViewController {
  open var CellIdentifier: String {
    return ""
  }

  let service = GidOnlineService.shared

  let localizer = Localizer("com.rubikon.GidOnlineSite")

//  override open func viewDidLoad() {
//    super.viewDidLoad()
//
//    localizer = Localizer("com.rubikon.GidOnlineSite")
//  }
}