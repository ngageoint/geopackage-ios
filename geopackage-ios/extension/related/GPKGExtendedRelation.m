//
//  GPKGExtendedRelation.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGExtendedRelation.h"
#import "GPKGRelationTypes.h"

NSString * const GPKG_ER_TABLE_NAME = @"gpkgext_relations";
NSString * const GPKG_ER_COLUMN_PK = @"id";
NSString * const GPKG_ER_COLUMN_ID = @"id";
NSString * const GPKG_ER_COLUMN_BASE_TABLE_NAME = @"base_table_name";
NSString * const GPKG_ER_COLUMN_BASE_PRIMARY_COLUMN = @"base_primary_column";
NSString * const GPKG_ER_COLUMN_RELATED_TABLE_NAME = @"related_table_name";
NSString * const GPKG_ER_COLUMN_RELATED_PRIMARY_COLUMN = @"related_primary_column";
NSString * const GPKG_ER_COLUMN_RELATION_NAME = @"relation_name";
NSString * const GPKG_ER_COLUMN_MAPPING_TABLE_NAME = @"mapping_table_name";

@implementation GPKGExtendedRelation

-(instancetype) init{
    self = [super init];
    return self;
}

-(void) resetId{
    self.id = nil;
}

-(enum GPKGRelationType) relationType{
    enum GPKGRelationType value = -1;
    
    if(self.relationName != nil){
        value = [GPKGRelationTypes fromName:self.relationName];
    }
    
    return value;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGExtendedRelation *extendedRelation = [[GPKGExtendedRelation alloc] init];
    extendedRelation.id = _id;
    extendedRelation.baseTableName = _baseTableName;
    extendedRelation.basePrimaryColumn = _basePrimaryColumn;
    extendedRelation.relatedTableName = _relatedTableName;
    extendedRelation.relatedPrimaryColumn = _relatedPrimaryColumn;
    extendedRelation.relationName = _relationName;
    extendedRelation.mappingTableName = _mappingTableName;
    return extendedRelation;
}

@end
