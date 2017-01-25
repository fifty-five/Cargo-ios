require File.expand_path("../scripts/build.rb", __FILE__)

# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

def import_pods
  Build.all_pods.each do |p|
    send :pod, p.name, p.version
  end
end

def import_gtm
  send :pod, 'Firebase/Core'
  send :pod, 'GoogleTagManager', '~> 5.0'
end

target 'Cargo' do
  import_gtm
  import_pods
end

target 'CargoTest' do
  import_gtm
  import_pods
  pod 'OCMockito', '~> 4.0.0'
end

target 'App' do
  import_gtm
  import_pods
end
