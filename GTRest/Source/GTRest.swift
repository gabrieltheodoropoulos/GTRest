//
//  GTRest.swift
//  GTRest
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Gabriel Theodoropoulos. All rights reserved.
//

import Foundation

/**
 A lightweight class to perform web requests.
 
 See [documentation](https://gtiapps.com/docs/gtrest/index.html).
 
 */
open class GTRest: NSObject, GTAssistiveTools {
    
    // MARK: - Properties
    
    /// It manages request HTTP headers.
    public var requestHttpHeaders = RestEntity(withEntityType: .requestHTTPHeader)
    
    /// It manages URL query parameters.
    public var urlQueryParameters = RestEntity(withEntityType: .URLQueryParameter)
    
    /// It manages HTTP body parameters. Use it when content type
    /// is either "application/json" or "application/x-www-form-urlencoded".
    /// There is no need to provide a value for the `httpBody` property.
    public var httpBodyParameters = RestEntity(withEntityType: .HttpBodyParameter)
    
    /// The HTTP body data that should be sent along with a request.
    /// Use this property if content type is other than "application/json"
    /// and "application/x-www-form-urlencoded".
    public var httpBody: Data?
    
    
    
    // MARK: - Init
    
    /**
     `GTRest` default initializer.
    */
    public override init() {
        super.init()
    }
    
    
    // MARK: - Public Methods
    
