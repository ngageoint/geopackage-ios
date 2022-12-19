//
//  GPKGDgiwgGeoPackage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGGeoPackage.h"
#import "GPKGDgiwgFile.h"
#import "GPKGDgiwgValidationErrors.h"
#import "GPKGDgiwgCoordinateReferenceSystems.h"
#import "GPKGMetadataReference.h"

/**
 * DGIWG (Defence Geospatial Information Working Group) GeoPackage
 * implementation
 */
@interface GPKGDgiwgGeoPackage : GPKGGeoPackage

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new DGIWG GeoPackage
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get the DGIWG file
 *
 * @return DGIWG file
 */
-(GPKGDgiwgFile *) file;

/**
 * Get the DGIWG file name
 *
 * @return DGIWG file name
 */
-(GPKGDgiwgFileName *) fileName;

/**
 * Is the GeoPackage valid according to the DGIWG GeoPackage Profile
 *
 * @return true if valid
 */
-(BOOL) isValid;

/**
 * Validate the GeoPackage against the DGIWG GeoPackage Profile
 *
 * @return validation errors
 */
-(GPKGDgiwgValidationErrors *) validate;

/**
 * Get the most recent {@link #validate()} results
 *
 * @return validation errors, null if not yet validated
 */
-(GPKGDgiwgValidationErrors *) errors;

/**
 * Validate the GeoPackage table against the DGIWG GeoPackage Profile
 *
 * @param table table
 * @return validation errors
 */
-(GPKGDgiwgValidationErrors *) validateTable: (NSString *) table;

/**
 * Validate the GeoPackage tables against the DGIWG GeoPackage Profile
 *
 * @param tables tables
 * @return validation errors
 */
-(GPKGDgiwgValidationErrors *) validateTables: (NSArray<NSString *> *) tables;

/**
 * Create tiles table
 *
 * @param table table name
 * @param crs   coordinate reference system
 * @return created tile matrix set
 */
-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs;

/**
 * Create tiles table
 *
 * @param table       table name
 * @param identifier  contents identifier
 * @param description contents description
 * @param crs         coordinate reference system
 * @return created tile matrix set
 */
-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs;

/**
 * Create tiles table
 *
 * @param table             table name
 * @param identifier        contents identifier
 * @param description       contents description
 * @param informativeBounds informative contents bounds
 * @param crs               coordinate reference system
 * @return created tile matrix set
 */
-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andInformativeBounds: (GPKGBoundingBox *) informativeBounds andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs;

/**
 * Create tiles table
 *
 * @param table        table name
 * @param crs          coordinate reference system
 * @param extentBounds crs extent bounds
 * @return created tile matrix set
 */
-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs andExtentBounds: (GPKGBoundingBox *) extentBounds;

/**
 * Create tiles table
 *
 * @param table        table name
 * @param identifier   contents identifier
 * @param description  contents description
 * @param crs          coordinate reference system
 * @param extentBounds crs extent bounds
 * @return created tile matrix set
 */
-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs andExtentBounds: (GPKGBoundingBox *) extentBounds;

/**
 * Create tiles table
 *
 * @param table             table name
 * @param identifier        contents identifier
 * @param description       contents description
 * @param informativeBounds informative contents bounds
 * @param crs               coordinate reference system
 * @param extentBounds      crs extent bounds
 * @return created tile matrix set
 */
-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andInformativeBounds: (GPKGBoundingBox *) informativeBounds andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs andExtentBounds: (GPKGBoundingBox *) extentBounds;

/**
 * Create tiles table
 *
 * @param table        table name
 * @param srs          spatial reference system
 * @param extentBounds crs extent bounds
 * @return created tile matrix set
 */
-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andSRS: (GPKGSpatialReferenceSystem *) srs andExtentBounds: (GPKGBoundingBox *) extentBounds;

/**
 * Create tiles table
 *
 * @param table        table name
 * @param identifier   contents identifier
 * @param description  contents description
 * @param srs          spatial reference system
 * @param extentBounds crs extent bounds
 * @return created tile matrix set
 */
-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andSRS: (GPKGSpatialReferenceSystem *) srs andExtentBounds: (GPKGBoundingBox *) extentBounds;

