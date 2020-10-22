//
//  GPKGUserMappingTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserMappingTable.h"

NSString * const GPKG_UMT_COLUMN_BASE_ID = @"base_id";
NSString * const GPKG_UMT_COLUMN_RELATED_ID = @"related_id";

@implementation GPKGUserMappingTable

+(GPKGUserMappingTable *) createWithName: (NSString *) tableName{
    return [self createWithName:tableName andAdditionalColumns:nil];
}

+(GPKGUserMappingTable *) createWithName: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns{
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [NSMutableArray array];
    [columns addObjectsFromArray:[self createRequiredColumns]];
    
    if(additionalColumns != nil){
        [columns addObjectsFromArray:additionalColumns];
    }
    
    return [[GPKGUserMappingTable alloc] initWithTable:tableName andColumns:columns];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumns{
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [NSMutableArray array];
    [columns addObject:[self createBaseIdColumn]];
    [columns addObject:[self createRelatedIdColumn]];
    
    return columns;
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex{
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [NSMutableArray array];
    [columns addObject:[self createBaseIdColumnWithIndex:startingIndex++]];
    [columns addObject:[self createRelatedIdColumnWithIndex:startingIndex++]];
    
    return columns;
}

+(GPKGUserCustomColumn *) createBaseIdColumn{
    return [self createBaseIdColumnWithIndex:NO_INDEX];
}

+(GPKGUserCustomColumn *) createBaseIdColumnWithIndex: (int) index{
    return [GPKGUserCustomColumn createColumnWithIndex:index andName:GPKG_UMT_COLUMN_BASE_ID andDataType:GPKG_DT_INTEGER andNotNull:YES];
}

+(GPKGUserCustomColumn *) createRelatedIdColumn{
    return [self createRelatedIdColumnWithIndex:NO_INDEX];
}

+(GPKGUserCustomColumn *) createRelatedIdColumnWithIndex: (int) index{
    return [GPKGUserCustomColumn createColumnWithIndex:index andName:GPKG_UMT_COLUMN_RELATED_ID andDataType:GPKG_DT_INTEGER andNotNull:YES];
}

+(int) numRequiredColumns{
    return (int)[self requiredColumns].count;
}

+(NSArray<NSString *> *) requiredColumns{
    NSMutableArray<NSString *> *requiredColumns = [NSMutableArray array];
    [requiredColumns addObject:GPKG_UMT_COLUMN_BASE_ID];
    [requiredColumns addObject:GPKG_UMT_COLUMN_RELATED_ID];
    return requiredColumns;
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [super initWithTable:tableName andColumns:columns andRequiredColumns:[GPKGUserMappingTable requiredColumns]];
    return self;
}

-(instancetype) initWithTable: (GPKGUserCustomTable *) table{
    self = [super initWithCustomTable:table];
    return self;
}

-(int) baseIdColumnIndex{
    return [self columnIndexWithColumnName:GPKG_UMT_COLUMN_BASE_ID];
}

-(GPKGUserCustomColumn *) baseIdColumn{
    return (GPKGUserCustomColumn *)[self columnWithColumnName:GPKG_UMT_COLUMN_BASE_ID];
}

-(int) relatedIdColumnIndex{
    return [self columnIndexWithColumnName:GPKG_UMT_COLUMN_RELATED_ID];
}

-(GPKGUserCustomColumn *) relatedIdColumn{
    return (GPKGUserCustomColumn *)[self columnWithColumnName:GPKG_UMT_COLUMN_RELATED_ID];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserMappingTable *userMappingTable = [super mutableCopyWithZone:zone];
    return userMappingTable;
}

@end