    /**
     It initiates a web request to the given URL using the specified HTTP method.
     
     Any data that should be sent along with the request should be provided prior
     to calling this method. Use the following properties:
     
     * `requestHttpHeaders`: To provide request HTTP headers.
     * `urlQueryParameters`: To provide URL query parameters.
     * `httpBodyParameters`: To provide HTTP body parameters if the content type is
     either "application/json" or "application/x-www-form-urlencoded".
     * `httpBody`: To provide the HTTP body data if the content type is other than
     "application/json" or "application/x-www-form-urlencoded".
     
     The web request takes place asynchronously. On completion, the method returns
     a `Results` object which contains the data and response coming from server,
     or any potential error.
     
     Usage example:
     
     ```
     let url = URL(...) // A URL object.
     let rest = GTRest()
     rest.makeRequest(toURL: url, httpMethod: .get) { [unowned self] (results) in // or [weak self] (results) in
         // Access data:
         if let data = results.data {
            // Perform app-specific actions
         }
     
         // Access the response:
         if let response = data.response {
            // Do something with the response object if necessary.
            // Remember that it's a GTRest.Response object.
            // Checking the HTTP status code :
            if (200...299).contains(response.httpStatusCode) {
                // Successful request.
            } else { ... }
         }
     
         // Access the error:
         if let error = results.error {
            // Do something with the error.
         }
     
         // Update your UI on main thread always:
         DispatchQueue.main.async {
            // Update UI.
         }
     }
     ```
     
     - Parameter url: The URL to make the request to.
     - Parameter httpMethod: The request HTTP method (get, post, etc).
     - Parameter completion: The completion handler called when server has responded
     with data. It is also called if the request object (URLRequest) cannot be created
     for some reason.
     - Parameter result: The `GTRest.Results` object containing the results of the web request.
    */
    public func makeRequest(toURL url: URL,
                            withHttpMethod httpMethod: HttpMethod,
                            completion: @escaping (_ result: Results) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let targetURL = self?.addURLQueryParameters(toURL: url)
            let httpBody = self?.getHttpBody()
            guard let request = self?.prepareRequest(withURL: targetURL, httpBody: httpBody, httpMethod: httpMethod) else { completion(Results(withError: CustomError.failedToCreateRequest)); return }
            
            let sessionConfiguration = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: sessionConfiguration)
            let task = session.dataTask(with: request) { (data, response, error) in
                completion(Results(withData: data,
                                  response: Response(fromURLResponse: response),
                                  error: error))
            }
            task.resume()
        }
    }

    
    
    /**
     It uploads the given files to the given URL, including additional data as URL query parameters
     or HTTP body parameters.
     
     A file is described by a `GTRest.FileInfo` object, and the collection of files to upload is a
     collection of `GTRest.FileInfo` objects.
     
     On completion, a `GTRest.Results` object is returned which includes the results of the request.
     In addition, an optional array of String values is also included in the completion which, if not nil,
     contains the names of files that could not be uploaded for some reason.
     
     - Important:
     `multipart/form-data; boundary=xxx` is the content type used for web requests made through this method.
     **Do not specify a content type** in request HTTP headers, it is automatically set.
     
     Usage example:
     
     ```
     var rest = GTRest()
     
     // Prepare the files that will be uploaded.
     var resume = GTRest.FileInfo()
     resume.fileContents = ... // File contents data
     resume.mimetype = "application/pdf" // or GTRest.MimeType.applicationPDF.rawValue
     resume.filename = "resume.pdf"
     
     var avatar = GTRest.FileInfo()
     avatar.fileContents = ... // File contents data
     avatar.mimetype = GTRest.MimeType.imagePNG.rawValue
     avatar.filename = "avatar.png"
     
     // Optionally, set any request HTTP methods, but not the "content-type".
     // Also, set any required URL query or HTTP body parameters.
     
     // Prepare the URL.
     let url = ... // A URL object.
     
     rest.upload(files: [resume, avatar], toURL: url, withHttpMethod: .post) { [unowned self] (results, failedFiles) in // or [unowned self] (results, failedFiles) in
        if let failedFiles = failedFiles {
            // Do something with the files that failed to be uploaded.
        }
     
        // Do something with the results.
        if let data = results.data {
            // ...
        }
     
        // Update your UI on main thread always:
        DispatchQueue.main.async {
            // Update UI.
        }
     }
     ```
     
     - Parameter files: A collection of `GTRest.FileInfo` objects with data regarding the files to upload.
     - Parameter url: The URL to make the request to.
     - Parameter httpMethod: The request HTTP method (get, post, etc).
     - Parameter completion: The completion handler called when server has responded
     with data. It is also called if the request object (URLRequest) cannot be created
     for some reason, or the boundary cannot be generated.
     - Parameter result: The `GTRest.Result` object containing the results of the web request
     - Parameter failedFiles: An optional array of String values containing the names of files failed
     to be uploaded.
    */
    public func upload(files: [FileInfo], toURL url: URL, withHttpMethod httpMethod: HttpMethod, completion: @escaping(_ result: Results, _ failedFiles: [String]?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let targetURL = self?.addURLQueryParameters(toURL: url)
            guard let boundary = self?.createBoundary() else { completion(Results(withError: CustomError.failedToCreateBoundary), nil); return }
            self?.requestHttpHeaders.add(value: "multipart/form-data; boundary=\(boundary)", forKey: GTRest.HttpHeader.contentType.rawValue)
            guard var body = self?.getHttpBody(withBoundary: boundary) else { completion(Results(withError: CustomError.failedToCreateHttpBody), nil); return }
            let failedFilenames = self?.add(files: files, toBody: &body, withBoundary: boundary)
            self?.close(body: &body, usingBoundary: boundary)
            guard let request = self?.prepareRequest(withURL: targetURL, httpBody: body, httpMethod: httpMethod) else { completion(Results(withError: CustomError.failedToCreateRequest), nil); return }
            
            let sessionConfiguration = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: sessionConfiguration)
            let task = session.uploadTask(with: request, from: nil, completionHandler: { (data, response, error) in
                completion(Results(withData: data,
                                  response: Response(fromURLResponse: response),
                                  error: error),
                           failedFilenames)
            })
            task.resume()
        }
    }
    
    
    
    /**
     It fetches data from the given URL.
     
     This method is useful for fetching single data from a URL, usually the contents of a
     file. For example, the image data for a user profile picture, or the contents of
     a PDF file.
     
     - Note:
     Data fetching takes place asynchronously.
     
     Usage example:
     
     ```
     let rest = GTRest()
     rest.getData(fromURL: url)  { [unowned self] (data) in // or [weak self] (data) in
        if let data = data {
            // Do something with the fetched data.
        }
     }
     ```
     
     - Parameter url: The URL to fetch data from.
     - Parameter completion: The completion handler that gets called after having fetched
     the data. It returns a `Data` object.
     - Parameter data: The `Data` object with the fetched data from the given URL. It can
     be `nil`.
    */
    public func getData(fromURL url: URL, completion: @escaping (_ data: Data?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let sessionConfiguration = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: sessionConfiguration)
            let task = session.dataTask(with: url) { (data, response, error) in
                guard let data = data else { completion(nil); return }
                completion(data)
            }
            task.resume()
        }
    }
    
}




// MARK: - Private Methods

extension GTRest {
    
