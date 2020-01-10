//
//  GPKGStyleMappingTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGStyleMappingTable.h"

NSString * const GPKG_SMT_COLUMN_GEOMETRY_TYPE_NAME = @"geometry_type_name";

@implementation GPKGStyleMappingTable

-(instancetype) initWithTableName: (NSString *) tableName{
    self = [super initWithTable:tableName andColumns:[GPKGStyleMappingTable createColumns]];
    return self;
}

-(instancetype) initWithTable: (GPKGUserCustomTable *) table{
    self = [super initWithTable:table];
    return self;
}

/**
 * Create the style mapping columns
 *
 * @return columns
 */
+(NSArray *) createColumns{
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [[NSMutableArray alloc] init];
    [columns addObjectsFromArray:[self createRequiredColumns]];
    
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:GPKG_SMT_COLUMN_GEOMETRY_TYPE_NAME andDataType:GPKG_DT_TEXT]];
    
    return columns;
}

-(int) geometryTypeNameColumnIndex{
    return [self columnIndexWithColumnName:GPKG_SMT_COLUMN_GEOMETRY_TYPE_NAME];
}

-(GPKGUserCustomColumn *) geometryTypeNameColumn{
    return (GPKGUserCustomColumn *)[self columnWithColumnName:GPKG_SMT_COLUMN_GEOMETRY_TYPE_NAME];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGStyleMappingTable *styleMappingTable = [super mutableCopyWithZone:zone];
    return styleMappingTable;
}

@end