/**
 * Create tiles table
 *
 * @param table             table name
 * @param identifier        contents identifier
 * @param description       contents description
 * @param informativeBounds informative contents bounds
 * @param srs               spatial reference system
 * @param extentBounds      crs extent bounds
 * @return created tile matrix set
 */
-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andInformativeBounds: (GPKGBoundingBox *) informativeBounds andSRS: (GPKGSpatialReferenceSystem *) srs andExtentBounds: (GPKGBoundingBox *) extentBounds;

/**
 * Create tile matrices for zoom levels
 *
 * @param tileMatrixSet tile matrix set
 * @param minZoom       min zoom level
 * @param maxZoom       max zoom level
 * @param matrixWidth   matrix width
 * @param matrixHeight  matrix height
 */
-(void) createTileMatricesWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight;

/**
 * Create tile matrices for zoom levels
 *
 * @param table        table name
 * @param boundingBox  bounding box
 * @param minZoom      min zoom level
 * @param maxZoom      max zoom level
 * @param matrixWidth  matrix width
 * @param matrixHeight matrix height
 */
-(void) createTileMatricesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight;

/**
 * Create tile matrices for zoom levels
 *
 * @param tileMatrixSet tile matrix set
 * @param zoomLevels    zoom levels
 * @param matrixWidth   matrix width
 * @param matrixHeight  matrix height
 */
-(void) createTileMatricesWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andZoomLevels: (NSArray<NSNumber *> *) zoomLevels andWidth: (int) matrixWidth andHeight: (int) matrixHeight;

/**
 * Create tile matrices for zoom levels
 *
 * @param table        table name
 * @param boundingBox  bounding box
 * @param zoomLevels   zoom levels
 * @param matrixWidth  matrix width
 * @param matrixHeight matrix height
 */
-(void) createTileMatricesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andZoomLevels: (NSArray<NSNumber *> *) zoomLevels andWidth: (int) matrixWidth andHeight: (int) matrixHeight;

/**
 * Create a tile matrix for a zoom level
 *
 * @param tileMatrixSet tile matrix set
 * @param zoom          zoom level
 * @param matrixWidth   matrix width
 * @param matrixHeight  matrix height
 */
-(void) createTileMatrixWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight;

/**
 * Create a tile matrix for a zoom level
 *
 * @param table        table name
 * @param boundingBox  bounding box
 * @param zoom         zoom level
 * @param matrixWidth  matrix width
 * @param matrixHeight matrix height
 */
-(void) createTileMatrixWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight;

/**
 * Create a tile matrix for a zoom level
 *
 * @param table        table name
 * @param zoom         zoom level
 * @param matrixWidth  matrix width
 * @param matrixHeight matrix height
 * @param pixelXSize   pixel x size
 * @param pixelYSize   pixel y size
 */
-(void) createTileMatrixWithTable: (NSString *) table andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight andPixelX: (double) pixelXSize andPixelY: (double) pixelYSize;

