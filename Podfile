source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'

inhibit_all_warnings!

pod "AFNetworking", "~> 2.1”
pod "proj4", "~> 4.8.0"
#pod 'wkb-ios', :git => 'git@git.geointapps.org:geopackage/wkb-ios.git', :tag => '0.0.1'
pod 'wkb-ios', :path => '../wkb-ios'

target :"geopackage-iosTests", :exclusive => true do
  pod 'geopackage-ios', :path => '.'
end


