//
//  ContentView.swift
//  Captain's Log
//
//  Created by Marcos Minond on 3/7/20.
//  Copyright © 2020 Marcos Minond. All rights reserved.
//

import SwiftUI
import Network

let lightGreyColor = Color(
  red: 239.0/255.0,
  green: 243.0/255.0,
  blue: 244.0/255.0, opacity: 1.0)

struct ContentView: View {
  @State private var email: String = ""
  @State private var password: String = ""
  @ObservedObject private var session = Session()

  var body: some View {
    VStack {
      Image("logo")
        .padding(.top, 40)
        .padding(.bottom, 60)
      TextField("Email", text: $email)
        .padding()
        .background(lightGreyColor)
        .cornerRadius(5.0)
        .padding(.bottom, 20)
      SecureField("Password", text: $password)
        .padding()
        .background(lightGreyColor)
        .cornerRadius(5.0)
        .padding(.bottom, 20)
      Button(action: {
        self.session.login(email: self.email, password: self.password)
      }) {
         Text("Continue")
           .foregroundColor(.blue)
           .padding()
      }

      if self.session.authenticated {
        Text("authenticated")
      }

      Spacer()
    }
      .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
