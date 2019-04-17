//
//  GTRestDefaultValues.swift
//  GTRest
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Gabriel Theodoropoulos. All rights reserved.
//

import Foundation

// MARK: - Common HTTP headers and MIME types.
extension GTRest {
    /**
     Common HTTP headers.
    */
    public enum HttpHeader: String {
        /// Accept
        case accept = "Accept"
        /// Accept-Charset
        case acceptCharset = "Accept-Charset"
        /// Accept-Encoding
        case acceptEncoding = "Accept-Encoding"
        /// Accept-Language
        case acceptLanguage = "Accept-Language"
        /// Authorization
        case authorization = "Authorization"
        /// Cache-Control
        case cacheControl = "Cache-Control"
        /// Connection
        case connection = "Connection"
        /// Content-Length
        case contentLength = "Content-Length"
        /// Content-MD5
        case contentMD5 = "Content-MD5"
        /// Content-Type
        case contentType = "Content-Type"
        /// Date
        case date = "Date"
        /// Expect
        case expect = "Expect"
        /// From
        case from = "From"
        /// Host
        case host = "Host"
        /// If-Match
        case ifMatch = "If-Match"
        /// If-Modified-Since
        case ifModifiedSince = "If-Modified-Since"
        /// If-None-Match
        case ifNoneMatch = "If-None-Match"
        /// If-Range
        case ifRange = "If-Range"
        /// If-Unmodified-Since
        case ifUnmodifiedSince = "If-Unmodified-Since"
        /// Max-Forwards
        case maxForwards = "Max-Forwards"
        /// Pragma
        case pragma = "Pragma"
        /// Proxy-Authorization
        case proxyAuthorization = "Proxy-Authorization"
        /// Range
        case range = "Range"
        /// Referer
        case referer = "Referer"
        /// TE
        case tE = "TE"
        /// User-Agent
        case userAgent = "User-Agent"
        /// Via
        case via = "Via"
        /// Warning
        case warning = "Warning"
        /// Cookie
        case cookie = "Cookie"
        /// Origin
        case origin = "Origin"
        /// Accept-Datetime
        case acceptDatetime = "Accept-Datetime"
    }
    
    
    /**
     Common MIME types.
    */
    public enum MimeType: String {
        /// application/javascript
        case applicationJavascript = "application/javascript"
        /// application/json
        case applicationJson = "application/json"
        /// application/octet-stream
        case applicationOctetStream = "application/octet-stream"
        /// application/ogg
        case applicationOgg = "application/ogg"
        /// application/pdf
        case applicationPdf = "application/pdf"
        /// application/x-www-form-urlencoded
        case applicationXWwwFormUrlencoded = "application/x-www-form-urlencoded"
        /// application/xhtml+xml
        case applicationXhtmlXml = "application/xhtml+xml"
        /// application/xml
        case applicationXml = "application/xml"
        /// application/zip
        case applicationZip = "application/zip"
        /// audio/midi
        case audioMidi = "audio/midi"
        /// audio/mpeg
        case audioMpeg = "audio/mpeg"
        /// audio/ogg
        case audioOgg = "audio/ogg"
        /// audio/wav
        case audioWav = "audio/wav"
        /// audio/webm
        case audioWebm = "audio/webm"
        /// image/gif
        case imageGif = "image/gif"
        /// image/jpeg
        case imageJpeg = "image/jpeg"
        /// image/png
        case imagePng = "image/png"
        /// image/svg+xml
        case imageSvgXml = "image/svg+xml"
        /// image/tiff
        case imageTiff = "image/tiff"
        /// multipart/alternative
        case multipartAlternative = "multipart/alternative"
        /// multipart/form-data
        case multipartFormData = "multipart/form-data"
        /// multipart/mixed
        case multipartMixed = "multipart/mixed"
        /// multipart/related
        case multipartRelated = "multipart/related"
        /// text/css
        case textCss = "text/css"
        /// text/csv
        case textCsv = "text/csv"
        /// text/html
        case textHtml = "text/html"
        /// text/plain
        case textPlain = "text/plain"
        /// text/xml
        case textXml = "text/xml"
        /// video/mp4
        case videoMp4 = "video/mp4"
        /// video/mpeg
        case videoMpeg = "video/mpeg"
        /// video/ogg
        case videoOgg = "video/ogg"
        /// video/quicktime
        case videoQuicktime = "video/quicktime"
        /// video/webm
        case videoWebm = "video/webm"
    }
}

