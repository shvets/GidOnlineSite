import UIKit
import Runglish
import TVSetKit

class SearchController: UIViewController {
  @IBOutlet weak var query: UITextField!
  @IBOutlet weak var transcodedQuery: UILabel!
  @IBOutlet weak var useRunglish: UIButton!
  @IBOutlet weak var useRunglishLabel: UILabel!
  @IBOutlet weak var searchButton: UIButton!

  public var adapter: ServiceAdapter!
  var localizer = Localizer("com.rubikon.GidOnlineSite")

  var params = [String: Any]()

  let checkedImage = UIImage(named: "ic_check_box")! as UIImage
  let uncheckedImage = UIImage(named: "ic_check_box_outline_blank")! as UIImage

  static public func instantiate() -> Self {
    let bundle = Bundle(identifier: "com.rubikon.GidOnlineSite")!

    return AppStoryboard.instantiateController( "GidOnline", bundle: bundle, viewControllerClass: self)
  }

  var isChecked: Bool = false {
    didSet {
      if isChecked == true {
        useRunglish.setImage(checkedImage, for: .normal)
      }
      else {
        useRunglish.setImage(uncheckedImage, for: .normal)
      }
    }
  }
  
  override open func viewDidLoad() {
    super.viewDidLoad()

    isChecked = true

    useRunglishLabel.text = localizer.localize(useRunglishLabel.text!)
    searchButton.setTitle(localizer.localize(searchButton.title(for: .normal)!), for: .normal)
    query.placeholder = localizer.localize(query.placeholder!)
    
    query.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
  }
  
  func textFieldDidChange(textField: UITextField) {
    if isChecked {
      let transcoded = LatToRusConverter().transliterate(query.text!)
      
      transcodedQuery.text = transcoded
    }
    else {
      transcodedQuery.text = ""
    }
  }

  @IBAction func onSearchAction(_ sender: UIButton) {
    let controller = MediaItemsController.instantiate(adapter).getActionController()
    let destination = controller as! MediaItemsController

    if isChecked {
      let transcoded = LatToRusConverter().transliterate(query.text!)

      adapter.query = transcoded
      transcodedQuery.text = transcoded
    }
    else {
      adapter.query = query.text
    }

    destination.adapter = adapter

    destination.collectionView?.collectionViewLayout = adapter.buildLayout()!

    show(controller!, sender: destination)
  }
  
  @IBAction func onUseRunglish(_ sender: UIButton) {
    isChecked = !isChecked
  }
}
