source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

inhibit_all_warnings!

pod 'AFNetworking', '~> 2.1'
pod 'proj4', '~> 4.8'
#pod 'wkb-ios', '~> 1.0'
#pod 'wkb-ios', :git => 'git@git.geointapps.org:geopackage/geopackage-wkb-ios.git', :tag => '1.0.0'
pod 'geopackage-wkb-ios', :path => '../geopackage-wkb-ios'

target :"geopackage-iosTests", :exclusive => true do
  pod 'geopackage-ios', :path => '.'
end
