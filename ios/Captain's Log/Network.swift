//
//  Network.swift
//  Captain's Log
//
//  Created by Marcos Minond on 3/8/20.
//  Copyright © 2020 Marcos Minond. All rights reserved.
//

import Foundation
import Combine

class Login: ObservableObject {
  var didChange = PassthroughSubject<Login, Never>()

  var authenticated = false {
    didSet {
      didChange.send(self)
    }
  }

  func run(email: String, password: String) {
    guard let url = URL(string: "http://localhost:3000/api/v1/token") else { return }
    let contents = ["email": email, "password": password]
    let body = try! JSONSerialization.data(withJSONObject: contents)

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { (data, response, error) in
      guard let data = data else { return }
      let body = try! JSONDecoder().decode(TokenCreateResponse.self, from: data)
      print(body.token)
    }.resume()
  }
}

struct TokenCreateResponse: Decodable {
  let token: String
}
