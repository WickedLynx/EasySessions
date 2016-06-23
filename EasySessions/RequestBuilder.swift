//
//  RequestBuilder.swift
//  Shuttl
//
//  Created by Harshad on 24/08/15.
//  Copyright (c) 2015 Leftshift Technologies. All rights reserved.
//

import Foundation

// Thanks, Mike Ash!

/// Used to express NSURLQueryItem objects in a dictionary literal like constructor
public struct QueryItemContainer: DictionaryLiteralConvertible {
    var items: [NSURLQueryItem]

    public init(dictionaryLiteral elements: (StringRepresentable, StringRepresentable)...) {
        items = elements.map({return NSURLQueryItem(name: $0.toString(), value: $1.toString())})
    }
}


public extension NSURLComponents {
    public func appendQueryItems(items: QueryItemContainer) -> NSURLComponents {
        if queryItems == nil {
            queryItems = items.items
        } else {
            queryItems?.appendContentsOf(items.items)
        }
        return self
    }

    public static func constructQueryStringWithItems(items: QueryItemContainer) -> String {
        let components = NSURLComponents()
        components.queryItems = items.items
        return components.percentEncodedQuery ?? ""
    }
}

public extension NSURL {

    public class func URLWithPath(path path: String, query: String?, relativeToURL baseURL: NSURL) -> NSURL? {
        let components = NSURLComponents()
        components.path = path
        components.query = query
        return components.URLRelativeToURL(baseURL)
    }

    public class func URLWithPath(path path: String, queryItems: QueryItemContainer, relativeToURL baseURL: NSURL) -> NSURL? {
        let components = NSURLComponents()
        components.path = path
        components.appendQueryItems(queryItems)
        return components.URLRelativeToURL(baseURL)
    }
}


public extension NSMutableURLRequest {
    public class func jsonPOSTRequest(URL URL: NSURL, body: NSData?) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "POST"
        request.HTTPBody = body
        request.setValue("application/json", forHTTPHeaderField: "accept")
        return request
    }

    public class func jsonPOSTRequest(URL URL: NSURL, jsonObject: AnyObject) throws -> NSMutableURLRequest {
        let data = try? NSJSONSerialization.dataWithJSONObject(jsonObject, options: .PrettyPrinted)
        let request = jsonPOSTRequest(URL: URL, body: data)
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        return request
    }
    
    public class func jsonPOSTRequest(URL URL: NSURL, parameters: QueryItemContainer) -> NSMutableURLRequest {
        let query = NSURLComponents.constructQueryStringWithItems(parameters)
        let request = jsonPOSTRequest(URL: URL, body: query.dataUsingEncoding(NSUTF8StringEncoding))
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        return request
    }

    public class func jsonGETRequest(URL URL: NSURL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        return request
    }

}
