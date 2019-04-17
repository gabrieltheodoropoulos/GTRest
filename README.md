# GTRest
A lightweight Swift library for making web requests and consuming RESTful APIs!

## Adding GTRest to your project

### Using CocoaPods

In your Podfile add:

```ruby
pod `GTRest`
```

Don't forget to import GTRest anywhere you want to use it in your project:

```swift
import GTRest
```

### Manually

Download or clone the repository, and add the files in *GTRest/Source* directory to your project.

## Usage

Making web requests with GTRest is really simple and straightforward!

See the [Documentation](https://gtiapps.com/docs/gtrest/index.html) generated by [jazzy](https://github.com/realm/jazzy) on how to use GTRest.

A quick example:

```swift
let url = URL(...) // A URL object.
let rest = GTRest()

// Set any request HTTP headers:
rest.requestHttpHeaders.add(value: "application/json", forKey: "Accept")

// Set any URL query parameters:
rest.urlQueryParameters.add(value: "2", forKey: "page")

// Make a request.
rest.makeRequest(toURL: url, httpMethod: .get) { [unowned self] (results) in // or [weak self] (results) in
    // Access data returned by the server:
    if let data = results.data {
        // Perform app-specific actions
    }

    // Access the response:
    if let response = results.response {
        // Do something with the response object if necessary.
        // Checking the HTTP status code :
        if (200...299).contains(response.httpStatusCode) {
            // Successful request.
        } else { ... }
    }

    // Access the error:
    if let error = results.error {
        // Do something with the error.
    }

    // Always update your UI on main thread:
    DispatchQueue.main.async {
        // Update UI.
    }
}
```

## Requirements

iOS 11.0 and above.

## See Also

You might be also interested in [GTNetMon](https://github.com/gabrieltheodoropoulos/GTNetMon), another Swift library to get network status and connection information, and to monitor for network changes.
