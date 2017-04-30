import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GidOnlineDataSource: DataSource {
  let service = GidOnlineService.shared

  func load(_ requestType: String, params: RequestParams, pageSize: Int, currentPage: Int, convert: Bool=true) throws -> [Any] {
    var result: [Any] = []

    let identifier = params.identifier
    let bookmarks = params.bookmarks!
    let history = params.history!
    let selectedItem = params.selectedItem
    let document = params.document as! Document

    var request = requestType

    if selectedItem?.type == "serie" {
      request = "Seasons"
    }
    else if selectedItem?.type == "season" {
      request = "Episodes"
    }

    switch request {
      case "Bookmarks":
        bookmarks.load()
        result = bookmarks.getBookmarks(pageSize: 60, page: currentPage)

      case "History":
        history.load()
        result = history.getHistoryItems(pageSize: 60, page: currentPage)

      case "All Movies":
        result = try service.getAllMovies(page: currentPage)["movies"] as! [Any]

      case "Movies":
        let id = selectedItem!.id

        let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + "/" + id!, page: currentPage))

        result = try service.getMovies(document!, path: id!)["movies"] as! [Any]

      case "Genres":
        result = try service.getGenres(document)

      case "Themes":
        let theme = selectedItem!.name

        if theme == "Top Seven" {
          result = try service.getTopLinks(document)
        }
        else if theme == "New Movies" {
          let id = "/new/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + id, page: currentPage))

          result = try service.getMovies(document!, path: id)["movies"] as! [Any]
        }
        else if theme == "Premiers" {
          let id = "/premiers/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + id, page: currentPage))

          result = try service.getMovies(document!, path: id)["movies"] as! [Any]
        }

      case "Filters":
        let theme = selectedItem!.name

        if theme == "By Actors" {
          result = try service.getTopLinks(document)
        }
        else if theme == "By Directors" {
          let id = "/new/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + id, page: currentPage))

          result = try service.getMovies(document!, path: id)["movies"] as! [Any]
        }
        else if theme == "By Countries" {
          let id = "/premiers/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + id, page: currentPage))

          result = try service.getMovies(document!, path: id)["movies"] as! [Any]
        }
        else if theme == "By Years" {
          let id = "/premiers/"

          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + id, page: currentPage))

          result = try service.getMovies(document!, path: id)["movies"] as! [Any]
        }

      case "Seasons":
        result = try service.getSeasons(identifier!, parentName: params.parentName!, thumb: selectedItem?.thumb)

      case "Episodes":
        result = try service.getEpisodes(selectedItem!.parentId!, seasonNumber: selectedItem!.id!, thumb: selectedItem?.thumb)

      case "Search":
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