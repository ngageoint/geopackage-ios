//
//  GPKGMetadata.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMetadata.h"

NSString * const M_TABLE_NAME = @"gpkg_metadata";
NSString * const M_COLUMN_PK = @"id";
NSString * const M_COLUMN_ID = @"id";
NSString * const M_COLUMN_SCOPE = @"md_scope";
NSString * const M_COLUMN_STANDARD_URI = @"md_standard_uri";
NSString * const M_COLUMN_MIME_TYPE = @"mime_type";
NSString * const M_COLUMN_METADATA = @"metadata";

NSString * const MST_UNDEFINED = @"undefined";
NSString * const MST_FIELD_SESSION = @"fieldSession";
NSString * const MST_COLLECTION_SESSION = @"collectionSession";
NSString * const MST_SERIES = @"series";
NSString * const MST_DATASET = @"dataset";
NSString * const MST_FEATURE_TYPE = @"featureType";
NSString * const MST_FEATURE = @"feature";
NSString * const MST_ATTRIBUTE_TYPE = @"attributeType";
NSString * const MST_ATTRIBUTE = @"attribute";
NSString * const MST_TILE = @"tile";
NSString * const MST_MODEL = @"model";
NSString * const MST_CATALOG = @"catalog";
NSString * const MST_SCHEMA = @"schema";
NSString * const MST_TAXONOMY = @"taxonomy";
NSString * const MST_SOFTWARE = @"software";
NSString * const MST_SERVICE = @"service";
NSString * const MST_COLLECTION_HARDWARE = @"collectionHardware";
NSString * const MST_NON_GEOGRAPHIC_DATASET = @"nonGeographicDataset";
NSString * const MST_DIMENSION_GROUP = @"dimensionGroup";

@implementation GPKGMetadata

-(enum GPKGMetadataScopeType) getMetadataScopeType{
    enum GPKGMetadataScopeType value = -1;
    
    if(self.scope != nil){
        NSDictionary *scopeTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:UNDEFINED], MST_UNDEFINED,
                                         [NSNumber numberWithInteger:FIELD_SESSION], MST_FIELD_SESSION,
                                         [NSNumber numberWithInteger:COLLECTION_SESSION], MST_COLLECTION_SESSION,
                                         [NSNumber numberWithInteger:SERIES], MST_SERIES,
                                         [NSNumber numberWithInteger:DATASET], MST_DATASET,
                                         [NSNumber numberWithInteger:FEATURE_TYPE], MST_FEATURE_TYPE,
                                         [NSNumber numberWithInteger:FEATURE], MST_FEATURE,
                                         [NSNumber numberWithInteger:ATTRIBUTE_TYPE], MST_ATTRIBUTE_TYPE,
                                         [NSNumber numberWithInteger:ATTRIBUTE], MST_ATTRIBUTE,
                                         [NSNumber numberWithInteger:TILE], MST_TILE,
                                         [NSNumber numberWithInteger:MODEL], MST_MODEL,
                                         [NSNumber numberWithInteger:CATALOG], MST_CATALOG,
                                         [NSNumber numberWithInteger:SCHEMA], MST_SCHEMA,
                                         [NSNumber numberWithInteger:TAXONOMY], MST_TAXONOMY,
                                         [NSNumber numberWithInteger:SOFTWARE], MST_SOFTWARE,
                                         [NSNumber numberWithInteger:SERVICE], MST_SERVICE,
                                         [NSNumber numberWithInteger:COLLECTION_HARDWARE], MST_COLLECTION_HARDWARE,
                                         [NSNumber numberWithInteger:NON_GEOGRAPHIC_DATASET], MST_NON_GEOGRAPHIC_DATASET,
                                         [NSNumber numberWithInteger:DIMENSION_GROUP], MST_DIMENSION_GROUP,
                                         nil
                                         ];
        NSNumber *enumValue = [scopeTypes objectForKey:self.scope];
        value = (enum GPKGMetadataScopeType)[enumValue intValue];
    }
    
    return value;
}

