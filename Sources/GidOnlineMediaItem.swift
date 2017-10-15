import UIKit
import SwiftyJSON
import WebAPI
import TVSetKit

class GidOnlineMediaItem: MediaItem {
  let service = GidOnlineService.shared

  override func isContainer() -> Bool {
    return type == "serie" || type == "season"
  }

  override func resolveType() {
    var serial = false

    do {
      serial = try service.isSerial(id!)
    }
    catch {
      print("cannot check if it is serial.")
    }

    if serial {
      type = "serie"
    }
    else {
      type = "movie"
    }
  }

  override func getBitrates() throws -> [[String: String]] {
    var bitrates: [[String: String]] = []

    let urls = try GidOnlineAPI(proxy: true).getUrls(id!, season: seasonNumber!, episode: episodeNumber!)

    let qualityLevels = QualityLevel.availableLevels(urls.count)

    for (index, item) in urls.enumerated() {
      var bitrate: [String: String] = [:]
      bitrate["id"] = item["bandwidth"]
      bitrate["url"] = item["url"]

      bitrate["name"] = qualityLevels[index].rawValue

      bitrates.append(bitrate)
    }

    return bitrates
  }

  override func retrieveExtraInfo() throws {
    if type == "movie" {
      let document = try service.fetchDocument(id!)

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

      description = text
    }
  }
}
