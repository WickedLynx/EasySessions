# EasySessions
A Swift wrapper around NSURLSession to quickly add a basic networking layer to apps

## Goals
- Adhere to KISS
- Create URLs and URL requests in a composite and type-safe manner
- Support for sending the most widely used JSON/plaint-text requests
- Additional layer for further parsing responses (for flexibility)
- No string manipulation for queries, url paths, etc.
- No singletons/globals/statics
- No runtime hackery

## Usage Example
All requests are sent via the `SessionManager`. You would typically require a single instance of the session manager throughout the application. The session manager internally uses a single `NSURLSession` to process network requests.

The framework provides extensions on `NSURL` and `NSURLRequest` to build URLs and requests.

Here's how you would use these components:

		import EasySessions;
		class UserService {
			let sessionManager = EasySessions.SessionManager(parser: nil)
			let baseURL = NSURL(string: "https://mydomain.com")!
			let accessToken = "avdi809_ijofidijiJojfUl13"
			
			func fetchUsers() {
				let path = "/users"
				let queryParameters = ["token" : accessToken, "limit" : 50] as EasySessions.QueryItemContainer
				
				guard let url = NSURL.URLWithPath(path: path, queryItems: queryParameters, relativeToURL: baseURL) else {
					return
				}
				
				let request = NSMutableURLRequest.jsonGETRequest(URL: url)
				
				sessionManager.ephemeralJSONDownloadTaskWithRequest(request) { (users, data, response, error) in
					// Do further processing
				}
			}
		}


## Planned Features
1.	Allow configuring the `NSURLSession` externally
2.	Allow different response parsers for different domains
3.	Implement all HTTP verbs as per the REST spec
4.	Improve test coverage

