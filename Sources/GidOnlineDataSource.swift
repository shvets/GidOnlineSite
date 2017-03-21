import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GidOnlineDataSource: DataSource {
  let service = GidOnlineService.shared

  func load(_ requestType: String, params: RequestParams, pageSize: Int, currentPage: Int) throws -> [MediaItem] {
    var result: [Any] = []

    let identifier = params.identifier
    let bookmarks = params.bookmarks!
    let history = params.history!
    let selectedItem = params.selectedItem
    let document = params.document as! Document

    var request = requestType

    if selectedItem?.type == "serie" {
      request = "SEASONS"
    }
    else if selectedItem?.type == "season" {
      request = "EPISODES"
    }

    switch request {
      case "BOOKMARKS":
        bookmarks.load()
        result = bookmarks.getBookmarks(pageSize: pageSize, page: currentPage)

      case "HISTORY":
        history.load()
        result = history.getHistoryItems(pageSize: pageSize, page: currentPage)

      case "ALL_MOVIES":
        result = try service.getAllMovies(page: currentPage)["movies"] as! [Any]

      case "MOVIES":
        let id = selectedItem!.id

        let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + "/" + id!, page: currentPage))

        result = try service.getMovies(document!, path: id!)["movies"] as! [Any]

      case "GENRES":
        result = try service.getGenres(document)

      case "THEMES":
        let theme = selectedItem!.name

        if theme == "TOP_SEVEN" {
          result = try service.getTopLinks(document)
        }
        else if theme == "NEW_MOVIES" {
          let id = "/new/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + id, page: currentPage))

          result = try service.getMovies(document!, path: id)["movies"] as! [Any]
        }
        else if theme == "PREMIERS" {
          let id = "/premiers/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + id, page: currentPage))

          result = try service.getMovies(document!, path: id)["movies"] as! [Any]
        }

      case "FILTERS":
        let theme = selectedItem!.name

        if theme == "BY_ACTORS" {
          result = try service.getTopLinks(document)
        }
        else if theme == "BY_DIRECTORS" {
          let id = "/new/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + id, page: currentPage))

          result = try service.getMovies(document!, path: id)["movies"] as! [Any]
        }
        else if theme == "BY_COUNTRIES" {
          let id = "/premiers/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + id, page: currentPage))

          result = try service.getMovies(document!, path: id)["movies"] as! [Any]
        }
        else if theme == "BY_YEARS" {
          let id = "/premiers/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + id, page: currentPage))

          result = try service.getMovies(document!, path: id)["movies"] as! [Any]
        }

      case "SEASONS":
        result = try service.getSeasons(identifier!, parentName: params.parentName!, thumb: selectedItem?.thumb)

      case "EPISODES":
        result = try service.getEpisodes(selectedItem!.parentId!, seasonNumber: selectedItem!.id!, thumb: selectedItem?.thumb)

      case "SEARCH":
        if !identifier!.isEmpty {
          result = try service.search(identifier!, page: currentPage)["movies"] as! [Any]
        }

      default:
        result = []
    }

    return convertToMediaItems(result)
  }

  func convertToMediaItems(_ items: [Any]) -> [MediaItem] {
    var newItems = [MediaItem]()

    for item in items {
      var jsonItem = item as? JSON

      if jsonItem == nil {
        jsonItem = JSON(item)
      }

      let movie = GidOnlineMediaItem(data: jsonItem!)

      newItems += [movie]
    }

    return newItems
  }
}