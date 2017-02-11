import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GidOnlineServiceAdapter: ServiceAdapter {
  let service = GidOnlineService.shared

  static let bookmarksFileName = NSHomeDirectory() + "/Library/Caches/gidonline-bookmarks.json"
  static let historyFileName = NSHomeDirectory() + "/Library/Caches/gidonline-history.json"

  lazy var bookmarks = Bookmarks(bookmarksFileName)
  lazy var history = History(historyFileName)

  var episodes: [JSON]?

  var document: Document?

  init() {
    super.init(configName: NSHomeDirectory() + "/Library/Caches/settings.json")

    bookmarks.load()
    history.load()

    do {
      document = try service.fetchDocument(GidOnlineAPI.SITE_URL)!
    }
    catch {
      print("Error fetching document")
    }

    provider = "GID_ONLINE"

    pageSize = 12
    rowSize = 6
  }

  override open func clone() -> ServiceAdapter {
    let cloned = GidOnlineServiceAdapter()

    cloned.clear()

    return cloned
  }

  override func load() throws -> [MediaItem] {
    let dataSource = GidOnlineDataSource()

    var params = RequestParams()

    params.identifier = requestType == "SEARCH" ? query : parentId
    params.parentName = parentName
    params.bookmarks = bookmarks
    params.history = history
    params.selectedItem = selectedItem
    params.document = document

    return try dataSource.load(requestType!, params: params, pageSize: pageSize, currentPage: currentPage)
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
    let id = params["id"] as! String
    let mediaItem = params["item"] as! MediaItem

    let urls = try service.getUrls(id, season: mediaItem.seasonNumber!, episode: mediaItem.episodeNumber!)

    var newUrls: [String] = []

    for url in urls {
      newUrls.append(url["url"]!)
    }

    return newUrls[0]
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
