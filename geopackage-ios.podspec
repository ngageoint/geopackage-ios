Pod::Spec.new do |s|
  s.name             = "geopackage-ios"
  s.version          = "1.0.0"
  s.summary          = "iOS SDK for GeoPackage"
  s.description      = <<-DESC
                       iOS SDK for GeoPackage
                       DESC
  s.homepage         = "https://www.nga.mil"
  s.license          = 'DOD'
  s.author           = { "NGA" => "osbornb@bit-sys.com" }
  s.source           = { :git => "https://git.geointapps.org/geopackage/geopackage-ios.git", :tag => s.version.to_s }

  s.platform         = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.source_files = 'geopackage-ios/**/*.{h,m}'
  s.prefix_header_file = 'geopackage-ios/geopackage-ios-Prefix.pch'

  #s.ios.exclude_files = 'Classes/osx'
  #s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.resource_bundle = { 'GeoPackage' => ['geopackage-ios/**/*.plist'] }
  s.resources = ['geopackage-ios/**/*.xcdatamodeld']
  s.frameworks = 'Foundation'
  s.dependency 'AFNetworking', '~> 2.1'
  s.dependency 'proj4', '~> 4.8'
  s.dependency 'geopackage-wkb-ios', '~> 1.0'
end
