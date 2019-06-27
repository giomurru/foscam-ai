//
//  MJPEGStreamLib.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 25/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

#if os(OSX)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

protocol MJPEGLibDelegate : AnyObject {
    func session(_ session: URLSession, didUpdate imageData: Data)
    func didStartPlaying()
}

open class MJPEGLib: NSObject , URLSessionDataDelegate {
    
    weak var delegate: MJPEGLibDelegate?
    
    fileprivate enum StreamStatus {
        case stop
        case loading
        case play
    }
    
    fileprivate var receivedData: NSMutableData?
    fileprivate var dataTask: URLSessionDataTask?
    fileprivate var session: Foundation.URLSession!
    fileprivate var status: StreamStatus = .stop
    
    open var authenticationHandler: ((URLAuthenticationChallenge) -> (Foundation.URLSession.AuthChallengeDisposition, URLCredential?))?
    open var contentURL: URL?
    
    override init() {
        super.init()
        self.session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    public convenience init(contentURL: URL) {
        self.init()
        self.contentURL = contentURL
    }
    
    deinit {
        dataTask?.cancel()
    }
    
    // Play function with url parameter
    open func play(url: URL){
        // Checking the status for it is already playing or not
        if status == .play || status == .loading {
            stop()
        }
        contentURL = url
        play()
    }
    
    // Play function without URL paremeter
    open func play() {
        guard let url = contentURL , status == .stop else {
            return
        }
        
        status = .loading
        receivedData = NSMutableData()
        let request = URLRequest(url: url)
        dataTask = session.dataTask(with: request)
        dataTask?.resume()
    }
    
    open func sendCommand(_ command: String, completionHandler: ((String?, URLResponse?, Error?) -> Void)? = nil) {
        if let url = URL(string: command) {
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error { //transport error has occurred
                    completionHandler?(nil, response, error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        completionHandler?(nil, response, error)
                        return
                }
                if let mimeType = httpResponse.mimeType, mimeType == "text/plain",
                    let responseData = data,
                    let responseValue = String(data: responseData, encoding: .utf8) {
                    completionHandler?(responseValue, response, error)
                }
                else {
                    completionHandler?(nil, response, error)
                }
            }
            task.resume()
        }
    }
    
    // Stop the stream function
    open func stop(){
        status = .stop
        dataTask?.cancel()
    }
    
    // NSURLSessionDataDelegate
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // Controlling the imageData is not nil
        if let imageData = receivedData , imageData.length > 0 {
            if status == .loading {
                status = .play
                DispatchQueue.main.async {
                    self.delegate?.didStartPlaying()
                }
            }
            delegate?.session(session, didUpdate: imageData as Data)
        }
        receivedData = NSMutableData()
        completionHandler(.allow)
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData?.append(data)
    }
    
    // NSURLSessionTaskDelegate
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        var credential: URLCredential?
        var disposition: Foundation.URLSession.AuthChallengeDisposition = .performDefaultHandling
        // Getting the authentication if stream asks it
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let trust = challenge.protectionSpace.serverTrust {
                credential = URLCredential(trust: trust)
                disposition = .useCredential
            }
        } else if let onAuthentication = authenticationHandler {
            (disposition, credential) = onAuthentication(challenge)
        }
        
        completionHandler(disposition, credential)
    }
}
