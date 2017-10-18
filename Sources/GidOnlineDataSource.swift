import SwiftSoup
import SwiftyJSON
import WebAPI
import TVSetKit

class GidOnlineDataSource: DataSource {
  let service = GidOnlineService.shared

  override open func load(params: Parameters) throws -> [Any] {
    var result: [Any] = []

//    let bookmarks = params["bookmarks"] as! Bookmarks
//    let history = params["history"] as! History
    let selectedItem = params["selectedItem"] as? Item
    let document = params["document"] as! Document

    var request = params["requestType"] as! String
    //let pageSize = params["pageSize"] as? Int
    let currentPage = params["currentPage"] as! Int

    if let selectedItem = selectedItem as? MediaItem {
      if selectedItem.type == "serie" {
        request = "Seasons"
      }
      else if selectedItem.type == "season" {
        request = "Episodes"
      }
    }

    switch request {
      case "Bookmarks":
        if let bookmarks = params["bookmarks"]  as? Bookmarks {
          result = bookmarks.getBookmarks(pageSize: 60, page: currentPage)
        }

      case "History":
        if let history = params["history"] as? History {
          result = history.getHistoryItems(pageSize: 60, page: currentPage)
        }

      case "All Movies":
        result = try service.getAllMovies(page: currentPage)["movies"] as! [Any]

      case "Movies":
        if let selectedItem = selectedItem, let id = selectedItem.id {
          let document = try service.fetchDocument(service.getPagePath(GidOnlineAPI.SiteUrl + "/" + id, page: currentPage))

          result = try service.getMovies(document!, path: id)["movies"] as! [Any]
        }

      case "Genres":
        result = try service.getGenres(document)

      case "Themes":
        if let selectedItem = selectedItem {
          let theme = selectedItem.name

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
        }

      case "Filters":
        if let selectedItem = selectedItem {
          let theme = selectedItem.name

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
        }

      case "Seasons":
        if let identifier = params["parentId"] as? String, let selectedItem = selectedItem as? MediaItem {
          result = try service.getSeasons(identifier, parentName: params["parentName"] as? String, thumb: selectedItem.thumb)
        }

      case "Episodes":
        if let selectedItem = selectedItem as? MediaItem {
          result = try service.getEpisodes(selectedItem.parentId!, seasonNumber: selectedItem.id!, thumb: selectedItem.thumb)
        }

      case "Search":
        if let query = params["query"] as? String {
          if !query.isEmpty {
            result = try service.search(query, page: currentPage)["movies"] as! [Any]
          }
        }

      default:
        result = []
    }

    return convertToMediaItems(result)
  }

  func convertToMediaItems(_ items: [Any]) -> [Item] {
    var newItems = [Item]()

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