    /**
     It appends any URL query parameters existing in the `urlQueryParameters` property to the given URL.
     
     - Warning: In case there are no URL query parameters provided, or for some reason the new URL
     cannot be generated, the original URL is returned back to the caller.
     
     - Parameter url: The source URL that the query parameters will be appended to.
     - Returns: The updated URL containing the query parameters, or the source URL if appending parameters
     to it fails.
    */
    private func addURLQueryParameters(toURL url: URL) -> URL {
        if urlQueryParameters.totalItems() > 0 {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
            var queryItems = [URLQueryItem]()
            for (key, value) in urlQueryParameters.getStorageValues() {
                queryItems.append(URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)))
            }

            urlComponents.queryItems = queryItems

            guard let updatedURL = urlComponents.url else { return url }
            return updatedURL
        }
        
        return url
    }
    
    
    /**
     It creates the HTTP body data based on the specified content type in request HTTP headers.
     
     If no content type has been specified, then the method returns `nil` as it is assumed that
     no data will be sent as the request's body.
     
     In case content type has been provided as a request HTTP header then the method checks its value.
     
     * If it's "application/json then it creates a JSON object from the HTTP body
     parameters and it returns it.
     * If it's "x-www-form-urlencoded" then a query string is built based on the values of the
     `httpBodyParameters` property. This string is converted to a data object and returned.
     
     - Warning: Do not use this method when uploading files. Use `getHttpBody(withBoundary:)` instead.
     
     - Returns: The HTTP post data as a `Data` object, or `nil` if no content type was specified, data
     object could not be generated or `httpBody` is nil (in case of a content type value other than those
     two mentioned above).
    */
    private func getHttpBody() -> Data? {
        guard let contentType = requestHttpHeaders.value(forKey: "Content-Type") else { return nil }
        
        if contentType.contains("application/json") {
            return try? JSONSerialization.data(withJSONObject: httpBodyParameters.getStorageValues(), options: [.prettyPrinted, .sortedKeys])
        } else if contentType.contains("application/x-www-form-urlencoded") {
            let defString = "xx--GTRest--xx"
            
            let bodyString = httpBodyParameters.getStorageValues().map { "\($0)=\($1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? defString)" }.filter { !$0.contains(defString) }.joined(separator: "&")
            return bodyString.data(using: .utf8)
        } else {
            return httpBody
        }
    }
    
    
    
    /**
     It initializes and configures a `URLRequest` object.
     
     The request object is configured using the given URL, HTTP body and HTTP method values. If the
     URL is `nil`, then `nil` is also returned by the method.
     
     - Parameter url: The URL that the request will be made to.
     - Parameter httpBody: The HTTP body data. It can be `nil`.
     - Parameter httpMethod: The HTTP method to use or the request. See `HTTPMethods` enum.
     - Returns: An `URLRequest` object, or `nil` if the given URL value is `nil` too.
    */
    private func prepareRequest(withURL url: URL?, httpBody: Data?, httpMethod: HttpMethod) -> URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        for (header, value) in requestHttpHeaders.getStorageValues() {
            request.setValue(value, forHTTPHeaderField: header)
        }
        request.httpBody = httpBody
        return request
    }
    
    
    
    
    // MARK: - Upload Related Methods
    
    /**
     It generates the *boundary* string necessary when uploading files.
     
     - Returns: The boundary String value.
    */
    private func createBoundary() -> String {
        return "------------------------------------------------------boundary\(generateRandomString(withNumberOfChars: 10))\(Int(Date.timeIntervalSinceReferenceDate))"
    }
    
    
    
    /**
     It creates the HTTP body data using parameters set through the `httpBodyParameters` property and the given boundary.
     
     - Parameter boundary: The boundary string value.
     - Returns: A `Data` object. If no HTTP body parameters exist, it returns an initialized `Data` object.
    */
    private func getHttpBody(withBoundary boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in httpBodyParameters.getStorageValues() {
            let values = ["--\(boundary)\r\n", "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n", "\(value)\r\n"]
            _ = append(values: values, toData: &body, valuesType: String.self)
        }
        
        return body
    }

    
    
    /**
     It adds the given files to HTTP body data.
     
     - Parameter files: A collection of `GTRest.FileInfo` objects containing upload files data.
     - Parameter body: The HTTP body data. It's marked as an `inout` parameter so any changes made to
     it are reflected to the caller of the method.
     - Parameter boundary: The boundary string value.
     
     - Returns: An optional array of String values containing names of files that could not be appended to
     the data that will be uploaded.
    */
    private func add(files: [FileInfo], toBody body: inout Data, withBoundary boundary: String) -> [String]? {
        var status = true
        var failedFilenames: [String]?
        
        // Go through each FileInfo object in a loop.
        for file in files {
            // Make sure that the file name, content and mime type exist.
            guard let filename = file.filename, let content = file.fileContents, let mimetype = file.mimetype else { continue }
            
            // Set status to false. If appending all following values to a Data object successfully
            // it'll become true again.
            status = false
            
            // Create an array with properly formatted strings which include
            // the boundary, file name and mime type.
            let toData = ["--\(boundary)\r\n",
                "Content-Disposition: form-data; name=\"\(filename)\"; filename=\"\(filename)\"\r\n",
                "Content-Type: \(mimetype)\r\n\r\n"]
            
            // Initialize a new Data object.
            // If appending all following values to this object, then this
            // object will be appended to the body Data object in turn.
            var data = Data()
            
            // Start appending to the data object.
            if append(values: toData, toData: &data, valuesType: String.self) { // Append the strings array to data object.
                if append(values: [content], toData: &data, valuesType: Data.self) {    // Append the actual file contents to data object.
                    if append(values: ["\r\n"], toData: &data, valuesType: String.self) {  // Append the new line string to data object.
                        // All values were successfully appended to the data object.
                        // Make the status flag true.
                        status = true
                    }
                }
            }
            
            
            // If the status is true, then append the data object initialized above
            // to the body data. Else, keep the file name of the file that was failed
            // to be appended to the data in the failedFilenames array.
            if status {
                body.append(data)
            } else {
                if failedFilenames == nil {
                    failedFilenames = [String]()
                }
                
                failedFilenames?.append(filename)
            }
            
        }
        
        // Return the array with the files that failed to be appended
        // to the body data. If all files were appended successfully,
        // then this is nil.
        return failedFilenames
    }
 
    
    
    /**
     It closes the HTTP post body.
     
     - Parameter body: The HTTP body data. Marked as `inout` parameter to reflect changes to the caller.
     - Parameter boundary: The boundary string value.
    */
    private func close(body: inout Data, usingBoundary boundary: String) {
        _ = append(values: ["\r\n--\(boundary)--\r\n"], toData: &body, valuesType: String.self)
    }
}