/**
 * Create features table
 *
 * @param table        table name
 * @param geometryType geometry type
 * @param crs          coordinate reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs;

/**
 * Create features table
 *
 * @param table        table name
 * @param geometryType geometry type
 * @param columns      feature columns
 * @param crs          coordinate reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs;

/**
 * Create features table
 *
 * @param table        table name
 * @param identifier   contents identifier
 * @param description  contents description
 * @param geometryType geometry type
 * @param crs          coordinate reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs;

/**
 * Create features table
 *
 * @param table        table name
 * @param identifier   contents identifier
 * @param description  contents description
 * @param geometryType geometry type
 * @param columns      feature columns
 * @param crs          coordinate reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs;

/**
 * Create features table
 *
 * @param table        table name
 * @param bounds       contents bounds
 * @param geometryType geometry type
 * @param crs          coordinate reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs;

/**
 * Create features table
 *
 * @param table        table name
 * @param bounds       contents bounds
 * @param geometryType geometry type
 * @param columns      feature columns
 * @param crs          coordinate reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs;

/**
 * Create features table
 *
 * @param table        table name
 * @param identifier   contents identifier
 * @param description  contents description
 * @param bounds       contents bounds
 * @param geometryType geometry type
 * @param crs          coordinate reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs;

/**
 * Create features table
 *
 * @param table        table name
 * @param identifier   contents identifier
 * @param description  contents description
 * @param bounds       contents bounds
 * @param geometryType geometry type
 * @param columns      feature columns
 * @param crs          coordinate reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs;

/**
 * Create features table
 *
 * @param table        table name
 * @param bounds       contents bounds
 * @param geometryType geometry type
 * @param dataType     data type
 * @param srs          spatial reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andSRS: (GPKGSpatialReferenceSystem *) srs;

/**
 * Create features table
 *
 * @param table        table name
 * @param bounds       contents bounds
 * @param geometryType geometry type
 * @param dataType     data type
 * @param columns      feature columns
 * @param srs          spatial reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andSRS: (GPKGSpatialReferenceSystem *) srs;

/**
 * Create features table
 *
 * @param table        table name
 * @param identifier   contents identifier
 * @param description  contents description
 * @param bounds       contents bounds
 * @param geometryType geometry type
 * @param dataType     data type
 * @param srs          spatial reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andSRS: (GPKGSpatialReferenceSystem *) srs;

/**
 * Create features table
 *
 * @param table        table name
 * @param identifier   contents identifier
 * @param description  contents description
 * @param bounds       contents bounds
 * @param geometryType geometry type
 * @param dataType     data type
 * @param columns      feature columns
 * @param srs          spatial reference system
 * @return created geometry columns
 */
-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andSRS: (GPKGSpatialReferenceSystem *) srs;

/**
 * Create metadata and metadata reference
 *
 * @param metadata  metadata
 * @param reference metadata reference
 */
-(void) createMetadata: (GPKGMetadata *) metadata andReference: (GPKGMetadataReference *) reference;

/**
 * Create metadata
 *
 * @param metadata metadata
 */
-(void) createMetadata: (GPKGMetadata *) metadata;

/**
 * Create metadata reference
 *
 * @param reference metadata reference
 * @param metadata  the reference metadata
 */
-(void) createMetadataReference: (GPKGMetadataReference *) reference withMetadata: (GPKGMetadata *) metadata;

/**
 * Create metadata reference
 *
 * @param reference metadata reference
 */
-(void) createMetadataReference: (GPKGMetadataReference *) reference;

/**
 * Create GeoPackage metadata with a series scope and metadata reference
 *
 * @param metadata metadata
 * @param uri      URI
 * @return metadata reference
 */
-(GPKGMetadataReference *) createGeoPackageSeriesMetadata: (NSString *) metadata withURI: (NSString *) uri;

/**
 * Create GeoPackage metadata with a dataset scope and metadata reference
 *
 * @param metadata metadata
 * @param uri      URI
 * @return metadata reference
 */
-(GPKGMetadataReference *) createGeoPackageDatasetMetadata: (NSString *) metadata withURI: (NSString *) uri;

/**
 * Create GeoPackage metadata and metadata reference
 *
 * @param metadata metadata
 * @param scope    metadata scope type
 * @param uri      URI
 * @return metadata reference
 */
-(GPKGMetadataReference *) createGeoPackageMetadata: (NSString *) metadata withScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri;

/**
 * Create metadata and metadata reference
 *
 * @param scope     metadata scope type
 * @param uri       URI
 * @param metadata  metadata
 * @param reference metadata reference
 * @return metadata reference
 */
-(GPKGMetadataReference *) createMetadata: (NSString *) metadata withScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri andReference: (GPKGMetadataReference *) reference;

/**
 * Query for GeoPackage DGIWG Metadata Foundation (DMF) metadata
 *
 * @return metadata references
 */
-(GPKGResultSet *) queryGeoPackageDMFMetadata;

/**
 * Query for GeoPackage NSG Metadata Foundation (NMF) NSG Application Schema
 * (NAS) metadata
 *
 * @return metadata references
 */
-(GPKGResultSet *) queryGeoPackageNASMetadata;

/**
 * Query for GeoPackage metadata
 *
 * @param baseURI base URI
 * @return metadata references
 */
-(GPKGResultSet *) queryGeoPackageMetadataWithBaseURI: (NSString *) baseURI;

@end
