import Foundation
import UIKit

struct NetworkManager {

    private let baseURL = "https://api.imgur.com"
    let clientID = ClientData.clientId
    var page = 1

    func fetchGallery(
        sections: String,
        sort: String,
        window: String,
        page: Int,
        closure: @escaping (GalleryResponse) -> Void
    ) {

        let query = "/3/gallery/\(sections)/\(sort)/\(window)/\(page)?showViral=true&mature=true&album_previews=true"
        let urlString = baseURL + query
        let httpHeaders = ["Authorization": "Client-ID \(clientID)"]
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = httpHeaders
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            if let error = error {
                print(error)
            }
            if let data = data {
                if let gallery: GalleryResponse = self.parseJSON(withData: data) {
                    DispatchQueue.main.async {
                        closure(gallery)
                    }
                }
            }
        }
        .resume()
    }

    func fetchImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        let imageURL = URL(string: urlString)
        DispatchQueue.global(qos: .utility).async {
            guard let url = imageURL, let imageData = try? Data(contentsOf: url) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(UIImage(data: imageData))
            }
        }
    }

    func fetchComment(sort: String, albumId: String, closure: @escaping (GalleryCommentResponse) -> Void) {

        let urlString = baseURL + "/3/gallery/\(albumId)/comments/\(sort)"
        let httpHeaders = ["Authorization": "Client-ID \(clientID)"]

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = httpHeaders

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            if let error = error {
                print(error)
            }
            if let data = data {
                if let comment: GalleryCommentResponse = self.parseJSON(withData: data) {
                    DispatchQueue.main.async {
                        closure(comment)
                    }
                }
            }
        }
        .resume()
    }

    // MARK: - Account conteinment block

    func fetchAcountBase(userName: String, closure: @escaping (AccountBaseResponse) -> Void) {
        let urlString = baseURL + "/3/account/\(userName)"
        let httpHeaders = ["Authorization": "Client-ID \(clientID)"]

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = httpHeaders

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            if let error = error {
                print(error)
            }
            if let data = data {
                if let accountBase: AccountBaseResponse = self.parseJSON(withData: data) {
                    DispatchQueue.main.async {
                        closure(accountBase)
                    }
                }
            }
        }
        .resume()
    }

    func authorization(accessTokken: String) {
        let urlString = baseURL + "/oauth2/authorize?client_id=960fe8e1862cf58&response_type=token"
        let httpHeaders = ["Authorization": "Bearer \(accessTokken)"]
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.allHTTPHeaderFields = httpHeaders
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            if let error = error {
                print(error)
            }
            if let data = data {
                print(data)
            }
        }
        .resume()
    }

    func fetchAccImage(closure: @escaping (AccGalleryResp) -> Void) {
        if let accessToken = AuthorizationData.authorizationData["access_token"] {
            let urlString = baseURL + "/3/account/me/images"
            let httpHeaders = ["Authorization": "Bearer \(accessToken)"]
            guard let url = URL(string: urlString) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = httpHeaders
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let response = response {
                    print(response)
                }
                if let error = error {
                    print(error)
                }
                if let data = data {
                    if let gallery: AccGalleryResp = self.parseJSON(withData: data) {
                        DispatchQueue.main.async {
                            closure(gallery)
                        }
                    }
                }
            }
            .resume()
        }
    }

    func fetchAccComment(userName: String, page: Int, sort: String, closure: @escaping (AccCommentsResp) -> Void) {

        guard let accessTokken = AuthorizationData.authorizationData["access_token"] else {
            print("\(Self.self) now have Access Tokken")
            return
        }
        let urlString = baseURL + "/3/account/\(userName)/comments/\(sort)/\(page)"
        let httpHeaders = ["Authorization": "Bearer \(accessTokken)"]
        guard let url = URL(string: urlString) else { print("\(Self.self) string is not valid URLString")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = httpHeaders

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            if let error = error {
                print(error)
            }
            if let data = data {
                if let comment: AccCommentsResp = self.parseJSON(withData: data) {
                    DispatchQueue.main.async {
                        closure(comment)
                    }
                }
            }
        }
        .resume()
    }

    func fetchAccFavorites(name: String, accessToken: String, closure: @escaping (AccFavoritesResp) -> Void) {
        let urlString = baseURL + "/3/account/\(name)/favorites/0/newest"
        let httpHeaders = ["Authorization": "Bearer \(accessToken)"]
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = httpHeaders
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            if let error = error {
                print(error)
            }
            if let data = data {
                if let favorite: AccFavoritesResp = self.parseJSON(withData: data) {
                    DispatchQueue.main.async {
                        closure(favorite)
                    }
                }
            }
        }
        .resume()
    }

    // Parse JSON
    func parseJSON<T>(withData data: Data) -> T? where T: Codable {
        let decoder = JSONDecoder()
        do {
            let galleryData = try decoder.decode(T.self, from: data)
            return galleryData
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
