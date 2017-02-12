import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GidOnlineDataSource: DataSource {
  let service = GidOnlineService.shared

  func load(_ requestType: String, params: RequestParams, pageSize: Int, currentPage: Int) throws -> [MediaItem] {
    var result: [String: Any] = [:]

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
        result = ["movies": bookmarks.getBookmarks(pageSize: pageSize, page: currentPage)]

      case "HISTORY":
        history.load()
        result = ["movies": history.getHistoryItems(pageSize: pageSize, page: currentPage)]

      case "ALL_MOVIES":
        result = try service.getAllMovies(page: currentPage)

      case "MOVIES":
        let id = selectedItem!.id

        let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SITE_URL + "/" + id!, page: currentPage))

        result = try service.getMovies(document!, path: id!)

      case "GENRES":
        result["movies"] = try service.getGenres(document)

      case "THEMES":
        let theme = selectedItem!.name

        if theme == "TOP_SEVEN" {
          result["movies"] = try service.getTopLinks(document)
        }
        else if theme == "NEW_MOVIES" {
          let id = "/new/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SITE_URL + id, page: currentPage))

          result = try service.getMovies(document!, path: id)
        }
        else if theme == "PREMIERS" {
          let id = "/premiers/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SITE_URL + id, page: currentPage))

          result = try service.getMovies(document!, path: id)
        }

      case "FILTERS":
        let theme = selectedItem!.name

        if theme == "BY_ACTORS" {
          result["movies"] = try service.getTopLinks(document)
        }
        else if theme == "BY_DIRECTORS" {
          let id = "/new/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SITE_URL + id, page: currentPage))

          result = try service.getMovies(document!, path: id)
        }
        else if theme == "BY_COUNTRIES" {
          let id = "/premiers/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SITE_URL + id, page: currentPage))

          result = try service.getMovies(document!, path: id)
        }
        else if theme == "BY_YEARS" {
          let id = "/premiers/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SITE_URL + id, page: currentPage))

          result = try service.getMovies(document!, path: id)
        }

      case "SEASONS":
        do {
          let seasons = try service.getSeasons(identifier!, parentName: params.parentName!, thumb: selectedItem?.thumb)

          result = ["movies": seasons]
        }
        catch {
          print("Error getting seasons")
        }

      case "EPISODES":
        let parentId = selectedItem.parentId

        let episodes = try service.getEpisodes(parentId!, seasonNumber: selectedItem!.id!, thumb: selectedItem?.thumb)

        result = ["movies": episodes]

      case "SEARCH":
        let query = identifier!

        result = try service.search(query, page: currentPage)

      default:
        result = [:]
    }

    var newItems = [MediaItem]()

    if result["movies"] != nil {
      let result2 = result["movies"] as! [Any]

      for item in result2 {
        var jsonItem = item as? JSON

        if jsonItem == nil {
          jsonItem = JSON(item)
        }

        let movie = GidOnlineMediaItem(data: jsonItem!)

        newItems += [movie]
      }
    }

    return newItems
  }
}