Pod::Spec.new do |spec|

  spec.name         = "GTRest"
  spec.version      = "1.0.0"
  spec.summary      = "A lightweight Swift library for making web requests and consuming RESTful APIs!"
  spec.description  = <<-DESC
                    GTRest makes it super easy and straightforward to perform web requests and work with RESTful APIs in iOS projects using Swift.
                   DESC
  spec.homepage     = "https://github.com/gabrieltheodoropoulos/GTRest"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.authors      = { "Gabriel Theodoropoulos" => "gabrielth.devel@gmail.com" }
  spec.social_media_url   = "https://twitter.com/gabtheodor"
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/gabrieltheodoropoulos/GTRest.git", :tag => "1.0.0" }
  spec.source_files = "GTRest/Source/*.{swift}"
  spec.swift_version = "4.2"

end
