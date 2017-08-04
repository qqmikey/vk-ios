//
//  VK.swift
//  vkauth
//
//  Created by Mikhail Rymarev on 03.08.17.
//  Copyright © 2017 Mikhail Rymarev. All rights reserved.
//

import Foundation
import Alamofire

struct User {
    var id: Int64
    var name: String
    var image: VKImage?
}

class VK {
    
    var apiVersion: String = "5.67"
    var methodName: String? = nil
    
    init(apiVersion: String?=nil, method: String?=nil) {
        if apiVersion != nil {
            self.apiVersion = apiVersion!
        }
        if method != nil {
            self.methodName = method!
        }
    }
    
    func apiUrl() -> String? {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            return nil
        }
        
        guard let method = self.methodName else {
            return nil
        }
        return "https://api.vk.com/method/\(method)?access_token=\(accessToken)&v=\(self.apiVersion)"
    }
    
    func sendMessage(to: User, text: String?=nil, image: UIImage?=nil, cb: @escaping (String?, Any?) -> ()) {
        guard let message = text else {
            return
        }
        
        var parameters = [
            "user_id": to.id,
            "message": message
        ] as [String : Any]
        
        if let img = image {
            uploadAndSaveImage(image: img) { data in
                if let ownerId = data["owner_id"] as? Int64, let mediaId = data["id"] as? Int64 {
                    parameters["attachment"] = "photo\(ownerId)_\(mediaId)"
                    VK(method: "messages.send").request(parameters: parameters, cb: cb)
                }
            }
        } else {
            VK(method: "messages.send").request(parameters: parameters, cb: cb)
        }
    
    }
    
    
    
    func uploadAndSaveImage(image: UIImage, cb: @escaping ([String: Any]) -> ()) {
        getUploadServer() { uploadUrl in
            self.uploadImage(image: image, uploadUrl: uploadUrl) { server, photo, hash in
                let parameters = [
                    "server": server,
                    "photo": photo,
                    "hash": hash
                ] as [String : Any]
                VK(method: "photos.saveMessagesPhoto").request(parameters: parameters) { error, response in
                    if let res = response as? [[String: Any]] {
                        if res.count > 0 {
                            if let uploadedImage = res[0] as? [String: Any] {
                                cb(uploadedImage)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getUploadServer(cb: @escaping (String) -> ()) {
        VK(method: "photos.getMessagesUploadServer").request() { error, response in
            if error == nil, let res = response as? [String: Any], let serverUrl = res["upload_url"] as? String {
                cb(serverUrl)
            }
        }
    }
    
    func getFriends(page: Int=1, cb: @escaping ([User]) -> ()) {
        self.methodName = "friends.get"
        if let userId = UserDefaults.standard.string(forKey: "userId")  {
            let offset = 30 * (page - 1)
            let parameters = [
                "user_id": userId,
                "fields": "nickname, photo_50, contacts",
                "count": 30,
                "offset": offset
            ] as [String : Any]
            self.request(parameters: parameters) { error, response in
                if let errorMessage = error {
                    print(errorMessage)
                } else {
                    var users = [User]()
                    if let res = response as? [String: Any], let items = res["items"] as? [Any] {
                        for item in items {
                            if let userJson = item as? [String: Any] {
                                if let imgUrl = userJson["photo_50"] as? String, let firstName = userJson["first_name"] as? String, let lastName = userJson["last_name"] as? String, let id = userJson["id"] as? Int64 {
                                    let user = User(id: id, name: "\(firstName) \(lastName)", image: VKImage(url: imgUrl))
                                    users += [user]
                                }
                            }
                        }
                        cb(users)
                    }
                    
                    
                }
            }
        }
        
    }
    
    
    func request(parameters: [String: Any]?=nil, cb: @escaping (String?, Any?) -> ()) {
        guard let url = self.apiUrl() else {
            return
        }
        
        Alamofire.request(url, parameters: parameters).responseJSON { response in
            if let json = response.result.value as? [String: Any] {
                if let error = json["error"] as? [String: Any], let errorMsg = error["error_msg"] as? String {
                    cb(errorMsg, nil)
                } else {
                    cb(nil, json["response"])
                }
            }

        }
    }
    
    func uploadImage(image: UIImage, uploadUrl: String, cb: @escaping (_ server: Int64, _ photo: String, _ hash: String) -> ()) {
        
        guard let imageData = UIImagePNGRepresentation(image) else {
            return
        }

        Alamofire.upload(multipartFormData:{ multipartFormData in
            multipartFormData.append(imageData, withName: "photo", fileName: "test.png", mimeType: "image/png")},
                         to: uploadUrl,
                         method:.post,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    if let json = response.result.value as? [String: Any] {
                                        if let server = json["server"] as? Int64, let photo = json["photo"] as? String, let hash = json["hash"] as? String {
                                            cb(server, photo, hash)
                                        }
                                        
                                    }
                                }
                            case .failure(let encodingError):
                                print(encodingError)
                            }
        })
        
    }
    
   
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    class func login(userId: String, accessToken: String, expires: String) {
        let defaults = UserDefaults.standard
        defaults.set(userId, forKey: "userId")
        defaults.set(accessToken, forKey: "accessToken")
        defaults.set(expires, forKey: "expires")
        defaults.synchronize()
    }
    
    class func logout() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if  let _ = cookie.domain.range(of: "vk.com") {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                }
            }
        }
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "userId")
        defaults.set(nil, forKey: "accessToken")
        defaults.set(nil, forKey: "expires")
        defaults.synchronize()
    }
    
    class func isAuthorized() -> Bool {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "userId") {
            return true
        }
        return false
    }
}

class VKImage {
    var name: String?
    var image: UIImage?
    var src: URL?
    
    init() {}
    
    init(url: String) {
        self.src = URL(string: url)
    }
    
}