-(void) setMetadataScopeType: (enum GPKGMetadataScopeType) scopeType{
    
    GPKGMetadataScope * scope = [GPKGMetadata fromScopeType:scopeType];
    self.scope = scope.name;
}

+(GPKGMetadataScope *) fromScopeType: (enum GPKGMetadataScopeType) type{
    
    GPKGMetadataScope * scope = [[GPKGMetadataScope alloc] init];
    
    switch(type){
        case UNDEFINED:
            scope.name = MST_UNDEFINED;
            scope.code = @"NA";
            scope.definition = @"Metadata information scope is undefined";
            break;
        case FIELD_SESSION:
            scope.name = MST_FIELD_SESSION;
            scope.code = @"012";
            scope.definition = @"Information applies to the field session";
            break;
        case COLLECTION_SESSION:
            scope.name = MST_COLLECTION_SESSION;
            scope.code = @"004";
            scope.definition = @"Information applies to the collection session";
            break;
        case SERIES:
            scope.name = MST_SERIES;
            scope.code = @"006";
            scope.definition = @"Information applies to the (dataset) series";
            break;
        case DATASET:
            scope.name = MST_DATASET;
            scope.code = @"005";
            scope.definition = @"Information applies to the (geographic feature) dataset";
            break;
        case FEATURE_TYPE:
            scope.name = MST_FEATURE_TYPE;
            scope.code = @"010";
            scope.definition = @"Information applies to a feature type (class)";
            break;
        case FEATURE:
            scope.name = MST_FEATURE;
            scope.code = @"009";
            scope.definition = @"Information applies to a feature (instance)";
            break;
        case ATTRIBUTE_TYPE:
            scope.name = MST_ATTRIBUTE_TYPE;
            scope.code = @"002";
            scope.definition = @"Information applies to the attribute class";
            break;
        case ATTRIBUTE:
            scope.name = MST_ATTRIBUTE;
            scope.code = @"001";
            scope.definition = @"Information applies to the characteristic of a feature (instance)";
            break;
        case TILE:
            scope.name = MST_TILE;
            scope.code = @"016";
            scope.definition = @"Information applies to a tile, a spatial subset of geographic data";
            break;
        case MODEL:
            scope.name = MST_MODEL;
            scope.code = @"015";
            scope.definition = @"Information applies to a copy or imitation of an existing or hypothetical object";
            break;
        case CATALOG:
            scope.name = MST_CATALOG;
            scope.code = @"NA";
            scope.definition = @"Metadata applies to a feature catalog";
            break;
        case SCHEMA:
            scope.name = MST_SCHEMA;
            scope.code = @"NA";
            scope.definition = @"Metadata applies to an application schema";
            break;
        case TAXONOMY:
            scope.name = MST_TAXONOMY;
            scope.code = @"NA";
            scope.definition = @"Metadata applies to a taxonomy or knowledge system";
            break;
        case SOFTWARE:
            scope.name = MST_SOFTWARE;
            scope.code = @"013";
            scope.definition = @"Information applies to a computer program or routine";
            break;
        case SERVICE:
            scope.name = MST_SERVICE;
            scope.code = @"014";
            scope.definition = @"Information applies to a capability which a service provider entity makes available to a service user entity through a set of interfaces that define a behaviour, such as a use case";
            break;
        case COLLECTION_HARDWARE:
            scope.name = MST_COLLECTION_HARDWARE;
            scope.code = @"003";
            scope.definition = @"Information applies to the collection hardware class";
            break;
        case NON_GEOGRAPHIC_DATASET:
            scope.name = MST_NON_GEOGRAPHIC_DATASET;
            scope.code = @"007";
            scope.definition = @"Information applies to non-geographic data";
            break;
        case DIMENSION_GROUP:
            scope.name = MST_DIMENSION_GROUP;
            scope.code = @"008";
            scope.definition = @"Information applies to a dimension group";
            break;
    }
    
    return scope;
}

@end
