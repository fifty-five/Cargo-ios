require File.expand_path("../scripts/build.rb", __FILE__)

# Uncomment this line to define a global platform for your project
platform :ios, '7.0'


def import_pods
  Build.all_pods.each do |p|
    send :pod, p.name, p.version
  end
end

def import_gtm
  send :pod, 'GoogleTagManager', '3.12.1'
end

target 'Cargo' do
  import_gtm
  import_pods
end

target 'CargoTest', :exclusive => true do
  import_gtm
  import_pods
  pod 'OCMockito', '~> 1.0'
end

target 'App' do
  import_gtm
  import_pods
end
