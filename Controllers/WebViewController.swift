import UIKit
import WebKit

protocol WebViewControllerDelegate: class {
    func update(dict: [String: String])
}
class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var imgurWebView: WKWebView!
    var request: URLRequest?
    var testArray: [String] = []
    var testDictionary: [String: String] = [:]
    var scheme = String()

    weak var webDelegate: WebViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backItem?.hidesBackButton = true
        self.navigationItem.setHidesBackButton(true, animated: true)

        if let urlRequest = request {
            imgurWebView.load(urlRequest)
        }
        imgurWebView.navigationDelegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        webDelegate?.update(dict: testDictionary)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
        if let uRLString = navigationAction.request.url?.absoluteString {
            if uRLString.contains("access_token") {
                testArray = uRLString.split(separator: "&").map { substring -> String in String(substring) }
                self.scheme = String(testArray[0].prefix(12))
                testArray[0].removeFirst(12)
                testDictionary = testArray.reduce(into: testDictionary) { into, string in
                    let callbackData = string.split(separator: "=").map { substring -> String in
                        String(substring)
                    }
                    into[callbackData[0]] = callbackData[1]
                }
            }
            if scheme.isEmpty == false {
                self.navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil)
            }
        }
    }
}
