//
//  Network.swift
//  Captain's Log
//
//  Created by Marcos Minond on 3/8/20.
//  Copyright © 2020 Marcos Minond. All rights reserved.
//

import Foundation
import Combine

struct TokenCreateResponse: Decodable {
  let token: String
}

func newRequest(_ method: String, _ endpoint: String) -> URLRequest? {
  guard let url = URL(string: "http://localhost:3000\(endpoint)") else { return nil }
  var request = URLRequest(url: url)
  request.httpMethod = method
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  return request
}

func newPostRequest(_ endpoint: String, contents: Any?) -> URLRequest? {
  guard var request = newRequest("POST", endpoint) else { return nil }

  if contents != nil {
    guard let contents = contents else { return nil }
    let body = try! JSONSerialization.data(withJSONObject: contents)
    request.httpBody = body
  }

  return request
}

func makeRequest<T>(
  _ type: T.Type,
  _ request: URLRequest,
  completionHandler: @escaping (T?, Error?) -> Void
) where T : Decodable {
  URLSession.shared.dataTask(with: request) { (data, response, error) in
    guard let data = data else { return completionHandler(nil, nil) }
    let body = try! JSONDecoder().decode(type, from: data)
    completionHandler(body, nil)
  }.resume()
}

class Session: ObservableObject {
  @Published var authenticated = false

  private var token = ""

  func login(email: String, password: String) {
    self.authenticated = false

    let contents = ["email": email, "password": password]
    guard let request = newPostRequest("/api/v1/token", contents: contents) else { return }

    makeRequest(TokenCreateResponse.self, request) { (response, error) in
      guard let response = response else { return }
      DispatchQueue.main.async {
        self.authenticated = true
        self.token = response.token
      }
    }
  }
}
