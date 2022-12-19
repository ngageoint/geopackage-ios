//
//  GPKGDgiwgMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGMetadataReference.h"
#import "GPKGGeoPackage.h"

/**
 * DGIWG (Defence Geospatial Information Working Group) Metadata utilities
 */
@interface GPKGDgiwgMetadata : NSObject

/**
 * Create a new metadata object with a series scope
 *
 * @param metadata
 *            metadata
 * @param uri
 *            URI
 * @return metadata
 */
+(GPKGMetadata *) createSeriesMetadata: (NSString *) metadata withURI: (NSString *) uri;

/**
 * Create a new metadata object with a dataset scope
 *
 * @param metadata
 *            metadata
 * @param uri
 *            URI
 * @return metadata
 */
+(GPKGMetadata *) createDatasetMetadata: (NSString *) metadata withURI: (NSString *) uri;

/**
 * Create a new metadata object
 *
 * @param metadata
 *            metadata
 * @param scope
 *            metadata scope type
 * @param uri
 *            URI
 * @return metadata
 */
+(GPKGMetadata *) createMetadata: (NSString *) metadata withScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri;

/**
 * Create a new metadata reference object with a GeoPackage scope
 *
 * @return metadata reference
 */
+(GPKGMetadataReference *) createGeoPackageMetadataReference;

/**
 * Create a new metadata reference object
 *
 * @param scope
 *            metadata reference scope type
 * @return metadata reference
 */
+(GPKGMetadataReference *) createMetadataReferenceWithScope: (enum GPKGReferenceScopeType) scope;

/**
 * Query for GeoPackage DGIWG Metadata Foundation (DMF) metadata
 *
 * @param geoPackage
 *            GeoPackage
 * @return metadata references
 */
+(GPKGResultSet *) queryGeoPackageDMFMetadata: (GPKGGeoPackage *) geoPackage;

/**
 * Query for GeoPackage NSG Metadata Foundation (NMF) NSG Application Schema
 * (NAS) metadata
 *
 * @param geoPackage
 *            GeoPackage
 * @return metadata references
 */
+(GPKGResultSet *) queryGeoPackageNASMetadata: (GPKGGeoPackage *) geoPackage;

/**
 * Query for GeoPackage metadata
 *
 * @param geoPackage
 *            GeoPackage
 * @param baseURI
 *            base URI
 * @return metadata references
 */
+(GPKGResultSet *) queryGeoPackageMetadata: (GPKGGeoPackage *) geoPackage withBaseURI: (NSString *) baseURI;

@end