// MARK: - GTRest Custom Types Definition

extension GTRest {
    
    /**
     The available HTTP methods.
    */
    public enum HttpMethod: String {
        /// HEAD HTTP method.
        case head
        /// GET HTTP method.
        case get
        /// POST HTTP method.
        case post
        /// PUT HTTP method.
        case put
        /// PATCH HTTP method.
        case patch
        /// DELETE HTTP method.
        case delete
    }
    
    
    
    /**
     It represents a REST entity.
     
     A REST entity can be any of the following:
     * Request HTTP headers
     * Response HTTP headers
     * URL query parameters
     * HTTP body parameters
    */
    public struct RestEntity: GTKeyValueCompliant, CustomStringConvertible {
        /**
         The type of the REST entity.
        */
        enum RestEntityType {
            case requestHTTPHeader
            case responseHTTPHeader
            case URLQueryParameter
            case HttpBodyParameter
        }
        
        public var storage = GTKeyValueCompliantStorage<String>()
        
        /// The entity type describing the current object.
        var entityType: RestEntityType?
        
        public var description: String {
            guard let entityType = entityType else {
                return getStorageValues().map { "\($0): \($1)" }.joined(separator: "\n")
            }
            
            var separator = ""
            switch entityType {
            case .requestHTTPHeader: separator = "\n"
            case .responseHTTPHeader: separator = "\n"
            case .URLQueryParameter: separator = "&"
            case .HttpBodyParameter: separator = ", "
            }
            
            return getStorageValues().map { "\($0): \($1)" }.joined(separator: separator)
        }
        
        
        /**
         Custom initializer expecting for a `GTRest.RestEntity.RestEntityType`
        */
        init(withEntityType type: RestEntityType) {
            entityType = type
        }
    }
    
    
    /**
     It keeps data related to the server response.
    */
    public struct Response {
        /// The server response as a `URLResponse` object.
        private(set) public var response: URLResponse?
        
        /// The HTTP status code (2xx, 3xx, etc).
        private(set) public var httpStatusCode: Int = 0
        
        /// Any response headers represented as a `RestEntity` object.
        private(set) public var headers = RestEntity(withEntityType: .responseHTTPHeader)
        
