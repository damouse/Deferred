Pod::Spec.new do |s|
    s.name         = "SwiftDeferred"
    s.version      = "1.0.3"
    s.summary      = "Deferreds for swift"
    s.description  = <<-DESC
                        Deferreds for Swift heavily inspired by Python Twisted's deferreds
                        DESC

    s.homepage     = "https://github.com/damouse/Deferred"
    s.license      = { :type => "MIT", :file => "LICENSE" }
    s.author       = { "Mickey Barboi" => "mickey.barboi@gmail.com" }
    s.source       = { :git => "https://github.com/damouse/Deferred.git", :tag => "1.0.3" }
    s.ios.deployment_target = "8.0"
    s.osx.deployment_target = "10.9"
    s.source_files  = "Deferred", "Deferred/**/*.{swift,h,m}"
    s.requires_arc = true
    
    # s.dependency 'SwiftyJSON', '~> 2.3.1'
    # s.dependency 'Alamofire', '~> 3.4'
    s.dependency 'AnyFunction', '~> 1.0.4'
end
