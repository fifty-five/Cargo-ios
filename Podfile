require File.expand_path("../scripts/build.rb", __FILE__)

# Uncomment this line to define a global platform for your project
platform :ios, '7.0'

source 'https://github.com/Accengage/CocoaPodsSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

def import_pods
  Build.all_pods.each do |p|
    send :pod, p.name, p.version
  end
end

def import_gtm
  send :pod, 'GoogleTagManager', '~> 3.15.0'
end

target 'Cargo' do
  import_gtm
  import_pods
end

target 'CargoTest' do
  import_gtm
  import_pods
  pod 'OCMockito', '~> 3.0'
end

target 'App' do
  import_gtm
  import_pods
end
