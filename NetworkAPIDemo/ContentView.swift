//
//  ContentView.swift
//  NetworkAPIDemo
//
//  Created by Nico Prananta on 29.09.21.
//

import SwiftUI

struct ContentView: View {
  @State var error: NSError?
  @State var isLoading: Bool = false
  @State var counter = 0
  @State var posts = [Post]()
  @State var progress = 0.0
  
  func createNewPost () async throws -> Post {
    let newPost = Post(id: 0, title: "New title \(counter)", body: "New Body  \(counter)")
    let createdPost = try await API().fetch(NewPostRequest(newPost: newPost))
    return createdPost
  }
  
  func uploadCover () async throws -> [Uploaded] {
    progress = 0.0
    var data: Data?
    if let url = Bundle.main.url(forResource: "ipadmini", withExtension: "png") {
      data = try Data(contentsOf: url)
      let image = UIImage(data: data!)
      data = image?.pngData()
    }
    
    let file = MultipartData(data: data!, name: "files", fileName: "ipadmini-\(counter).png", mimeType: "image/png")
    let uploadPost = try await API().fetch(UploadRequest(file: file), progress: $progress)
    return uploadPost
  }
  
  var body: some View {
    VStack(spacing: 30) {
      Text("Number of posts: \(posts.count)")
        .padding()
      Text("Upload progress: \(progress)")
        .padding()
      Text("Counter: \(counter)")
        .padding()
        .alert(isPresented: $error.mappedToBool()) {
          Alert(title: Text("Error"),
                message: Text(error?.localizedDescription ?? ""),
                dismissButton: .default(Text("Close")))
        }
      Button("Count") {
        counter += 1
      }
      Button("Create new post") {
        isLoading = true
        Task {
          do {
            let created = try await createNewPost()
            print(created)
            let posts = try await API().fetch(PostsRequest())
            self.posts = posts
            self.isLoading = false
          } catch let error as NSError {
            self.error = error
            self.isLoading = false
          }
        }
      }
      .opacity(isLoading ? 0.5 : 1)
      .disabled(isLoading)
      
      Button("Upload cover") {
        isLoading = true
        Task {
          do {
            let uploaded = try await uploadCover()
            print(uploaded)
            self.isLoading = false
          } catch let error as NSError {
            self.error = error
            self.isLoading = false
          }
        }
      }
      .opacity(isLoading ? 0.5 : 1)
      .disabled(isLoading)
    }
    .task {
      do {
        let authData = try await API().fetch(
          LoginRequest(loginData:
                        LoginData(identifier: "nico.prananta@gmail.com",
                                  password: "abcd123ABCD####")
                      )
        )
        print(authData)
        let tokenProvider = AccessTokenProvider()
        await tokenProvider.setAccessToken(authData.jwt)
        
        let posts = try await API().fetch(PostsRequest())
        self.posts = posts
        
      } catch let error as NSError {
        self.error = error
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
