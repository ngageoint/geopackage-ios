# Change Log
All notable changes to this project will be documented in this file.
Adheres to [Semantic Versioning](http://semver.org/).

---

## [3.2.0](https://github.com/ngageoint/geopackage-ios/releases/tag/3.2.0) (04-03-2019)

* sf-wkb-ios version 2.0.2
* sf-proj-ios version 2.0.2
* tiff-io version 1.1.2
* NGA [Contents Id](http://ngageoint.github.io/GeoPackage/docs/extensions/contents-id.html) Extension
* NGA [Feature Style](http://ngageoint.github.io/GeoPackage/docs/extensions/feature-style.html) Extension
* OGC [Related Tables](http://www.geopackage.org/18-000.html) Extension improvements
* Feature Tile drawing and generator improvements including scaling, styles, and layering
* FeatureIndexResults id iteration option in place of reading full feature rows
* Feature Cache for memory caching feature rows in a single table
* Feature Cache Tables for memory caching feature rows from multiple single GeoPackage tables
* Feature Row geometry type accessor
* GeoPackage user version saved as 1.2.1
* Improved GeoPackage extension cleanup
* Color support and utilities for hex, RBG, arithmetic RBG, HSL, and integer colors
* Common data type and contents methods for all User Table types
* GeoPackage contents check for table names
* Build an envelope from a Bounding Box
* WKT for Coordinate Reference Systems extension default value of 'undefined' removed
* Feature Style cache and utilities
* Feature Shape for maintaining shapes and metadata shapes for a single feature
* Feature Shapes improvements for maintaining map shapes
* Overlay improvements for bounds checking
* Map Point Options anchor setter
* Custom styled / options Polyline and Polygon objects with updates to Map Shape Converter

## [3.1.0](https://github.com/ngageoint/geopackage-ios/releases/tag/3.1.0) (10-05-2018)

* Xcode 10 fix
* Simple Features Projection (sf-proj-ios) version 2.0.1
* Simple Features WKB (sf-wkb-ios) version 2.0.1
* TIFF (tiff-ios) version 1.1.1
* Related Tables Extension fix to save Simple Attributes and Media tables as Attribute table types
* Bounding Box methods: intersects, overlap, union, and contains
* Bounding Box and Tile Grid isEqual implementations
* GeoPackage Contents Bounding Box and overall Bounding Box methods
* GeoPackage Geometry Index Table index methods, independent of table creation
* GeoPackage Cache connection close improvements & has GeoPackage method
* User Table DAO projected bounding box methods
* Contents DAO bounds and projection methods
* Connection, SQL Utils, and Base DAO query improvements
* Feature Indexer and Feature Table Index chunked limit queries when indexing
* Table Creator improvements for generic SQL script execution
* Result Set fix for logged misuse error from multiple final moveToNext calls
* Result Set close statement only method
* Base DAO set and get value fix for columns beyond configured column indexes
* Geometry Metadata Data Source bounding box methods
* RTree extension support improvements, including querying geometries
* Feature Index Results interface and implementations
* Feature Index Manager support for RTree and Manual queries
* Feature Row geometry value and envelope methods
* Feature Table Reader ignore case of geometry column name
* Manual Feature Queries for unindexed geometries
* Geometry Data get or build envelope method
* Additional Date Converter format to handle format yyyy/MM/dd
* User DAO, Tile Matrix Set, and Tile DAO bounds in projection method
* User Row NSDate fix for date and date time data types
* Tile Overlays load tiles in a new thread

## [3.0.2](https://github.com/ngageoint/geopackage-ios/releases/tag/3.0.2) (07-27-2018)

* Geometry Utils computeAreaOfDegreesPath fix
* Properties Extension for saving GeoPackage metadata in the file
* Properties Manager for using the Properties Extension on multiple open GeoPackages
* Create Attributes Table methods with unique constraints
* Remove Data Columns requirement of enumerated data types
* GeoPackage Cache add all method
* Additional Connection and SQL Utils query methods
* Additional Base DAO deletion and query methods

## [3.0.1](https://github.com/ngageoint/geopackage-ios/releases/tag/3.0.1) (07-16-2018)

* Database name fix when opening a GeoPackage with a name different from the file name
* Related Tables Extension support
* Additional table, table type, and contents methods and improvements
* Base DAO and User DAO support for id-less and auto increment id tables
* Base DAO "like" query support
* Custom User table, column, DAO, row, and table reader implementations
* Recommended project updates

## [3.0.0](https://github.com/ngageoint/geopackage-ios/releases/tag/3.0.0) (05-18-2018)

* WKB dependency updated to use new [Simple Features WKB library](https://github.com/ngageoint/simple-features-wkb-ios)
  * Class prefixes in dependent classes must be updated from "WKB" to "SF" or "SFW"
  * GeometryType code calls must be replaced using GeometryCodes
* Common projection code moved to [Simple Features Projections library](https://github.com/ngageoint/simple-features-proj-ios)
  * Class prefixes in dependent classes must be updated from "GPKG" to "SFP"
  * ProjectionFactory SRS calls must be replaced using SpatialReferenceSystem projection method
  * ProjectionTransform bounding box calls must be replaced using BoundingBox transform method
* Feature Tiles projection bug fix when drawing tiles from features
* Bounding Box projection transform method
* Spatial Reference System projection and transformation methods
* Gridded Coverage Data extension definition url
* Composite Overlay for combining multiple overlays into a single map overlay
* Overlay Factory composite overlay and linked feature overlay creation methods
* Map Shape Converter bounding box transformation methods

## [2.0.2](https://github.com/ngageoint/geopackage-ios/releases/tag/2.0.2) (03-21-2018)

* Tile Scaling extension for displaying missing tiles using nearby zoom levels
* Projection Transform "is same projection" method
* Tile DAO zoom level improvements and approximate zoom level determinations
* Skip tiles drawn from features when no features overlap the tile
* Tile Generator fix to save updated bounds in the Tile Matrix Set
* Tile Generator projection transformations only when projections differ
* Stream closing improvements
* Feature Tiles close method
* RTree Trigger Update 3 spec fix

## [2.0.1](https://github.com/ngageoint/geopackage-ios/releases/tag/2.0.1) (02-14-2018)

* Coverage Data extension (previously Elevation Extension)
* WebP extension column name fix
* Zoom Other extension column name fix
* RTree Index Extension support
* Extended Geometry bit encoding fix, set only for non standard geometries
* Tile Grid zoom increase and decrease utilities
* Tile Generator contents bounding box fix to use the requested bounds
* Database Decimal Number data type fix for database reads
* Zoom level determination fix for bounds resulting in a single point
* Correct Geometry Type fix for created Feature Tables
* User table unique constraint fix for created tables
* Quote wrapping improvements and additional wrapping of names in SQL operations
* GeoPackage creation example
* wkb version update to 1.0.9

## [2.0.0](https://github.com/ngageoint/geopackage-ios/releases/tag/2.0.0) (11-21-2017)

* WARNING - GPKGBoundingBox coordinate constructor arguments order changed to (min lon, min lat, max lon, max lat)
* WARNING - GPKGTileGrid constructor arguments order changed to (minX, minY, maxX, maxY)
* Bounding Box envelope constructor
* Bounding Box projection based complementary, bounding, and expansion methods
* Feature Indexer and Feature Table Index row syncing
* Improved feature row geometry blob handling
* FeatureShapes for maintaining active map Shapes
* Map Shape Converter geometry simplifications
* Map Shape Converter memory improvements
* MapUtils for zoom, tolerance distance, map bounds, click bounds utilities, and location on shape determinations
* Projection transformations for lists of points
* Minor SQL changes to match spec changes
* Bounding box utility improvements for overlap and point in box testing
* Tolerance distance utility methods for geometry proximity testing
* Feature Tiles geometry simplifications
* Multiple Results and List Results implementations of Feature Index results
* Feature Index Manager index type specific improvements
* Tile Creator source image size check
* User Table / Row has id check & columns of a type methods
* User Row Sync implementation to support sharing user row query results
* FeatureInfoBuilder for common feature creating result messages and data
* tiff-ios version updated to 1.1.0
* wkb version update to 1.0.8

## [1.3.0](https://github.com/ngageoint/geopackage-ios/releases/tag/1.3.0) (07-31-2017)

* Projections refactor to support additional coordinate authorities and custom projections
* Mutable copy implementations for base, extension, and user table (features, tiles, attributes) row objects
* Date Time utils formatter creation and date to string conversions
* Improved date column support for user tables (features, tiles, attributes)
* User table zoom level bounding of degree unit projections
* Tile Bounding Box Utils method to bound degree unit bounding box with web mercator limits
* Bounding of degree projected boxes before Web Mercator transformations
* Curve Polygon to map polygon support (drawn as straight lines)
* DAO where clause cascading delete fixes due to open connections during deletions
* Result Set move to position off by one fix
* Base DAO fix to handle insertions of all nil values

## [1.2.3](https://github.com/ngageoint/geopackage-ios/releases/tag/1.2.3) (07-10-2017)

* Bug fix for indexed feature row enumeration in optimized release builds
* Improved handling of unknown Contents bounding boxes
* Feature Tiles fix for max feature number drawn tiles on non retina screens
* tiff-ios version updated to 1.0.3

## [1.2.2](https://github.com/ngageoint/geopackage-ios/releases/tag/1.2.2) (06-14-2017)

* Allow user tables (feature, tile, attributes) without primary keys to support table views
* Support EPSG 900913 (GOOGLE)
* Elevation Extension scale, offset, and id columns changed to be non nullable
* Bug fixes for elevation extension when handling null elevations
* Timezone fixes for Contents last change and Metadata Reference timestamp
* Geometry utilities
* Map Shape Converter fix for single point polygon points at creation time
* Map Shape Converter default constructor
* Map Shape Converter draw shapes using closest longitude direction between consecutive points
* Map Shape Converter complementary path creation for shapes over -180 / 180 longitudes
* Map Shape hidden setters
* Map Shape Markers size and is empty methods
* Map Point Options support for pinTintColor alongside deprecated pinColor
* Map Point Options mutable copy support
* Close Polygons converting from Google Map Shapes to Geometries
* Default and optional polygon counterclockwise and clockwise conversion orientations
* Removed AFNetworking dependency
* tiff-ios version updated to 1.0.2
* proj4-ios verion 4.9.3
* wkb version update to 1.0.7

## [1.2.1](https://github.com/ngageoint/geopackage-ios/releases/tag/1.2.1) (02-02-2017)

* GeoPackage spec version 1.2 changes and updates
* Elevation Extension support (PNG & TIFF)
* User Attributes table support
* tiff-ios dependency for TIFF support
* Elevation Tiles table type (2d-gridded-coverage)
* Contents Data Type (features, tiles, attributes, elevation) functionality
* Built in support for WGS 84 Geographic 3d projection (EPSG:4979)
* Table and column name SQL quotations to allow uncommon but valid names
* Elevation query algorithms including Nearest Neighbor, Bilinear, and Bicubic
* Elevation unbounded results elevation queries
* Tile bounding box utility methods precision adjustments
* Spatial Reference System definition_12_163 column changed to definition_12_063
* Deprecated the User Geometry Types Extension per spec removal
* Deprecated gpkx file extension for extended GeoPackages per spec removal
* GeoPackage application id and user version
* Additional Tile Dao zoom level determinations, including the closest
* Zoom level determination using width and height
* Resource cleanup including fix for [Issue #25](https://github.com/ngageoint/geopackage-ios/issues/25)

## [1.2.0](https://github.com/ngageoint/geopackage-ios/releases/tag/1.2.0) (06-23-2016)

* Spatial Reference System DAO create from EPSG code in addition to SRS id
* Projection unit retrieval
* Dropped web mercator terminology from method names that only require consistent units per pixel
* Zoom level from tile size in meters method
* Image rectangle from bounding box methods
* WGS84 tile grid, bounding box, tiles per side, and tile size methods
* Tile Generator support for multiple projections, such as WGS84 in addition to Web Mercator
* URL Tile Generator changed to use provided projection in place of parsing URL
* Improved tile drawing on bounds for tiles not lining up with requests
* Tile Creator providing common tile generation functionality
* Tile reprojections between different unit types (ex. WGS84 GeoPackage tiles)
* Tile DAO changed to work with any projection units
* Tile DAO utility methods

## [1.1.11](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.11) (05-10-2016)

* AFNetworking version updated to 3.1 with GeoPackage Manager code adaptations
* GeoPackage 1.1.0 spec updates
* GeoPackage application id updated to GP11
* OGC Well known text representation of Coordinate Reference Systems extension support
* GeoPackage Connection column exists, add column, and query single result methods
* Base extension with implementations and support for: CRS WKT, Geometries, Metadata, Schema, WebP, and Zoom Other
* Projection creations from Spatial Reference Systems
* Data Column Constraint column name changes per spec
* Include projection when building Feature Overlay Query map click messages
* Feature Overlay Query use of Data Column names in place of the column name when available

## [1.1.10](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.10) (03-18-2016)

* wkb-ios version updated to 1.0.6
* GeoPackage like and not like name queries
* Import GeoPackage as link to existing file
* Delete a GeoPackage without deleting the database file
* Automatic deletion of GeoPackages with missing database files
* Map click query improvements including projections, feature table data responses, and additional supported input parameters
* Feature table data to JSON compatible object conversions
* Tile Retriever standalone logic extracted from GeoPackage Overlay

## [1.1.9](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.9) (03-04-2016)

* GeoPackage validate has GeoPackage extension bug fix
* Additional GeoPackage manager import GeoPackage from path method
* GeoPackage table type check methods

## [1.1.8](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.8) (02-22-2016)

* Fixing the SQL date format to include milliseconds
* Removing unused GeoPackage Overlay method parameters

## [1.1.7](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.7) (02-12-2016)

* Standard Format Overlay has tile to retrieve implementation

## [1.1.6](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.6) (02-10-2016)

* Additional Feature Tile Table Linker methods for retrieving table names and data access objects
* Bounded Overlay check if a specified tile exists
* Feature Overlay ignore drawing tiles that already exist in a linked tile table
* Feature Overlay Query improved determination if a tile exists before querying features

## [1.1.5](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.5) (02-09-2016)

* Feature Tile Link Extension implementation - http://ngageoint.github.io/GeoPackage/docs/extensions/feature-tile-link.html
* Feature Tile Generator linking between feature and tile tables
* Feature Overlay Query updates to support linked feature and tile tables
* GeoPackage drop table method
* Added delete all methods to base data access object
* Delete extensions when deleting a user table
* Removed CFBundleExecutable key from bundle
* wkb-ios version updated to 1.0.4

## [1.1.4](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.4) (01-20-2016)

* Geometry projection transformations

## [1.1.3](https://github.com/ngageoint/geopackage-ios/releases/tag/1.1.3) (12-14-2015)

* Table Index Extension invalid foreign key fix - [Issue #13](https://github.com/ngageoint/geopackage-ios/issues/13)
* GeoPackage methods: execute SQL, query, foreign key check, integrity check, quick integrity check
* URL Tile Generator TMS support
* Tile Generator fix for updating a GeoPackage and replacing an existing tile

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
