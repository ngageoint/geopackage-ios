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
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [[NSMutableArray alloc] init];
    [columns addObjectsFromArray:[self createRequiredColumns]];
    
    if(additionalColumns != nil){
        [columns addObjectsFromArray:additionalColumns];
    }
    
    return [[GPKGUserMappingTable alloc] initWithTable:tableName andColumns:columns andRequiredColumns:[self requiredColumns]];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumns{
    return [self createRequiredColumnsWithIndex:0];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex{
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [[NSMutableArray alloc] init];
    [columns addObject:[self createBaseIdColumnWithIndex:startingIndex++]];
    [columns addObject:[self createRelatedIdColumnWithIndex:startingIndex++]];
    
    return columns;
}

+(GPKGUserCustomColumn *) createBaseIdColumnWithIndex: (int) index{
    return [GPKGUserCustomColumn createColumnWithIndex:index andName:GPKG_UMT_COLUMN_BASE_ID andDataType:GPKG_DT_INTEGER andNotNull:YES andDefaultValue:nil];
}

+(GPKGUserCustomColumn *) createRelatedIdColumnWithIndex: (int) index{
    return [GPKGUserCustomColumn createColumnWithIndex:index andName:GPKG_UMT_COLUMN_RELATED_ID andDataType:GPKG_DT_INTEGER andNotNull:YES andDefaultValue:nil];
}

+(int) numRequiredColumns{
    return (int)[self requiredColumns].count;
}

+(NSArray<NSString *> *) requiredColumns{
    NSMutableArray<NSString *> *requiredColumns = [[NSMutableArray alloc] init];
    [requiredColumns addObject:GPKG_UMT_COLUMN_BASE_ID];
    [requiredColumns addObject:GPKG_UMT_COLUMN_RELATED_ID];
    return requiredColumns;
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andRequiredColumns:(NSArray<NSString *> *)requiredColumns{
    self = [super initWithTable:tableName andColumns:columns andRequiredColumns:requiredColumns];
    return self;
}

-(instancetype) initWithTable: (GPKGUserCustomTable *) table{
    self = [super initWithCustomTable:table];
    return self;
}

-(int) baseIdColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_UMT_COLUMN_BASE_ID];
}

-(GPKGUserCustomColumn *) baseIdColumn{
    return (GPKGUserCustomColumn *)[self getColumnWithColumnName:GPKG_UMT_COLUMN_BASE_ID];
}

-(int) relatedIdColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_UMT_COLUMN_RELATED_ID];
}

-(GPKGUserCustomColumn *) relatedIdColumn{
    return (GPKGUserCustomColumn *)[self getColumnWithColumnName:GPKG_UMT_COLUMN_RELATED_ID];
}

@end
