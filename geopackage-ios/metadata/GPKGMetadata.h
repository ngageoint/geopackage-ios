//
//  GPKGMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGMetadataScope.h"

extern NSString * const M_TABLE_NAME;
extern NSString * const M_COLUMN_PK;
extern NSString * const M_COLUMN_ID;
extern NSString * const M_COLUMN_SCOPE;
extern NSString * const M_COLUMN_STANDARD_URI;
extern NSString * const M_COLUMN_MIME_TYPE;
extern NSString * const M_COLUMN_METADATA;

enum GPKGMetadataScopeType{
    UNDEFINED,
    FIELD_SESSION,
    COLLECTION_SESSION,
    SERIES,
    DATASET,
    FEATURE_TYPE,
    FEATURE,
    ATTRIBUTE_TYPE,
    ATTRIBUTE,
    TILE,
    MODEL,
    CATALOG,
    SCHEMA,
    TAXONOMY,
    SOFTWARE,
    SERVICE,
    COLLECTION_HARDWARE,
    NON_GEOGRAPHIC_DATASET,
    DIMENSION_GROUP
};

extern NSString * const MST_UNDEFINED;
extern NSString * const MST_FIELD_SESSION;
extern NSString * const MST_COLLECTION_SESSION;
extern NSString * const MST_SERIES;
extern NSString * const MST_DATASET;
extern NSString * const MST_FEATURE_TYPE;
extern NSString * const MST_FEATURE;
extern NSString * const MST_ATTRIBUTE_TYPE;
extern NSString * const MST_ATTRIBUTE;
extern NSString * const MST_TILE;
extern NSString * const MST_MODEL;
extern NSString * const MST_CATALOG;
extern NSString * const MST_SCHEMA;
extern NSString * const MST_TAXONOMY;
extern NSString * const MST_SOFTWARE;
extern NSString * const MST_SERVICE;
extern NSString * const MST_COLLECTION_HARDWARE;
extern NSString * const MST_NON_GEOGRAPHIC_DATASET;
extern NSString * const MST_DIMENSION_GROUP;

@interface GPKGMetadata : NSObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *scope;
@property (nonatomic, strong) NSString *standardUri;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *metadata;

-(enum GPKGMetadataScopeType) getMetadataScopeType;

-(void) setMetadataScopeType: (enum GPKGMetadataScopeType) scopeType;

+(GPKGMetadataScope *) fromScopeType: (enum GPKGMetadataScopeType) type;

@end
