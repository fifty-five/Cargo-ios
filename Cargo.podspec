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
  s.version          = "2.0.1"
  s.summary          = "Cargo makes it easier to track your mobile app."

  s.description      = <<-DESC
  Cargo is a tool developed by fifty-five. It allows to quickly and easily integrate third-party analytics SDKs through Google Tag Manager.
  With Google Tag Manager (GTM), developers are able to change configuration values in their mobile applications using the GTM interface without having to rebuild and resubmit app binaries to app marketplaces.
                       DESC

  s.homepage         = "https://github.com/fifty-five/Cargo-ios"
  s.license          = 'MIT'
  s.author           = { "Julien" => "julien.gil@fifty-five.com" }
  s.source           = { :git => "https://github.com/fifty-five/Cargo-ios.git", :tag => "v#{s.version.to_s}" }
  s.documentation_url = 'https://github.com/fifty-five/Cargo-ios/wiki'
  s.social_media_url = 'https://twitter.com/55FiftyFive55'

  s.platform     = :ios, '8.0'
  s.requires_arc = true


  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.subspec 'Core' do |ss|
    ss.public_header_files = "Cargo/Core/**/*.h"
    ss.source_files = "Cargo/Core/**/*"
    ss.platform = :ios, '7.0'
    s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => "CARGO_VERSION=#{s.version}" }
    s.dependency 'GoogleTagManager', '~> 5.0.0'
  end

  Build.subspecs.each do |a|
    s.subspec a.name do |ss|
      ss.prefix_header_contents = "#define USE_CARGO_#{a.name.upcase} 1"

      ss.platform = :ios, '8.0'
      ss.public_header_files = ['Cargo/Handlers/*.h', "Cargo/Handlers/#{a.name}/*.h"]
      ss.ios.source_files = "Cargo/Handlers/#{a.name}/*.{h,m}"
      ss.dependency 'Cargo/Core'

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
