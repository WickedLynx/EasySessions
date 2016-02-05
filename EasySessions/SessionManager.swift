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
    private var parser: ResponseParsing.Type = DefaultParser.self
    private var ongoingOperations = 0
    private lazy var processingQueue: dispatch_queue_t = dispatch_queue_create("com.lbs.easysessions.processingqueue", DISPATCH_QUEUE_CONCURRENT)

    private lazy var downloadSessionComponents: SessionComponents = { [unowned self] in
        let queue = NSOperationQueue()

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.allowsCellularAccess = true

        let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: queue)

        return(session, queue)

        } ()


    // MARK: Public functions

    public init(parser: ResponseParsing.Type?) {
        if let cParser = parser {
            self.parser = cParser
        }
    }

    public func ephemeralDataDownloadTaskWithRequest(request: NSURLRequest, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionTask {
        return ephemeralDataTaskWithRequest(request, completion: completion)
    }

    public func ephemeralJSONDownloadTaskWithRequest(request: NSURLRequest, completion: ((AnyObject?, NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionTask {
        return ephemeralJSONTaskWithRequest(request, completion: completion)
    }


    // MARK: Private functions

    private func ephemeralJSONTaskWithRequest(request: NSURLRequest, completion: ((AnyObject?, NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionTask {
        return ephemeralDataTaskWithRequest(request, completion: {[weak self] (data, response, error) -> Void in
            if let cCompletion = completion {
                var receivedObject: AnyObject?
                var jsonError: NSError?
                if let cData = data {
                    if let queue = self?.processingQueue {
                        dispatch_async(queue, { () -> Void in
                            do {
                                receivedObject = try NSJSONSerialization.JSONObjectWithData(cData, options: [])
                            } catch let error as NSError {
                                jsonError = error
                                receivedObject = nil
                            } catch {
                                print("EasySessions: Unknown error")
                            }
                            let result = self?.parser.parseReceivedJSON(receivedObject, data: data, response: response, error: jsonError, forRequest: request)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                cCompletion(result?.0, result?.1, result?.2, result?.3)
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

    private func ephemeralDataTaskWithRequest(request: NSURLRequest, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionTask {
        let session = downloadSessionComponents.0
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

                print("\n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\nRequest URL: \(request.URL!)\n-----------------------\nHeaders:\n\(request.allHTTPHeaderFields)\n-----------------------\nBody:\n\(bodyAsString)\n-----------------------\nResponse:\nStatus code: \(statusCode)\nHeaders:\(responseHeaders)\n-----------------------\nReceived data:\n\(returnedData)\n-----------------------\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n")
            }
            self?.updateAfterIncrementingNetworkIndicator(shouldIncrement: false)
            let result = self?.parser.parseReceivedData(data, response: response, error: error, forRequest: request)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion?(result?.0, result?.1, result?.2)
            })
        })
        task.resume()
        return task
    }


    private func updateAfterIncrementingNetworkIndicator(shouldIncrement shouldIncrement: Bool) {
        dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
            self?.ongoingOperations += shouldIncrement ? 1 : -1
            self?.ongoingOperations = max(self?.ongoingOperations ?? 0, 0)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = (self?.ongoingOperations ?? 0) > 0
        })
    }
}
