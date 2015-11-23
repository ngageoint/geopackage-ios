# Change Log
All notable changes to this project will be documented in this file.
Adheres to [Semantic Versioning](http://semver.org/).

---

## 1.1.3 (TBD)

* TBD

## [1.1.2](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.2) (11-23-2015)

* Bridging Header for Swift
* Fixing file prefix typo on GeoPackage Cache

## [1.1.1](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.1) (11-20-2015)

* Feature Overlay Query message builder, check if features are indexed first
* Data Columns Dao get data column by table and column names method - [Issue #4](https://github.com/ngageoint/geopackage-ios/issues/4)
* Additional GeoPackage createFeatureTableWithMetadata methods - [Issue #8](https://github.com/ngageoint/geopackage-ios/issues/8)
* min and max column query methods - [Issue #5](https://github.com/ngageoint/geopackage-ios/issues/5)
* Determine bounding box from Tile Grid methods - [Issue #7](https://github.com/ngageoint/geopackage-ios/issues/7)
* TileDao methods, query for tile grid or bounding box at zoom level - [Issue #6](https://github.com/ngageoint/geopackage-ios/issues/6)
* Database header and integrity validation options and methods. Validate externally linked GeoPackage headers by default. - [Issue #9](https://github.com/ngageoint/geopackage-ios/issues/9)
* User Table column ordering fix when created user table columns are not presorted by column index - [Issue #10](https://github.com/ngageoint/geopackage-ios/issues/10)

## [1.1.0](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.0) (11-04-2015)

* NGA Table Index Extension implementation - http://ngageoint.github.io/GeoPackage/docs/extensions/geometry-index.html
* Feature Index Manager to combine existing metadata indexing with the NGA Table Index Extension
* Feature Tile improvements, including max features per tile settings and custom max feature tile drawing
* Feature and Tile DAO get bounding box and zoom level methods
* Feature Overlay Query for querying the features behind the drawn feature tiles
* Added new GeoPackageCoreCache functionality
* Get Tile Grid from single point and zoom level method
* Database connection pool and transactions

## [1.0.0](https://github.com/ngageoint/geopackage-ios/releases/tag/1.0.0)  (10-27-2015)

* Initial Release
