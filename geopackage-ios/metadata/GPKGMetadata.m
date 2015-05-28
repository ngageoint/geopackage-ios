//
//  GPKGMetadata.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMetadata.h"
#import "GPKGUtils.h"

NSString * const GPKG_M_TABLE_NAME = @"gpkg_metadata";
NSString * const GPKG_M_COLUMN_PK = @"id";
NSString * const GPKG_M_COLUMN_ID = @"id";
NSString * const GPKG_M_COLUMN_SCOPE = @"md_scope";
NSString * const GPKG_M_COLUMN_STANDARD_URI = @"md_standard_uri";
NSString * const GPKG_M_COLUMN_MIME_TYPE = @"mime_type";
NSString * const GPKG_M_COLUMN_METADATA = @"metadata";

NSString * const GPKG_MST_UNDEFINED_NAME = @"undefined";
NSString * const GPKG_MST_FIELD_SESSION_NAME = @"fieldSession";
NSString * const GPKG_MST_COLLECTION_SESSION_NAME = @"collectionSession";
NSString * const GPKG_MST_SERIES_NAME = @"series";
NSString * const GPKG_MST_DATASET_NAME = @"dataset";
NSString * const GPKG_MST_FEATURE_TYPE_NAME = @"featureType";
NSString * const GPKG_MST_FEATURE_NAME = @"feature";
NSString * const GPKG_MST_ATTRIBUTE_TYPE_NAME = @"attributeType";
NSString * const GPKG_MST_ATTRIBUTE_NAME = @"attribute";
NSString * const GPKG_MST_TILE_NAME = @"tile";
NSString * const GPKG_MST_MODEL_NAME = @"model";
NSString * const GPKG_MST_CATALOG_NAME = @"catalog";
NSString * const GPKG_MST_SCHEMA_NAME = @"schema";
NSString * const GPKG_MST_TAXONOMY_NAME = @"taxonomy";
NSString * const GPKG_MST_SOFTWARE_NAME = @"software";
NSString * const GPKG_MST_SERVICE_NAME = @"service";
NSString * const GPKG_MST_COLLECTION_HARDWARE_NAME = @"collectionHardware";
NSString * const GPKG_MST_NON_GEOGRAPHIC_DATASET_NAME = @"nonGeographicDataset";
NSString * const GPKG_MST_DIMENSION_GROUP_NAME = @"dimensionGroup";

@implementation GPKGMetadata

