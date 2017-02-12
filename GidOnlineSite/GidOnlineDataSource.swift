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
          var movies: [MediaItem] = []

          let index1 = identifier!.index(identifier!.startIndex, offsetBy: GidOnlineAPI.SITE_URL.characters.count)
          let index2 = identifier!.endIndex
          let path = identifier![index1 ..< index2]
          let seasons = try service.getSeasons(path) as! [[String: String]]

          for season  in seasons {
            let mediaItem = GidOnlineMediaItem(data: JSON(["name": season["name"]!, "id": season["id"]!]))

            mediaItem.type = "season"
            mediaItem.thumb = selectedItem?.thumb
            mediaItem.parentName = params.parentName!
            mediaItem.parentId = identifier!

            movies.append(mediaItem)
          }

          result = ["seasons": movies]
        }
        catch {
          print("Error getting seasons")
        }

      case "EPISODES":
        var movies: [MediaItem] = []

        let parentId = (selectedItem as! GidOnlineMediaItem).parentId

        let serialInfo = try service.getSerialInfo(parentId!, season: selectedItem!.id!, episode: "1")

        let episodes = serialInfo["episodes"] as! [String]

        for episode in episodes {
          let index1 = episode.index(episode.startIndex, offsetBy: 6)
          let index2 = episode.endIndex

          let episodeNumber = episode[index1..<index2]

          let mediaItem = GidOnlineMediaItem(data: JSON(["name": episode, "id": parentId!]))

          mediaItem.type = "episode"
          mediaItem.thumb = selectedItem?.thumb
          mediaItem.seasonNumber = selectedItem!.id!
          mediaItem.episodeNumber = episodeNumber

          movies.append(mediaItem)
        }

        result = ["episodes": movies]

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
    else if result["seasons"] != nil {
      newItems = result["seasons"] as! [MediaItem]
    }
    else if result["episodes"] != nil {
      newItems = result["episodes"] as! [MediaItem]
    }

    return newItems
  }
}