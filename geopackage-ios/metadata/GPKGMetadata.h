//
//  GPKGMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGMetadataScope.h"

/**
 *  Metadata table constants
 */
extern NSString * const GPKG_M_TABLE_NAME;
extern NSString * const GPKG_M_COLUMN_PK;
extern NSString * const GPKG_M_COLUMN_ID;
extern NSString * const GPKG_M_COLUMN_SCOPE;
extern NSString * const GPKG_M_COLUMN_STANDARD_URI;
extern NSString * const GPKG_M_COLUMN_MIME_TYPE;
extern NSString * const GPKG_M_COLUMN_METADATA;

/**
 *  Metadata Scope Type enumeration
 */
enum GPKGMetadataScopeType{
    GPKG_MST_UNDEFINED,
    GPKG_MST_FIELD_SESSION,
    GPKG_MST_COLLECTION_SESSION,
    GPKG_MST_SERIES,
    GPKG_MST_DATASET,
    GPKG_MST_FEATURE_TYPE,
    GPKG_MST_FEATURE,
    GPKG_MST_ATTRIBUTE_TYPE,
    GPKG_MST_ATTRIBUTE,
    GPKG_MST_TILE,
    GPKG_MST_MODEL,
    GPKG_MST_CATALOG,
    GPKG_MST_SCHEMA,
    GPKG_MST_TAXONOMY,
    GPKG_MST_SOFTWARE,
    GPKG_MST_SERVICE,
    GPKG_MST_COLLECTION_HARDWARE,
    GPKG_MST_NON_GEOGRAPHIC_DATASET,
    GPKG_MST_DIMENSION_GROUP
};

/**
 *  Metadata Scope Type enumeration names
 */
extern NSString * const GPKG_MST_UNDEFINED_NAME;
extern NSString * const GPKG_MST_FIELD_SESSION_NAME;
extern NSString * const GPKG_MST_COLLECTION_SESSION_NAME;
extern NSString * const GPKG_MST_SERIES_NAME;
extern NSString * const GPKG_MST_DATASET_NAME;
extern NSString * const GPKG_MST_FEATURE_TYPE_NAME;
extern NSString * const GPKG_MST_FEATURE_NAME;
extern NSString * const GPKG_MST_ATTRIBUTE_TYPE_NAME;
extern NSString * const GPKG_MST_ATTRIBUTE_NAME;
extern NSString * const GPKG_MST_TILE_NAME;
extern NSString * const GPKG_MST_MODEL_NAME;
extern NSString * const GPKG_MST_CATALOG_NAME;
extern NSString * const GPKG_MST_SCHEMA_NAME;
extern NSString * const GPKG_MST_TAXONOMY_NAME;
extern NSString * const GPKG_MST_SOFTWARE_NAME;
extern NSString * const GPKG_MST_SERVICE_NAME;
extern NSString * const GPKG_MST_COLLECTION_HARDWARE_NAME;
extern NSString * const GPKG_MST_NON_GEOGRAPHIC_DATASET_NAME;
extern NSString * const GPKG_MST_DIMENSION_GROUP_NAME;

/**
 *  Contains metadata in MIME encodings structured in accordance with any
 *  authoritative metadata specification
 */
@interface GPKGMetadata : NSObject

/**
 *  Metadata primary key
 */
@property (nonatomic, strong) NSNumber *id;

/**
 *  Case sensitive name of the data scope to which this metadata applies; see
 *  Metadata Scopes below
 */
@property (nonatomic, strong) NSString *scope;

/**
 *  URI reference to the metadata structure definition authority
 */
@property (nonatomic, strong) NSString *standardUri;

/**
 *  MIME encoding of metadata
 */
@property (nonatomic, strong) NSString *mimeType;

/**
 *  metadata
 */
@property (nonatomic, strong) NSString *metadata;

/**
 *  Get the metadata scope type
 *
 *  @return metadata scope type
 */
-(enum GPKGMetadataScopeType) getMetadataScopeType;

/**
 *  Set the metadata scope type
 *
 *  @param scopeType metadata scope type
 */
-(void) setMetadataScopeType: (enum GPKGMetadataScopeType) scopeType;

/**
 *  Get the metadata scope from the metadata scope type
 *
 *  @param type metadata scope type
 *
 *  @return metadata scope
 */
+(GPKGMetadataScope *) fromScopeType: (enum GPKGMetadataScopeType) type;

@end
