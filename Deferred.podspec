Pod::Spec.new do |s|
    s.name         = "Deferred"
    s.version      = "1.0.0"
    s.summary      = "Key-Value Coding (KVC) for native Swift classes and structs"
    s.description  = <<-DESC
                        Deferred enables Key-Value Coding (KVC) for native Swift classes and structs.
                        DESC

    s.homepage     = "https://github.com/damouse/Deferred"
    s.license      = { :type => "MIT", :file => "LICENSE" }
    s.author       = { "Mickey Barboi" => "mickey.barboi@gmail.com" }
    s.source       = { :git => "https://github.com/damouse/Deferred.git", :tag => "1.0.0" }
    s.ios.deployment_target = "8.0"
    s.osx.deployment_target = "10.9"
    s.source_files  = "Deferred", "Deferred/**/*.{swift,h,m}"
    s.requires_arc = true
    
    s.dependency 'SwiftyJSON', '~> 2.3.1'
end