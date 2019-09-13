//
//  GPKGSimpleAttributesTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGSimpleAttributesTable.h"

NSString * const GPKG_RSAT_COLUMN_ID = @"id";

@implementation GPKGSimpleAttributesTable

+(enum GPKGRelationType) relationType{
    return GPKG_RT_SIMPLE_ATTRIBUTES;
}

+(GPKGSimpleAttributesTable *) createWithName: (NSString *) tableName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns{
    return [self createWithName:tableName andIdColumnName:nil andColumns:columns];
}

+(GPKGSimpleAttributesTable *) createWithName: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns{
    
    NSMutableArray<GPKGUserCustomColumn *> *tableColumns = [[NSMutableArray alloc] init];
    [tableColumns addObjectsFromArray:[self createRequiredColumnsWithIdColumnName:idColumnName]];
    
    if(columns != nil){
        [tableColumns addObjectsFromArray:columns];
    }
    
    return [[GPKGSimpleAttributesTable alloc] initWithTable:tableName andColumns:tableColumns andIdColumnName:idColumnName];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumns{
    return [self createRequiredColumnsWithIdColumnName:nil];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIdColumnName: (NSString *) idColumnName{

    if(idColumnName == nil){
        idColumnName = GPKG_RSAT_COLUMN_ID;
    }
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [[NSMutableArray alloc] init];
    [columns addObject:[self createIdColumnWithName:idColumnName]];
    
    return columns;
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex{
    return [self createRequiredColumnsWithIndex:startingIndex andIdColumnName:nil];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex andIdColumnName: (NSString *) idColumnName{
    
    if(idColumnName == nil){
        idColumnName = GPKG_RSAT_COLUMN_ID;
    }
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [[NSMutableArray alloc] init];
    [columns addObject:[self createIdColumnWithIndex:startingIndex++ andName:idColumnName]];
    
    return columns;
}

+(GPKGUserCustomColumn *) createIdColumnWithName: (NSString *) idColumnName{
    return [self createIdColumnWithIndex:NO_INDEX andName:idColumnName];
}

+(GPKGUserCustomColumn *) createIdColumnWithIndex: (int) index andName: (NSString *) idColumnName{
    return [GPKGUserCustomColumn createPrimaryKeyColumnWithIndex:index andName:idColumnName];
}

+(int) numRequiredColumns{
    return (int)[self requiredColumns].count;
}

+(NSArray<NSString *> *) requiredColumns{
    return [self requiredColumnsWithIdColumnName:nil];
}

+(NSArray<NSString *> *) requiredColumnsWithIdColumnName: (NSString *) idColumnName{
    
    if(idColumnName == nil){
        idColumnName = GPKG_RSAT_COLUMN_ID;
    }
    
    NSMutableArray<NSString *> *requiredColumns = [[NSMutableArray alloc] init];
    [requiredColumns addObject:idColumnName];
    return requiredColumns;
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    return [self initWithTable:tableName andColumns:columns andIdColumnName:nil];
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andIdColumnName: (NSString *) idColumnName{
    self = [super initWithTable:tableName andRelation:[GPKGRelationTypes name:[GPKGSimpleAttributesTable relationType]] andDataType:[GPKGRelationTypes dataType:[GPKGSimpleAttributesTable relationType]] andColumns:columns andRequiredColumns:[GPKGSimpleAttributesTable requiredColumnsWithIdColumnName:idColumnName]];
    if(self != nil){
        [self validateColumns];
    }
    return self;
}

-(instancetype) initWithTable: (GPKGUserCustomTable *) table{
    self = [super initWithRelation:[GPKGRelationTypes name:[GPKGSimpleAttributesTable relationType]] andDataType:[GPKGRelationTypes dataType:[GPKGSimpleAttributesTable relationType]] andCustomTable:table];
    if(self != nil){
        [self validateColumns];
    }
    return self;
}

-(void) validateColumns{
    
    NSArray<GPKGUserColumn *> *columns = [self columns];
    if(columns.count < 2){
        [NSException raise:@"Simple Attributes Columns" format:@"Simple Attributes Tables require at least one non id column. Columns: %lu", (unsigned long)columns.count];
    }
    
    for(GPKGUserCustomColumn *column in columns){
        if(![GPKGSimpleAttributesTable isSimpleColumn:column]){
            [NSException raise:@"Simple Attributes Columns" format:@"Simple Attributes Tables only support simple data types. Column: %@, Non Simple Data Type: %@", column.name, [GPKGDataTypes name:column.dataType]];
        }
    }
}

-(int) idColumnIndex{
    return self.pkIndex;
}

-(GPKGUserCustomColumn *) idColumn{
    return (GPKGUserCustomColumn *)[self getPkColumn];
}

+(BOOL) isSimpleColumn: (GPKGUserColumn *) column{
    return column.notNull && [self isSimpleDataType:column.dataType];
}

+(BOOL) isSimpleDataType: (enum GPKGDataType) dataType{
    return dataType != GPKG_DT_BLOB;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGSimpleAttributesTable *simpleAttributesTable = [super mutableCopyWithZone:zone];
    return simpleAttributesTable;
}

@end
