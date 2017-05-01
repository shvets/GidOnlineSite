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

  lazy var bookmarks = Bookmarks(bookmarksFileName)
  lazy var history = History(historyFileName)

  var episodes: [JSON]?

  var document: Document?

  public init(mobile: Bool=false) {
    super.init(dataSource: GidOnlineDataSource(), mobile: mobile)
    
    bookmarks.load()
    history.load()

    do {
      document = try service.fetchDocument(GidOnlineAPI.SiteUrl)!
    }
    catch {
      print("Error fetching document")
    }

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

  open func instantiateController(controllerId: String) -> UIViewController {
    return UIViewController.instantiate(
      controllerId: controllerId,
      storyboardId: GidOnlineServiceAdapter.StoryboardId,
      bundleId: GidOnlineServiceAdapter.BundleId)
  }

  func load() throws -> [Any] {
    if let requestType = params["requestType"] as? String, let dataSource = dataSource {
      var newParams = RequestParams()

      newParams["requestType"] = requestType
      newParams["identifier"] = requestType == "Search" ? params["query"] as? String : params["parentId"] as? String
      newParams["parentName"] = params["parentName"]
      newParams["bookmarks"] = bookmarks
      newParams["history"] = history
      newParams["selectedItem"] = params["selectedItem"]
      newParams["document"] = document
      newParams["pageSize"] = pageLoader.pageSize
      newParams["currentPage"] = pageLoader.currentPage

      return try dataSource.load(params: newParams)
    }
    else {
      return []
    }
  }

  override func buildLayout() -> UICollectionViewFlowLayout? {
    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 200*1.2, height: 300*1.2) // 200 x 300
    layout.sectionInset = UIEdgeInsets(top: 40.0, left: 40.0, bottom: 120.0, right: 40.0)
    layout.minimumInteritemSpacing = 40.0
    layout.minimumLineSpacing = 140.0

    layout.headerReferenceSize = CGSize(width: 500, height: 75)

    return layout
  }

  override func getDetailsImageFrame() -> CGRect? {
    return CGRect(x: 40, y: 40, width: 210*2.7, height: 300*2.7)
  }

  override func getUrl(_ params: [String: Any]) throws -> String {
    let bitrate = params["bitrate"] as! [String: String]

    return bitrate["url"]!
  }

  override func retrieveExtraInfo(_ item: MediaItem) throws {
    let movieUrl = item.id!

    if item.type == "movie" {
      let document = try service.fetchDocument(movieUrl)

      let mediaData = try service.getMediaData(document!)

      var text = ""

      if let year = mediaData["year"] as? String {
        text += "\(year)\n"
      }

      if let countries = mediaData["countries"] as? [String] {
        let txt = countries.joined(separator: ", ")

        text += "\(txt)\n"
      }

      if let duration = mediaData["duration"] as? String {
        text += "\(duration)\n\n"
      }

      if let tags = mediaData["tags"] as? [String] {
        let txt = tags.joined(separator: ", ")

        text += "\(txt)\n"
      }

      if let summary = mediaData["summary"] as? String {
        text += "\(summary)\n"
      }

      item.description = text
    }
  }

  override func addBookmark(item: MediaItem) -> Bool {
    return bookmarks.addBookmark(item: item)
  }

  override func removeBookmark(item: MediaItem) -> Bool {
    return bookmarks.removeBookmark(item: item)
  }

  override func addHistoryItem(_ item: MediaItem) {
    history.add(item: item)
  }

}
