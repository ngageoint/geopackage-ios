//
//  GPKGDgiwgUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"
#import "GPKGMetadataReference.h"
#import "GPKGDgiwgDataTypes.h"

/**
 * DGIWG (Defence Geospatial Information Working Group) GeoPackage utilities
 */
@interface GPKGDgiwgUtils : NSObject

/**
 * Create tiles table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param identifier
 *            contents identifier
 * @param description
 *            contents description
 * @param informativeBounds
 *            informative contents bounds
 * @param srs
 *            spatial reference system
 * @param extentBounds
 *            crs extent bounds
 * @return created tile matrix set
 */
+(GPKGTileMatrixSet *) createTilesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andInformativeBounds: (GPKGBoundingBox *) informativeBounds andSRS: (GPKGSpatialReferenceSystem *) srs andExtentBounds: (GPKGBoundingBox *) extentBounds;

/**
 * Create tile matrices for zoom levels
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param boundingBox
 *            bounding box
 * @param minZoom
 *            min zoom level
 * @param maxZoom
 *            max zoom level
 * @param matrixWidth
 *            matrix width
 * @param matrixHeight
 *            matrix height
 */
+(void) createTileMatricesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight;

/**
 * Create tile matrices for zoom levels
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param boundingBox
 *            bounding box
 * @param zoomLevels
 *            zoom levels
 * @param matrixWidth
 *            matrix width
 * @param matrixHeight
 *            matrix height
 */
+(void) createTileMatricesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andZoomLevels: (NSArray<NSNumber *> *) zoomLevels andWidth: (int) matrixWidth andHeight: (int) matrixHeight;

/**
 * Create a tile matrix for a zoom level
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param boundingBox
 *            bounding box
 * @param zoom
 *            zoom level
 * @param matrixWidth
 *            matrix width
 * @param matrixHeight
 *            matrix height
 */
+(void) createTileMatrixWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight;

/**
 * Create a tile matrix for a zoom level
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param zoom
 *            zoom level
 * @param matrixWidth
 *            matrix width
 * @param matrixHeight
 *            matrix height
 * @param pixelXSize
 *            pixel x size
 * @param pixelYSize
 *            pixel y size
 */
+(void) createTileMatrixWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight andPixelX: (double) pixelXSize andPixelY: (double) pixelYSize;

/**
 * Create features table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param identifier
 *            contents identifier
 * @param description
 *            contents description
 * @param bounds
 *            contents bounds
 * @param geometryType
 *            geometry type
 * @param dataType
 *            data type
 * @param columns
 *            feature columns
 * @param srs
 *            spatial reference system
 * @return created tile matrix set
 */
+(GPKGGeometryColumns *) createFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andSRS: (GPKGSpatialReferenceSystem *) srs;

/**
 * Create metadata and metadata reference
 *
 * @param geoPackage
 *            GeoPackage
 * @param metadata
 *            metadata
 * @param reference
 *            metadata reference
 */
+(void) createMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andMetadata: (GPKGMetadata *) metadata andReference: (GPKGMetadataReference *) reference;

/**
 * Create metadata
 *
 * @param geoPackage
 *            GeoPackage
 * @param metadata
 *            metadata
 */
+(void) createMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andMetadata: (GPKGMetadata *) metadata;

/**
 * Create metadata reference
 *
 * @param geoPackage
 *            GeoPackage
 * @param metadata
 *            the reference metadata
 * @param reference
 *            metadata reference
 */
+(void) createMetadataReferenceWithGeoPackage: (GPKGGeoPackage *) geoPackage andMetadata: (GPKGMetadata *) metadata andReference: (GPKGMetadataReference *) reference;

/**
 * Create metadata reference
 *
 * @param geoPackage
 *            GeoPackage
 * @param reference
 *            metadata reference
 */
+(void) createMetadataReferenceWithGeoPackage: (GPKGGeoPackage *) geoPackage andReference: (GPKGMetadataReference *) reference;

/**
 * Create GeoPackage metadata with a series scope and metadata reference
 *
 * @param geoPackage
 *            GeoPackage
 * @param uri
 *            URI
 * @param metadata
 *            metadata
 * @return metadata reference
 */
+(GPKGMetadataReference *) createGeoPackageSeriesMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andURI: (NSString *) uri andMetadata: (NSString *) metadata;

/**
 * Create GeoPackage metadata with a dataset scope and metadata reference
 *
 * @param geoPackage
 *            GeoPackage
 * @param uri
 *            URI
 * @param metadata
 *            metadata
 * @return metadata reference
 */
+(GPKGMetadataReference *) createGeoPackageDatasetMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andURI: (NSString *) uri andMetadata: (NSString *) metadata;

/**
 * Create GeoPackage metadata and metadata reference
 *
 * @param geoPackage
 *            GeoPackage
 * @param scope
 *            metadata scope type
 * @param uri
 *            URI
 * @param metadata
 *            metadata
 * @return metadata reference
 */
+(GPKGMetadataReference *) createGeoPackageMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri andMetadata: (NSString *) metadata;

/**
 * Create metadata and metadata reference
 *
 * @param geoPackage
 *            GeoPackage
 * @param scope
 *            metadata scope type
 * @param uri
 *            URI
 * @param metadata
 *            metadata
 * @param reference
 *            metadata reference
 * @return metadata reference
 */
+(GPKGMetadataReference *) createMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri andMetadata: (NSString *) metadata andReference: (GPKGMetadataReference *) reference;

@end
