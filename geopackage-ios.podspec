Pod::Spec.new do |s|
  s.name             = 'geopackage-ios'
  s.version          = '7.4.3'
  s.license          =  {:type => 'MIT', :file => 'LICENSE' }
  s.summary          = 'iOS SDK for GeoPackage'
  s.homepage         = 'https://github.com/ngageoint/geopackage-ios'
  s.authors          = { 'NGA' => '', 'BIT Systems' => '', 'Brian Osborn' => 'bosborn@caci.com' }
  s.social_media_url = 'https://twitter.com/NGA_GEOINT'
  s.source           = { :git => 'https://github.com/ngageoint/geopackage-ios.git', :tag => s.version }
  s.requires_arc     = true

  s.platform         = :ios, '12.0'
  s.ios.deployment_target = '12.0'

  s.source_files = 'geopackage-ios/**/*.{h,m}'

  s.resource_bundle = { 'geopackage-ios' => ['geopackage-ios/**/geopackage*.plist'] }
  s.frameworks = 'Foundation'

  s.library = 'sqlite3'

  s.dependency 'sf-wkb-ios', '~> 4.1.2'
  s.dependency 'sf-wkt-ios', '~> 2.1.2'
  s.dependency 'sf-proj-ios', '~> 5.1.3'
  s.dependency 'ogc-api-features-json-ios', '~> 4.2.3'
  s.dependency 'color-ios', '~> 1.0.1'
  s.dependency 'tiff-ios', '~> 4.0.1'
end
