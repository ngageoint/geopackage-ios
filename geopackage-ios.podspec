Pod::Spec.new do |s|
  s.name             = 'geopackage-ios'
  s.version          = '1.3.1'
  s.license          =  {:type => 'MIT', :file => 'LICENSE' }
  s.summary          = 'iOS SDK for GeoPackage'
  s.homepage         = 'https://github.com/ngageoint/geopackage-ios'
  s.authors          = { 'NGA' => '', 'BIT Systems' => '', 'Brian Osborn' => 'osbornb@bit-sys.com' }
  s.social_media_url = 'https://twitter.com/NGA_GEOINT'
  s.source           = { :git => 'https://github.com/ngageoint/geopackage-ios.git', :tag => s.version }
  s.requires_arc     = true

  s.platform         = :ios, '8.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'geopackage-ios/**/*.{h,m}'

  s.resource_bundle = { 'GeoPackage' => ['geopackage-ios/**/*.plist'] }
  s.frameworks = 'Foundation'

  s.library = 'sqlite3'

  s.dependency 'proj4-ios', '~> 4.9.3'
  s.dependency 'wkb-ios', '~> 1.0.8'
  s.dependency 'tiff-ios', '~> 1.0.4'
end
