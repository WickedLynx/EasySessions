//
//  SessionManager.swift
//  EasySessions
//
//  Created by Harshad on 20/08/15.
//  Copyright (c) 2015 Laughing Buddha Software. All rights reserved.
//

import Foundation
import UIKit

typealias SessionComponents = (NSURLSession, NSOperationQueue)

public class SessionManager {

    // MARK: Public properties
    /// Set true to enable logging
    public var loggingEnabled = false

    // MARK: Private properties

    private var ongoingOperations = 0
    private lazy var processingQueue = dispatch_queue_create("com.lbs.easysessions.processingqueue", DISPATCH_QUEUE_CONCURRENT)

    private lazy var downloadSessionComponents: SessionComponents = { [unowned self] in
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 5

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.allowsCellularAccess = true

        let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: queue)

        return(session, queue)

        } ()
    
    private lazy var uploadSessionComponents: SessionComponents = { [unowned self] in
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 5

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.allowsCellularAccess = true

        let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: queue)

        return(session, queue)
        
        } ()

    // MARK: Public functions

    public init() {

    }

    public func ephemeralDataDownloadTaskWithRequest(request: NSURLRequest, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionTask {
        return ephemeralDataTaskWithRequest(request, isUpload: false, completion: completion)
    }

    public func ephemeralDataUploadTaskWithRequest(request: NSURLRequest, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionTask {
        return ephemeralDataTaskWithRequest(request, isUpload: true, completion: completion)
    }

    public func ephemeralJSONDownloadTaskWithRequest(request: NSURLRequest, completion: ((AnyObject?, NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionTask {
        return ephemeralJSONTaskWithRequest(request, isUpload: false, completion: completion)
    }

    public func ephemeralJSONUploadTaskWithRequest(request: NSURLRequest, completion: ((AnyObject?, NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionTask {
        return ephemeralJSONTaskWithRequest(request, isUpload: true, completion: completion)
    }


    // MARK: Private functions

    private func ephemeralJSONTaskWithRequest(request: NSURLRequest, isUpload: Bool, completion: ((AnyObject?, NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionTask {
        return ephemeralDataTaskWithRequest(request, isUpload: isUpload, completion: {[weak self] (data, response, error) -> Void in
            if let cCompletion = completion {
                var receivedObject: AnyObject?
                var jsonError: NSError?
                if let cData = data {
                    if let queue = self?.processingQueue {
                        dispatch_async(queue, { () -> Void in
                            receivedObject = NSJSONSerialization.JSONObjectWithData(cData, options: .allZeros, error: &jsonError)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                cCompletion(receivedObject, data, response, jsonError)
                            })
                        })
                    } else {
                        cCompletion(nil, data, response, error)
                    }
                } else {
                    cCompletion(nil, data, response, error)
                }
            }
            })
    }

    private func ephemeralDataTaskWithRequest(request: NSURLRequest, isUpload: Bool, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionTask {
        let session = isUpload ? uploadSessionComponents.0 : downloadSessionComponents.0
        updateAfterIncrementingNetworkIndicator(shouldIncrement: true)
        let task = session.dataTaskWithRequest(request, completionHandler: {[weak self] (data, response, error) -> Void in
            if self?.loggingEnabled ?? false {
                var bodyAsString = "Body not set" as NSString
                if let body = request.HTTPBody {
                    bodyAsString = NSString(data: body, encoding: NSUTF8StringEncoding) ?? "Unable to decode body"
                }

                var returnedData = "No data returned" as NSString
                if let cData = data {
                    returnedData = NSString(data: cData, encoding: NSUTF8StringEncoding) ?? "Unable to decode returned data"
                }

                var statusCode = "Unable to get status code"
                var responseHeaders = "Unable to get response headers"
                if let cResponse = response as? NSHTTPURLResponse {
                    statusCode = "\(cResponse.statusCode)"
                    responseHeaders = "\(cResponse.allHeaderFields)"
                }

                println("\n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\nRequest URL: \(request.URL!)\n-----------------------\nHeaders:\n\(request.allHTTPHeaderFields)\n-----------------------\nBody:\n\(bodyAsString)\n-----------------------\nResponse:\nStatus code: \(statusCode)\nHeaders:\(responseHeaders)\n-----------------------\nReceived data:\n\(returnedData)\n-----------------------\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n")
            }
            self?.updateAfterIncrementingNetworkIndicator(shouldIncrement: false)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion?(data, response, error)
            })
        })
        task.resume()
        return task
    }


    private func updateAfterIncrementingNetworkIndicator(#shouldIncrement: Bool) {
        dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
            self?.ongoingOperations += shouldIncrement ? 1 : -1
            self?.ongoingOperations = max(self?.ongoingOperations ?? 0, 0)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = (self?.ongoingOperations ?? 0) > 0
        })
    }
}
