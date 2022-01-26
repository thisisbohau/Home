//
//  RequestManager.swift
//  Home
//
//  Created by David Bohaumilitzky on 27.12.21.
//

import Foundation
import UIKit

enum InvalidURL: Error {
    case invalidURL
    case notFound
    case unexpected(code: Int)
}

class RequestManager{
    private let accessKey: String = AccessKit().getAccessKey()
    private let deviceToken: String = AccessKit().getDeviceToken()
    private let serverAddress: String = AccessKit().getServerAddress()
    
//    private let accessKey: String = "AccessKit().getAccessKey()"
//    private let deviceToken: String = "AccessKit().getDeviceToken()"
//    private let serverAddress: String = "AccessKit().getServerAddress()"
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }

    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
    }
    
    /// Performs a data task either as a `URLSession` or `BackgroundSession`.
    /// - Important: Never call this method directly. Use the `make---Request` methods instead.
    func makeRequest(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        if await UIApplication.shared.applicationState == .active{
            //perform normal data task
            request.httpBody = String("user=\(deviceToken)&password=\(accessKey)").data(using: .utf8)
            request.httpMethod = "POST"
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: request){data1, response, error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        guard let data1 = data1 else {
                            fatalError("Expected non-nil result 'data1' in the non-error case")
                        }
                        continuation.resume(returning: data1)
                    }
                }
                task.resume()
            }
        }else{
            print("Performing background update")
            beginBackgroundUpdateTask()
            request.httpBody = String("user=\(deviceToken)&password=\(accessKey)").data(using: .utf8)
            request.httpMethod = "POST"
                let task = URLSession.shared.dataTask(with: request){data1, response, error in
                    print("background task finished")
                }
                task.resume()
            endBackgroundUpdateTask()
        }
        return Data()
    }
    
    
    /// Performs a status request with expected Return Values
    /// - Returns: If successful, a JSON response
    func makeStatusRequest() async throws -> String {
        var components = URLComponents()
        components.scheme = "http"
        components.path = "/hook/home/status"
        components.port = 80
        components.host = serverAddress
        
        guard let url = components.url else{
            print("Request URL couldn't be constructed")
            throw InvalidURL.invalidURL
        }
        
        let response = try await makeRequest(url: url)
        let String = String(data: response , encoding: .utf8) ?? ""
        return String
    }
    
    /// Performs a request with the given query items
    /// - Parameter queries: Additional information to for the sever to process
    /// - Returns: If available, a JSON response
    func makeActionRequest(requestDirectory: ActionDirectories, queries: [URLQueryItem]) async throws -> String {
        var components = URLComponents()
        components.scheme = "http"
        components.path = "/hook/home/"
        components.port = 80
        components.host = AccessKit().getServerAddress()
        components.queryItems = queries
        components.path.append(requestDirectory.rawValue)
        
        guard let url = components.url else{
            print("Request URL couldn't be constructed")
            throw InvalidURL.invalidURL
        }
        
        let response = try await makeRequest(url: url)
        let String = String(data: response , encoding: .utf8) ?? ""
        return String
    }
    
    /// Performs an access request. This request may not require a user to be logged in
    /// - Parameter queries: Additional information to for the sever to process
    /// - Returns: If available, a JSON response
    func makeAccessRequest(queries: [URLQueryItem]) async throws -> String {
        var components = URLComponents()
        components.scheme = "http"
        components.path = "/hook/home/idaccess"
        components.port = 80
        components.host = serverAddress
        components.queryItems = queries
        print("Making Access Request ")
        guard let url = components.url else{
            print("Request URL couldn't be constructed")
            throw InvalidURL.invalidURL
        }
        
        let response = try await makeRequest(url: url)
        let String = String(data: response , encoding: .utf8) ?? ""
        return String
    }
    
}

class BackgroundSession: NSObject {
    static let shared = BackgroundSession()
    static let identifier = "com.domain.app.bg"
    private var session: URLSession!
    #if !os(macOS)
    var savedCompletionHandler: (() -> Void)?
    #endif
    
    private override init() {
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: BackgroundSession.identifier)
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func start(_ request: URLRequest) {
        session.downloadTask(with: request).resume()
    }
}

extension BackgroundSession: URLSessionDelegate {
    #if !os(macOS)
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.savedCompletionHandler?()
            self.savedCompletionHandler = nil
        }
    }
    #endif
}

extension BackgroundSession: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            // handle failure here
            print("\(error.localizedDescription)")
        }
    }
}

extension BackgroundSession: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Background data task finished.")
    }
}
