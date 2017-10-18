import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GidOnlineServiceAdapter: ServiceAdapter {
  let service = GidOnlineService.shared

  static let bookmarksFileName = NSHomeDirectory() + "/Library/Caches/gidonline-bookmarks.json"
  static let historyFileName = NSHomeDirectory() + "/Library/Caches/gidonline-history.json"

  override open class var StoryboardId: String { return "GidOnline" }
  override open class var BundleId: String { return "com.rubikon.GidOnlineSite" }

  lazy var bookmarks = Bookmarks(GidOnlineServiceAdapter.bookmarksFileName)
  lazy var history = History(GidOnlineServiceAdapter.historyFileName)

  lazy var bookmarksManager = BookmarksManager(bookmarks)
  lazy var historyManager = HistoryManager(history)

  var episodes: [JSON]?

  public init(mobile: Bool=false) {
    super.init(dataSource: GidOnlineDataSource(), mobile: mobile)

    bookmarksManager = BookmarksManager(bookmarks)
    historyManager = HistoryManager(history)

    pageLoader.pageSize = 12
    pageLoader.rowSize = 6

    pageLoader.load = {
      return try self.load()
    }
  }

  override open func clone() -> ServiceAdapter {
    let cloned = GidOnlineServiceAdapter(mobile: mobile!)

    cloned.clear()

    return cloned
  }

  override open func load() throws -> [Any] {
    do {
      params["document"] = try service.fetchDocument(GidOnlineAPI.SiteUrl)!
    }
    catch {
      print("Error fetching document")
    }

    params["bookmarks"] = bookmarks
    params["history"] = history

    return try super.load()
  }

  func buildLayout() -> UICollectionViewFlowLayout? {
    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 200*1.2, height: 300*1.2) // 200 x 300
    layout.sectionInset = UIEdgeInsets(top: 40.0, left: 40.0, bottom: 120.0, right: 40.0)
    layout.minimumInteritemSpacing = 40.0
    layout.minimumLineSpacing = 140.0

    layout.headerReferenceSize = CGSize(width: 500, height: 75)

    return layout
  }

  func getDetailsImageFrame() -> CGRect? {
    return CGRect(x: 40, y: 40, width: 210*2.7, height: 300*2.7)
  }

  func getConfiguration() -> [String: Any] {
    var conf = [String: Any]()

    conf["pageSize"] = 12

    if mobile {
      conf["rowSize"] = 1
    }
    else {
      conf["rowSize"] = 6
    }

    conf["mobile"] = mobile

    conf["bookmarksManager"] = bookmarksManager
    conf["historyManager"] = historyManager
    conf["dataSource"] = dataSource
    conf["storyboardId"] =  GidOnlineServiceAdapter.StoryboardId
    conf["detailsImageFrame"] = getDetailsImageFrame()
    conf["buildLayout"] = buildLayout()
    return conf
  }
}
