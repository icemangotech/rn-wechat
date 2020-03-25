require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "rn-wechat"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  rn-wechat
                   DESC
  s.homepage     = "https://github.com/icemangotech/rn-wechat"
  s.license    = { :type => "BSD-3-Clause", :file => "LICENSE" }
  s.authors      = { "phecda" => "phecda@brae.co" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/icemangotech/rn-wechat.git", :tag => "v#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.frameworks = 'SystemConfiguration','CoreTelephony'
  s.library = 'sqlite3','c++','z'
  s.vendored_libraries = "ios/libWeChatSDK.a"
end