        init(fromURLResponse response: URLResponse?) {
            guard let response = response else { return }
            self.response = response
            httpStatusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            if let headerFields = (response as? HTTPURLResponse)?.allHeaderFields {
                for (key, value) in headerFields {
                    headers.add(value: "\(value)", forKey: "\(key)")
                }
            }
        }
    }
    
    
    
    /**
     It contains results related to a web request.
    */
    public struct Results {
        /// The returned data by the server.
        private(set) public var data: Data?
        
        /// A `GTRest.Response` object which contains server response data.
        private(set) public var response: Response?
        
        /// An error object describing potential errors.
        private(set) public var error: Error?
        
        init(withData data: Data?, response: Response?, error: Error?) {
            self.data = data
            self.response = response
            self.error = error
        }
        
        init(withError error: Error) {
            self.error = error
        }
        
        
        /**
         A convenient method to convert raw fetched data to a custom type by decoding
         it using JSONDecoder.
         
         * Important: Custom type must conform to Decodable or Codable protocol.
         
         JSONDecoder object used to decode data in this method can be configured
         in the `decoderConfiguration` handler. Keep it nil in case you don't
         want to make any configuration to JSONDecoder instance.
         
         In case decoding fails an exception is thrown by the method.
         
         **Example:**
         
         Consider the following struct:
         
         ```
         struct User: Codable {
             var id: Int?
             var firstName: String?
             var lastName: String?
         }
         ```
         
         Also, the following server fetched data:
         
         ```
         {
             "id": 325,
             "first_name": "Gabriel",
             "last_name": "Theodoropoulos"
         }
         ```
         
         Here's how to convert fetched user data, using the `decoderConfiguration`
         to set the `convertFromSnakeCase` as the `keyDecodingStrategy`:
         
         ```
         let rest = GTRest()
         let url = URL(...)
         // Additional configuration...
         
         rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
             do {
                if let user = try results.convertData(toType: User.self, decoderConfiguration: { (decoder) in
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                }) {
                    // User data has been successfully converted into a `User` object.
                    print(user)
                }
             } catch {
                print(error.localizedDescription)
             }
         }
         ```
         
         - Parameter type: The custom type to convert `data` to.
         - Parameter decoderConfiguration: Use this closure to perform any
         configuration to the JSONDecoder instance that is used in this method to
         decode the data. Set `nil` if no configuration needed.
         - Parameter decoder: The JSONDecoder instance used to decode fetched data.
         
         - Returns: An object of the custom type specified, or `nil` if no data exists or
         decoding fails.
        */
        public func convertData<T>(toType type: T.Type, decoderConfiguration config: ((_ decoder: inout JSONDecoder) -> Void)?) throws -> T? where T: Decodable {
            guard let data = data else { return nil }
            var decoder = JSONDecoder()
            if let config = config {
                config(&decoder)
            }
            do {
                let T = try decoder.decode(T.self, from: data)
                return T
            } catch {
                print(error.localizedDescription)
                throw error
            }
        }
    }
    
    
    /**
     A custom type to keep data about a file that should be uploaded.
    */
    public struct FileInfo {
        /// The actual file contents as a `Data` object.
        public var fileContents: Data?
        
        /// The MIME type of the file.
        ///
        /// See `GTRest.MimeType` enum for common values optionally.
        public var mimetype: String?
        
        /// The name of the file.
        public var filename: String?
        
        /**
         Public initializer.
        */
        public init() {
            
        }
    }
    
    
    
    /**
     It represents custom errors in GTRest class.
    */
    public enum CustomError: Error {
        /// The URL request object could not be created.
        case failedToCreateRequest
        /// The boundary string used in "multipart/form-data" content type
        /// could not be created.
        case failedToCreateBoundary
        /// HTTP body data could not be created.
        case failedToCreateHttpBody
    }
}




// MARK: - CustomError Extension

extension GTRest.CustomError: LocalizedError {
    /// :nodoc:
    public var localizedDescription: String {
        switch self {
        case .failedToCreateRequest: return NSLocalizedString("GTRest: Unable to create the URLRequest object", comment: "")
        case .failedToCreateBoundary: return NSLocalizedString("GTRest: Unable to create boundary string necessary to separate data to upload", comment: "")
        case .failedToCreateHttpBody: return NSLocalizedString("GTRest: Unable to create Post body parameters data", comment: "")
        }
    }
}
