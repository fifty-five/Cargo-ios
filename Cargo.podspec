#
# Be sure to run `pod lib lint Cargo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

begin
  require File.expand_path('./scripts/build.rb')
end


Pod::Spec.new do |s|
  s.name             = "Cargo"
  s.version          = "0.1.2"
  s.summary          = "A short description of TestPod."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                       DESC

  s.homepage         = "https://github.com/fifty-five/Cargo-ios"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "louis" => "louis.chavane@gmail.com" }
  s.source           = { :git => "https://github.com/fifty-five/Cargo-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true


  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.subspec 'Cargo-iOS' do |ss|
    ss.public_header_files = ['Cargo/*.h', 'Cargo/*/*.h']
    ss.source_files = ['Cargo/*.{h,m}', 'Cargo/*/*.{h,m}']
    ss.platform = :ios, '7.0'
    s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => "CARGO_VERSION=#{s.version}" }
    s.dependency 'GoogleTagManager', '3.12.1'
  end

  Build.subspecs.each do |a|
    s.subspec a.name do |ss|
      ss.prefix_header_contents = "#define USE_CARGO_#{a.name.upcase} 1"
      ss.public_header_files = ['Cargo/Handlers/*.h', "Cargo/Handlers/#{a.name}/*.h"]
      ss.ios.source_files = "Cargo/Handlers/#{a.name}/*.{h,m}"
      ss.platform = :ios, '7.0'

      ss.dependency 'Cargo/Cargo-iOS'

      (a.dependencies || []).each do |d|
        if d.version
          ss.dependency d.name, d.version
        else
          ss.dependency d.name
        end
      end
    end
  end

end
