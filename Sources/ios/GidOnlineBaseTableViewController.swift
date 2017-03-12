import TVSetKit

open class GidOnlineBaseTableViewController: BaseTableViewController {
  open var CellIdentifier: String {
    return ""
  }

  let service = GidOnlineService.shared

  let localizer = Localizer("com.rubikon.GidOnlineSite")

  override open func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! MediaNameTableCell

//    if adapter.nextPageAvailable(dataCount: items.count, index: indexPath.row) {
//      loadMoreData(indexPath.row)
//    }

    let item = items[indexPath.row]

    let localizedName = localizer.localize(item.name!)

    cell.configureCell(item: item, localizedName: localizedName)

    return cell
  }
}