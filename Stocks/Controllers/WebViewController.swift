import UIKit
import WebKit

class WebViewController: UIViewController {
    var webView =  WKWebView()
    var _url = String()
    init(url : String) {
        super.init(nibName: nil, bundle: nil)
        _url = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupWebView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    func setupWebView() {
        self.view.addSubview(webView)
        webView.frame = self.view.bounds
        webView.load(URLRequest(url: URL(string: _url)!))
    }
}
