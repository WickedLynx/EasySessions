//
//  RequestBuilder.swift
//  Shuttl
//
//  Created by Harshad on 24/08/15.
//  Copyright (c) 2015 Leftshift Technologies. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////////
// Source: http://stackoverflow.com/a/16582586
extension NSCharacterSet {

    /// Returns the character set for characters allowed in the individual parameters within a query URL component.
    ///
    /// The query component of a URL is the component immediately following a question mark (?).
    /// For example, in the URL `http://www.example.com/index.php?key1=value1#jumpLink`, the query
    /// component is `key1=value1`. The individual parameters of that query would be the key `key1`
    /// and its associated value `value1`.
    ///
    /// According to RFC 3986, the set of unreserved characters includes
    ///
    /// `ALPHA / DIGIT / "-" / "." / "_" / "~"`
    ///
    /// In section 3.4 of the RFC, it further recommends adding `/` and `?` to the list of unescaped characters
    /// for the sake of compatibility with some erroneous implementations, so this routine also allows those
    /// to pass unescaped.


    static func URLQueryParameterAllowedCharacterSet() -> Self {
        return self.init(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~/?")
    }
    
}
///////////////////////////////////////////////////////////////////////////////////

public extension String {
    ///////////////////////////////////////////////////////////////////////////////////
    // Source: http://stackoverflow.com/a/16582586
    public func urlEncodedString() -> String? {
        let allowedCharacters = NSCharacterSet.URLQueryParameterAllowedCharacterSet()
        return stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }
    ///////////////////////////////////////////////////////////////////////////////////

    public static func URLQuery<T: Stringify>(parameters parameters: [T : T]) -> String {
        var query = ""
        var index = 0
        for (key, value) in parameters {
            query += index == 0 ? "" : "&"
            query += (key.toString() + "=" + (value.toString().urlEncodedString() ?? ""))
            ++index
        }
        return query
    }
}

public extension NSURL {

    public class func URLWithPath(path path: String, query: String?, relativeToURL baseURL: NSURL) -> NSURL? {
        let components = NSURLComponents()
        components.path = path
        components.query = query
        return components.URLRelativeToURL(baseURL)
    }

    public class func URLWithPath<T: Stringify>(path path: String, parameters: [T : T]?, baseURL: NSURL) -> NSURL? {
        var query = ""
        if let cParameters = parameters {
            query = "?" + String.URLQuery(parameters: cParameters)
        }
        return URLWithPath(path: path, query: query, relativeToURL: baseURL)
    }
}

public extension NSMutableURLRequest {
    public class func jsonPOSTRequest(URL URL: NSURL, body: NSData?) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "POST"
        request.HTTPBody = body
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        return request
    }

    public class func jsonPOSTRequest(URL URL: NSURL, jsonObject: AnyObject) throws -> NSMutableURLRequest {
        let data = try? NSJSONSerialization.dataWithJSONObject(jsonObject, options: .PrettyPrinted)
        return jsonPOSTRequest(URL: URL, body: data)
    }
    
    public class func jsonPOSTRequest<T: Stringify>(URL URL: NSURL, parameters: [T : T]) -> NSMutableURLRequest {
        let query = String.URLQuery(parameters: parameters)
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
