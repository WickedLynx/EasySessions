//
//  ResponseParser.swift
//  EasySessions
//
//  Created by Harshad on 13/11/15.
//  Copyright © 2015 Laughing Buddha Software. All rights reserved.
//

import Foundation

public protocol ResponseParsing: class {
    static func parseReceivedData(data: NSData?, response: NSURLResponse?, error: NSError?, forRequest request: NSURLRequest) -> (NSData?, NSURLResponse?, NSError?)
    static func parseReceivedJSON(json: AnyObject?, data: NSData?, response: NSURLResponse?, error: NSError?, forRequest request: NSURLRequest) -> (AnyObject?, NSData?, NSURLResponse?, NSError?)
}

internal class DefaultParser: ResponseParsing {
    static func parseReceivedData(data: NSData?, response: NSURLResponse?, error: NSError?, forRequest request: NSURLRequest) -> (NSData?, NSURLResponse?, NSError?) {
        return (data, response, error)
    }

    static func parseReceivedJSON(json: AnyObject?, data: NSData?, response: NSURLResponse?, error: NSError?, forRequest request: NSURLRequest) -> (AnyObject?, NSData?, NSURLResponse?, NSError?) {
        return (json, data, response, error)
    }
}