-(enum GPKGMetadataScopeType) getMetadataScopeType{
    enum GPKGMetadataScopeType value = -1;
    
    if(self.scope != nil){
        NSDictionary *scopeTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:GPKG_MST_UNDEFINED], GPKG_MST_UNDEFINED_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_FIELD_SESSION], GPKG_MST_FIELD_SESSION_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_COLLECTION_SESSION], GPKG_MST_COLLECTION_SESSION_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_SERIES], GPKG_MST_SERIES_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_DATASET], GPKG_MST_DATASET_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_FEATURE_TYPE], GPKG_MST_FEATURE_TYPE_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_FEATURE], GPKG_MST_FEATURE_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_ATTRIBUTE_TYPE], GPKG_MST_ATTRIBUTE_TYPE_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_ATTRIBUTE], GPKG_MST_ATTRIBUTE_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_TILE], GPKG_MST_TILE_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_MODEL], GPKG_MST_MODEL_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_CATALOG], GPKG_MST_CATALOG_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_SCHEMA], GPKG_MST_SCHEMA_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_TAXONOMY], GPKG_MST_TAXONOMY_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_SOFTWARE], GPKG_MST_SOFTWARE_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_SERVICE], GPKG_MST_SERVICE_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_COLLECTION_HARDWARE], GPKG_MST_COLLECTION_HARDWARE_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_NON_GEOGRAPHIC_DATASET], GPKG_MST_NON_GEOGRAPHIC_DATASET_NAME,
                                         [NSNumber numberWithInteger:GPKG_MST_DIMENSION_GROUP], GPKG_MST_DIMENSION_GROUP_NAME,
                                         nil
                                         ];
        NSNumber *enumValue = [GPKGUtils objectForKey:self.scope inDictionary:scopeTypes];
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
        case GPKG_MST_UNDEFINED:
            scope.name = GPKG_MST_UNDEFINED_NAME;
            scope.code = @"NA";
            scope.definition = @"Metadata information scope is undefined";
            break;
        case GPKG_MST_FIELD_SESSION:
            scope.name = GPKG_MST_FIELD_SESSION_NAME;
            scope.code = @"012";
            scope.definition = @"Information applies to the field session";
            break;
        case GPKG_MST_COLLECTION_SESSION:
            scope.name = GPKG_MST_COLLECTION_SESSION_NAME;
            scope.code = @"004";
            scope.definition = @"Information applies to the collection session";
            break;
        case GPKG_MST_SERIES:
            scope.name = GPKG_MST_SERIES_NAME;
            scope.code = @"006";
            scope.definition = @"Information applies to the (dataset) series";
            break;
        case GPKG_MST_DATASET:
            scope.name = GPKG_MST_DATASET_NAME;
            scope.code = @"005";
            scope.definition = @"Information applies to the (geographic feature) dataset";
            break;
        case GPKG_MST_FEATURE_TYPE:
            scope.name = GPKG_MST_FEATURE_TYPE_NAME;
            scope.code = @"010";
            scope.definition = @"Information applies to a feature type (class)";
            break;
        case GPKG_MST_FEATURE:
            scope.name = GPKG_MST_FEATURE_NAME;
            scope.code = @"009";
            scope.definition = @"Information applies to a feature (instance)";
            break;
        case GPKG_MST_ATTRIBUTE_TYPE:
            scope.name = GPKG_MST_ATTRIBUTE_TYPE_NAME;
            scope.code = @"002";
            scope.definition = @"Information applies to the attribute class";
            break;
        case GPKG_MST_ATTRIBUTE:
            scope.name = GPKG_MST_ATTRIBUTE_NAME;
            scope.code = @"001";
            scope.definition = @"Information applies to the characteristic of a feature (instance)";
            break;
        case GPKG_MST_TILE:
            scope.name = GPKG_MST_TILE_NAME;
            scope.code = @"016";
            scope.definition = @"Information applies to a tile, a spatial subset of geographic data";
            break;
        case GPKG_MST_MODEL:
            scope.name = GPKG_MST_MODEL_NAME;
            scope.code = @"015";
            scope.definition = @"Information applies to a copy or imitation of an existing or hypothetical object";
            break;
        case GPKG_MST_CATALOG:
            scope.name = GPKG_MST_CATALOG_NAME;
            scope.code = @"NA";
            scope.definition = @"Metadata applies to a feature catalog";
            break;
        case GPKG_MST_SCHEMA:
            scope.name = GPKG_MST_SCHEMA_NAME;
            scope.code = @"NA";
            scope.definition = @"Metadata applies to an application schema";
            break;
        case GPKG_MST_TAXONOMY:
            scope.name = GPKG_MST_TAXONOMY_NAME;
            scope.code = @"NA";
            scope.definition = @"Metadata applies to a taxonomy or knowledge system";
            break;
        case GPKG_MST_SOFTWARE:
            scope.name = GPKG_MST_SOFTWARE_NAME;
            scope.code = @"013";
            scope.definition = @"Information applies to a computer program or routine";
            break;
        case GPKG_MST_SERVICE:
            scope.name = GPKG_MST_SERVICE_NAME;
            scope.code = @"014";
            scope.definition = @"Information applies to a capability which a service provider entity makes available to a service user entity through a set of interfaces that define a behaviour, such as a use case";
            break;
        case GPKG_MST_COLLECTION_HARDWARE:
            scope.name = GPKG_MST_COLLECTION_HARDWARE_NAME;
            scope.code = @"003";
            scope.definition = @"Information applies to the collection hardware class";
            break;
        case GPKG_MST_NON_GEOGRAPHIC_DATASET:
            scope.name = GPKG_MST_NON_GEOGRAPHIC_DATASET_NAME;
            scope.code = @"007";
            scope.definition = @"Information applies to non-geographic data";
            break;
        case GPKG_MST_DIMENSION_GROUP:
            scope.name = GPKG_MST_DIMENSION_GROUP_NAME;
            scope.code = @"008";
            scope.definition = @"Information applies to a dimension group";
            break;
    }
    
    return scope;
}

@end
